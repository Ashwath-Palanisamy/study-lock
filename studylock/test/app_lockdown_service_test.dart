import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylock/services/app_lockdown_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.studylock/blocker');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
          return true;
        case 'openAccessibilitySettings':
        case 'stopBlocking':
          return null;
        case 'startBlocking':
          return true;
        default:
          throw PlatformException(code: 'not-implemented');
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('checks the native accessibility service state', () async {
    expect(await AppBlockerService.isAccessibilityServiceEnabled(), isTrue);
    expect(calls.single.method, 'isAccessibilityServiceEnabled');
  });

  test('opens Android accessibility settings', () async {
    await AppBlockerService.openAccessibilitySettings();
    expect(calls.single.method, 'openAccessibilitySettings');
  });

  test('starts blocking with the requested packages', () async {
    await AppBlockerService.startBlocking(['com.example.distraction']);
    expect(calls.single.method, 'startBlocking');
    expect(
      calls.single.arguments,
      {'restrictedPackages': ['com.example.distraction']},
    );
  });

  test('stops blocking', () async {
    await AppBlockerService.stopBlocking();
    expect(calls.single.method, 'stopBlocking');
  });
}
