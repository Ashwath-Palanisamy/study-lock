import 'package:flutter_test/flutter_test.dart';
import 'package:studylock/api/api_config.dart';

void main() {
  test('configures the StudyLock backend URL', () {
    expect(dioClient.options.baseUrl, 'https://study-lock-xakx.onrender.com');
  });

  test('does not ship an API key in default test builds', () {
    expect(dioClient.options.headers.containsKey('X-StudyLock-App-Key'), isFalse);
  });
}
