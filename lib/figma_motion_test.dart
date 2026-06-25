import 'figma_motion_test_platform_interface.dart';
export 'src/figma_motion.dart';

class FigmaMotionTest {
  Future<String?> getPlatformVersion() {
    return FigmaMotionTestPlatform.instance.getPlatformVersion();
  }
}
