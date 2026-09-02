import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';

class AiFunctions {
  Future<String> uploadfile(PlatformFile uploadfile) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          uploadfile.path!,
          filename: uploadfile.name,
        ),
      });

      final response = await dioClient.post('/upload-file', data: formData);

      return response.data['file_uri'];
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError during upload: ${e.message}');
      }
      return 'file upload error. Please try again';
    }
  }

  Stream<String> chatAPI(String fileUri, String message) async* {
    try {
      final response = await dioClient.post(
        '/chat',
        queryParameters: {'file_uri': fileUri, 'question': message},
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      ResponseBody responseBody = response.data;
      
      await for (var chunk in responseBody.stream) {
        yield utf8.decode(chunk);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError when sending Chat message: ${e.message}');
      }

      yield 'Can\'t able to send chat. Check your network connection';
    }
  }

  Future<Map<String, dynamic>> getMcqs(String fileUri) async {
    try {
      final response = await dioClient.post(
        '/mcq-ai',
        queryParameters: {'file_uri': fileUri},
      );

      if (response.data == null) {
        throw Exception('Server returned an empty response.');
      }

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError during MCQ generation: ${e.message}');
      }
      throw Exception('Failed to generate MCQs: ${e.message}');
    }
  }
}