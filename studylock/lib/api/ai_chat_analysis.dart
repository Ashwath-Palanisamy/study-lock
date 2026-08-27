import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';

class AiChatAnalysis {
  Future<String> uploadfile(PlatformFile uploadfile) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          uploadfile.path!,
          filename: uploadfile.name,
        ),
      });

      final response = await dioClient.post('/upload-pdf', data: formData);

      // Extract and return the file_uri sent by backend
      return response.data['file_uri'];
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError during upload: ${e.message}');
      }
      return 'file upload error. Please try again';
    }
  }

  Future<String> chat(String fileUri, String message) async {
    try {
      final response = await dioClient.post(
        '/chat',
        data: {'file_uri': fileUri, 'question': message},
      );

      // Extract and return ai response
      return response.data['answer'];
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError when sending Chat message: ${e.message}');
      }

      return 'Can\'t able to send chat. Check your network connection';
    }
  }
}
