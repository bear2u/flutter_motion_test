import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'figma_motion_test_method_channel.dart';

abstract class FigmaMotionTestPlatform extends PlatformInterface {
  /// Constructs a FigmaMotionTestPlatform.
  FigmaMotionTestPlatform() : super(token: _token);

  static final Object _token = Object();

  static FigmaMotionTestPlatform _instance = MethodChannelFigmaMotionTest();

  /// The default instance of [FigmaMotionTestPlatform] to use.
  ///
  /// Defaults to [MethodChannelFigmaMotionTest].
  static FigmaMotionTestPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FigmaMotionTestPlatform] when
  /// they register themselves.
  static set instance(FigmaMotionTestPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
