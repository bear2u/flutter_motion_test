import 'package:flutter_test/flutter_test.dart';
import 'package:figma_motion_test/figma_motion_test.dart';
import 'package:figma_motion_test/figma_motion_test_platform_interface.dart';
import 'package:figma_motion_test/figma_motion_test_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFigmaMotionTestPlatform
    with MockPlatformInterfaceMixin
    implements FigmaMotionTestPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FigmaMotionTestPlatform initialPlatform =
      FigmaMotionTestPlatform.instance;

  test('$MethodChannelFigmaMotionTest is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFigmaMotionTest>());
  });

  test('getPlatformVersion', () async {
    FigmaMotionTest figmaMotionTestPlugin = FigmaMotionTest();
    MockFigmaMotionTestPlatform fakePlatform = MockFigmaMotionTestPlatform();
    FigmaMotionTestPlatform.instance = fakePlatform;

    expect(await figmaMotionTestPlugin.getPlatformVersion(), '42');
  });
}
