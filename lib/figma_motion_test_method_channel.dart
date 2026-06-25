import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'figma_motion_test_platform_interface.dart';

/// An implementation of [FigmaMotionTestPlatform] that uses method channels.
class MethodChannelFigmaMotionTest extends FigmaMotionTestPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('figma_motion_test');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
