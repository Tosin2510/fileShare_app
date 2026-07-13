import 'package:file_share_app/features/file_transfer/services/incoming_files.dart';
// A blueprint for an incoming session
class IncomingSession{
  final String sessionId;
  final String senderName;
  final List<IncomingFile> files; // List of the incoming files.
  const IncomingSession({
    required this.sessionId,
    required this.senderName,
    required this.files,
  });
}