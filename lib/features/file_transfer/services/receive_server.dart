import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_share_app/constants/app_constant.dart';
import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:file_share_app/features/file_transfer/services/incoming_files.dart';
import 'package:file_share_app/features/file_transfer/services/incoming_session.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_multicast_lock/flutter_multicast_lock.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

enum ServerState { stopped, starting, running} // Tracks the status of the server. 
class ReceiveServer{
  ReceiveServer._internal();
  static final ReceiveServer instance = ReceiveServer._internal();
  final _multicastLock = FlutterMulticastLock();
  HttpServer? _server; // This is the engine that is running the network port.
  ServerState _state = ServerState.stopped;
  ServerState get state => _state; // This is the getter the UI will use to check if the server is running.
  bool get isRunning => _state == ServerState.running;
  final Map<String, IncomingSession> _sessions = {}; // Maps sessions to their unique sessionID.
  final Map<String, Completer<bool>> _decisionCompleters = {};

  // Broadcasts live updates(incoming session requests) from the network servers to the UI.
  final StreamController<IncomingSession> _sessionController =
     StreamController<IncomingSession>.broadcast();
  Stream<IncomingSession> get incomingSessionStream => _sessionController.stream;

  // This is basically for completed file transfers.
  final StreamController<String> _fileReceivedController = 
    StreamController<String>.broadcast();
  Stream<String> get fileReceivedStream => _fileReceivedController.stream;

  Future<void> start() async {
    await _multicastLock.acquireMulticastLock();
    if(state != ServerState.stopped) return;
    _state = ServerState.starting;
    final router = Router();
    // The sending device annnounces the incoming files
    router.post('/prepare', _handlePrepare);
    // The device does the streaming of the actual file bytes.
    router.post('/upload', _handleUpload);
    try {
      // This basically opens the server to the world.
      _server = await shelf_io.serve(
        router.call,
        '0.0.0.0', // This allows the device to listen to any connection on the local network and not just from that device.
        AppConstant.transferPort,
      );
      _state = ServerState.running;
      debugPrint('Receive server running on port ${AppConstant.transferPort}');
    } catch (e) {
      _state = ServerState.stopped;
      debugPrint('Failed to start receiver server $e');
    }
  }
  // This function handles the handshake between both devices.
  // It basically takes an incoming https request and promises to return an https response.
  Future<Response> _handlePrepare(Request request) async {
  try{
    final String body = await request.readAsString();
    final Map<String, dynamic> json = jsonDecode(body);
    // Parsing the transfer session.
    final String sessionId = json['sessionId'] as String;
    final String senderName = json['deviceName'] as String;
    final List<dynamic> filesJson = json['files'] as List<dynamic>;
    // Iterates through the filesJson array, performs type casting as a type
    // Passes it into a factory constructor.
    final List<IncomingFile> files = filesJson.
      map((a) => IncomingFile.fromJson(a as Map<String, dynamic>))
      .toList();
    final session = IncomingSession(
      sessionId: sessionId,
      senderName: senderName,
      files: files,
    );
    _sessions[sessionId] = session;

    final completer = Completer<bool>();
    _decisionCompleters[sessionId] = completer;
    _sessionController.add(session);

    final bool accepted = await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => false,
    );
    _decisionCompleters.remove(sessionId);
    if (!accepted) {
      _sessions.remove(sessionId);
    } else {
      for (final f in files) {
        TransferTracker.instance.addItem(TransferItem(
          id: f.fileId, 
          fileName: f.name, 
          mimeType: f.mimeType, 
          totalBytes: f.size, 
          direction: TransferDirection.received));
      }
    }

    return Response.ok(
      jsonEncode({
        'sessionId': sessionId,
        'status': accepted ? 'accepted' : 'declined',
        }),
        headers: {'Content-Type': 'application/json'},
      );
  } catch(e) {
    debugPrint('Error handling /prepare: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to process prepare request'}),
      headers: {'Content-Type' : 'application/json'},
      );
  }
}

void respondToSession(String sessionId, bool accepted) {
  final completer = _decisionCompleters[sessionId];
  if (completer != null && !completer.isCompleted) {
    completer.complete(accepted);
  }
}

Future<Response> _handleUpload(Request request) async {
  try{
    final String? sessionId = request.url.queryParameters['sessionId'];

    final String? fileId = request.url.queryParameters['fileId'];

    if(sessionId == null || fileId == null) {
      return Response.badRequest(
        body: jsonEncode({'error' : 'Missing sessionId or fileId'}),
        );
    }
    final IncomingSession? session = _sessions[sessionId];
    if(session == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Session not found'}),
        );
    }
    final IncomingFile? incomingFile = session.files
     .where((a) => a.fileId == fileId)
     .firstOrNull;
     if(incomingFile == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'File not found in session'}) 
        );
     }
     // Determine the directory to save the incoming files.
     final Directory saveDir = await _getSaveDirectory(incomingFile.mimeType);
     final String savePath = '${saveDir.path}/${incomingFile.name}';

     // Stream the file bytes to the disk.
     final File file = File(savePath);
     final IOSink sink = file.openWrite();
     int received = 0;
     await request.read().forEach((chunk) {
      sink.add(chunk);
      received += chunk.length;
      TransferTracker.instance.updateProgress(
        fileId, received
      );
     });
     await sink.close();

     TransferTracker.instance.markDone(fileId, savedPath: savePath);
     _fileReceivedController.add(savePath);
     debugPrint('File saved: $savePath');

     return Response.ok(
      jsonEncode({'status': 'received'}),
      headers: {'Content-Type' : 'application/json'},
     );
  } catch (e) {
    debugPrint('Error handling upload: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to save file'}),
      );
  }
}
// Gets the location to store the files.
Future<Directory> _getSaveDirectory(String mimeType) async {
  final Directory base = await getApplicationDocumentsDirectory();
  String subFolder = 'FileShare/Files';
  if(mimeType.startsWith('image/')) {
    subFolder = 'FileShare/Images';
  } else if (mimeType.startsWith('video/')) {
    subFolder = 'FileShare/Videos';
  } else if (mimeType.startsWith('audio/')) {
    subFolder = 'FileShare/Audio';
  } else if(mimeType == 'application/vnd.android.package-archive') {
    subFolder = 'FileShare/APKs';
  }
  final Directory dir = Directory('${base.path}/$subFolder');
  if(!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}
Future<void> stop() async {
  await _server?.close(force: true);
  _server = null;
  _sessions.clear();
  _state = ServerState.stopped;
  await _multicastLock.releaseMulticastLock();
  debugPrint('Receive server stopped');
}
Future<void> dispose() async {
  await stop();
  for (final c in _decisionCompleters.values) {
    if (!c.isCompleted) c.complete(false);
  }
  _decisionCompleters.clear();
  await _sessionController.close();
  await _fileReceivedController.close();
}
}

