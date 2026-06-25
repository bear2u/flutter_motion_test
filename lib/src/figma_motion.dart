import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FigmaMotion {
  FigmaMotion({
    required this.version,
    required this.playbackStyle,
    required List<FigmaMotionNode> nodes,
  }) : nodes = Map.unmodifiable({for (final node in nodes) node.id: node});

  factory FigmaMotion.fromJson(Map<String, Object?> json) {
    return FigmaMotion(
      version: (json['version'] as num?)?.toInt() ?? 1,
      playbackStyle: json['playbackStyle'] as String? ?? 'once',
      nodes: [
        for (final node in (json['nodes'] as List? ?? const []))
          FigmaMotionNode.fromJson(Map<String, Object?>.from(node as Map)),
      ],
    );
  }

  factory FigmaMotion.fromJsonString(String source) {
    return FigmaMotion.fromJson(
      Map<String, Object?>.from(jsonDecode(source) as Map),
    );
  }

  final int version;
  final String playbackStyle;
  final Map<String, FigmaMotionNode> nodes;

  bool get loops => playbackStyle == 'loop';

  int get durationMs {
    var maxMs = 0;
    for (final node in nodes.values) {
      maxMs = math.max(maxMs, node.durationMs);
    }
    return maxMs == 0 ? 1 : maxMs;
  }

  FigmaMotionNode? operator [](String nodeId) => nodes[nodeId];
}

class FigmaMotionNode {
  FigmaMotionNode({
    required this.id,
    required this.timelineDurationMs,
    required List<FigmaMotionField> fields,
  }) : fields = List.unmodifiable(fields);

  factory FigmaMotionNode.fromJson(Map<String, Object?> json) {
    return FigmaMotionNode(
      id: json['node'] as String,
      timelineDurationMs: (json['timelineDurationMs'] as num?)?.toInt() ?? 1,
      fields: [
        for (final field in (json['fields'] as List? ?? const []))
          FigmaMotionField.fromJson(Map<String, Object?>.from(field as Map)),
      ],
    );
  }

  final String id;
  final int timelineDurationMs;
  final List<FigmaMotionField> fields;

  int get durationMs {
    var maxMs = timelineDurationMs;
    for (final field in fields) {
      if (field.keyframes.isNotEmpty) {
        maxMs = math.max(maxMs, field.keyframes.last.timeMs);
      }
    }
    return maxMs;
  }

  double valueFor(String prefix, double timeMs, double fallback) {
    for (final field in fields) {
      if (field.name.startsWith(prefix)) {
        return field.valueAt(timeMs);
      }
    }
    return fallback;
  }
}

class FigmaMotionField {
  FigmaMotionField({required this.name, required List<FigmaKeyframe> keyframes})
    : keyframes = List.unmodifiable(keyframes);

  factory FigmaMotionField.fromJson(Map<String, Object?> json) {
    return FigmaMotionField(
      name: json['field'] as String,
      keyframes: [
        for (final keyframe in (json['keyframes'] as List? ?? const []))
          FigmaKeyframe.fromJson(Map<String, Object?>.from(keyframe as Map)),
      ]..sort((a, b) => a.timeMs.compareTo(b.timeMs)),
    );
  }

  final String name;
  final List<FigmaKeyframe> keyframes;

  double valueAt(double timeMs) {
    if (keyframes.isEmpty) return 0;
    if (timeMs <= keyframes.first.timeMs) return keyframes.first.value;
    if (timeMs >= keyframes.last.timeMs) return keyframes.last.value;

    for (var i = 0; i < keyframes.length - 1; i++) {
      final from = keyframes[i];
      final to = keyframes[i + 1];
      if (timeMs < from.timeMs || timeMs > to.timeMs) continue;
      if (from.hold || from.timeMs == to.timeMs) return from.value;

      final rawT = (timeMs - from.timeMs) / (to.timeMs - from.timeMs);
      final curvedT = from.curve.transform(rawT.clamp(0, 1));
      return from.value + (to.value - from.value) * curvedT;
    }
    return keyframes.last.value;
  }
}

class FigmaKeyframe {
  const FigmaKeyframe({
    required this.timeMs,
    required this.value,
    required this.hold,
    required this.curve,
  });

  factory FigmaKeyframe.fromJson(Map<String, Object?> json) {
    final easing = json['easingToNext'];
    final easingMap = easing is Map ? Map<String, Object?>.from(easing) : null;
    final bezier = easingMap?['bezierValues'];
    final bezierMap = bezier is Map ? Map<String, Object?>.from(bezier) : null;

    return FigmaKeyframe(
      timeMs: (json['timeMs'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toDouble() ?? 0,
      hold: easingMap?['hold'] == true,
      curve: bezierMap == null
          ? Curves.linear
          : Cubic(
              (bezierMap['p1x'] as num).toDouble(),
              (bezierMap['p1y'] as num).toDouble(),
              (bezierMap['p2x'] as num).toDouble(),
              (bezierMap['p2y'] as num).toDouble(),
            ),
    );
  }

  final int timeMs;
  final double value;
  final bool hold;
  final Curve curve;
}

class FigmaMotionWidget extends StatefulWidget {
  const FigmaMotionWidget({
    super.key,
    required this.motion,
    required this.nodeId,
    required this.child,
    this.autoplay = true,
    this.loop,
    this.controller,
    this.alignment = Alignment.center,
  });

  final FigmaMotion motion;
  final String nodeId;
  final Widget child;
  final bool autoplay;
  final bool? loop;
  final AnimationController? controller;
  final Alignment alignment;

  @override
  State<FigmaMotionWidget> createState() => _FigmaMotionWidgetState();
}

class FigmaMotionAsset extends StatelessWidget {
  const FigmaMotionAsset({
    super.key,
    required this.asset,
    required this.builder,
    this.loading,
  });

  final String asset;
  final Widget Function(BuildContext context, FigmaMotion motion) builder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString(asset),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return loading ?? const SizedBox.shrink();
        return builder(context, FigmaMotion.fromJsonString(snapshot.data!));
      },
    );
  }
}

class FigmaMotionScene extends StatefulWidget {
  const FigmaMotionScene({
    super.key,
    required this.motion,
    required this.builder,
    this.autoplay = true,
    this.loop,
  });

  final FigmaMotion motion;
  final bool autoplay;
  final bool? loop;
  final Widget Function(
    BuildContext context,
    FigmaMotion motion,
    AnimationController controller,
  )
  builder;

  @override
  State<FigmaMotionScene> createState() => _FigmaMotionSceneState();
}

class _FigmaMotionSceneState extends State<FigmaMotionScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.motion.durationMs),
    );
    _play();
  }

  @override
  void didUpdateWidget(FigmaMotionScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion.durationMs != widget.motion.durationMs) {
      _controller.duration = Duration(milliseconds: widget.motion.durationMs);
    }
    if (oldWidget.motion != widget.motion ||
        oldWidget.autoplay != widget.autoplay ||
        oldWidget.loop != widget.loop) {
      _controller.stop();
      _play();
    }
  }

  void _play() {
    if (!widget.autoplay) return;
    if (widget.loop ?? widget.motion.loops) {
      _controller.repeat();
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.motion, _controller);
  }
}

class _FigmaMotionWidgetState extends State<FigmaMotionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(FigmaMotionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.motion.durationMs != widget.motion.durationMs) {
      if (_ownsController) _controller.dispose();
      _initController();
    }
  }

  void _initController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.motion.durationMs),
        );
    if (widget.autoplay && _ownsController) {
      if (widget.loop ?? widget.motion.loops) {
        _controller.repeat();
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.motion[widget.nodeId];
    if (node == null) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value * node.durationMs;
        final dx = node.valueFor('motionTranslationX', t, 0);
        final dy = node.valueFor('motionTranslationY', t, 0);
        final scaleX = node.valueFor('motionScaleX', t, 1);
        final scaleY = node.valueFor('motionScaleY', t, 1);
        final rotation = node.valueFor('motionRotation', t, 0);
        final opacity = _opacity(node.valueFor('opacity', t, 100));

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: rotation,
              alignment: widget.alignment,
              child: Transform.scale(
                scaleX: scaleX,
                scaleY: scaleY,
                alignment: widget.alignment,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  double _opacity(double value) {
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0, 1);
  }
}
