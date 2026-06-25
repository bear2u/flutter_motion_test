import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:figma_motion_test/figma_motion_test_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFigmaMotionTest platform = MethodChannelFigmaMotionTest();
  const MethodChannel channel = MethodChannel('figma_motion_test');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
