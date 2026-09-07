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
            case 'checkActiveSession':
              return 125;
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

  test('treats a null native accessibility state as disabled', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    expect(await AppBlockerService.isAccessibilityServiceEnabled(), isFalse);
    expect(calls.single.method, 'isAccessibilityServiceEnabled');
  });

  test('returns the remaining active-session seconds', () async {
    expect(await AppBlockerService.checkActiveSession(), 125);
    expect(calls.single.method, 'checkActiveSession');
  });

  test('treats a missing active session as zero seconds', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    expect(await AppBlockerService.checkActiveSession(), 0);
    expect(calls.single.method, 'checkActiveSession');
  });

  test('opens Android accessibility settings', () async {
    await AppBlockerService.openAccessibilitySettings();
    expect(calls.single.method, 'openAccessibilitySettings');
  });

  test('starts blocking with the requested packages', () async {
    await AppBlockerService.startBlocking(['com.example.distraction'], 45);
    expect(calls.single.method, 'startBlocking');
    expect(calls.single.arguments, {
      'restrictedPackages': ['com.example.distraction'],
      'sessionDuration': 45,
    });
  });

  test('stops blocking', () async {
    await AppBlockerService.stopBlocking();
    expect(calls.single.method, 'stopBlocking');
  });
}
