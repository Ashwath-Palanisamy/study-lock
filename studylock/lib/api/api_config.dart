import 'package:dio/dio.dart';

const _backendApiKey = String.fromEnvironment('STUDYLOCK_API_KEY');

final Dio dioClient = Dio(
  BaseOptions(
    baseUrl: 'https://study-lock-xakx.onrender.com',
    headers: _backendApiKey.isEmpty
        ? const <String, String>{}
        : <String, String>{'X-StudyLock-App-Key': _backendApiKey},
  ),
);
