
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_share_app/constants/app_constant.dart';
import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:file_share_app/features/file_transfer/services/outgoing_file.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_tracker.dart';
import 'package:flutter/foundation.dart';

enum SendResult {accepted, declined, failed}
class SendService {
  final Dio _dio = Dio();

  // This function sends file batch to the target Ip and returns the result of the handshake/connection.
  // The receiving device must accept before file bytes are shared.

  Future<SendResult> sendFiles({
    required String targetIp,
    required String senderDeviceName,
    required List<OutgoingFile> files,
    void Function(String fileId, double progress) ? onProgress
  }) async {
    final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final String baseUrl = 'http://$targetIp:${AppConstant.transferPort}';

    for (final file in files) {
      TransferTracker.instance.addItem(TransferItem(
        id: file.fileId, 
        fileName: file.name, 
        mimeType: file.mimeType, 
        totalBytes: file.size, 
        direction: TransferDirection.sent)
        );
    }

    try {
      // This part is the handshake between both device. It blocks on the receiving device end until they either accept or reject.
      final prepareResponse = await _dio.post(
        '$baseUrl/prepare',
        data: {
          'sessionId': sessionId,
          'deviceName': senderDeviceName,
          'files': files.map((f) => f.toJson()).toList(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 35)
        )
      );

      final status = prepareResponse.data['status'] as String?;
      if (status != 'accepted') {
        for (final file in files) {
          TransferTracker.instance.markFailed(file.fileId);
        }
        return SendResult.declined;
      }
      // This is for uploading each file bytes
      for (final file in files) {
        final fileOnDisk = File(file.path);
        if (!await fileOnDisk.exists()) {
          TransferTracker.instance.markFailed(file.fileId);
          continue;
        }

        await _dio.post(
          '$baseUrl/upload',
          queryParameters: {
            'sessionId': sessionId,
            'fileId': file.fileId,
          },
          data: fileOnDisk.openRead(),
          options: Options(
            headers: {
              Headers.contentLengthHeader: file.size,
              Headers.contentTypeHeader: 'application/octet-stream',
            }
          ),
          onSendProgress: (sent, total) {
            TransferTracker.instance.updateProgress(
              file.fileId,
              sent 
            );
          }
        );
        TransferTracker.instance.markDone(file.fileId);
      }
      return SendResult.accepted;
    } on DioException catch(e) {
      debugPrint('Send failed: ${e.message}');
      for (final file in files) {
        TransferTracker.instance.markFailed(file.fileId);
      }
      return SendResult.failed;
    } catch(e) {
      debugPrint('Unexpected send error: $e');
      return SendResult.failed;
    }
  }
}