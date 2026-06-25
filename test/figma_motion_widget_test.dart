import 'package:figma_motion_test/figma_motion_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _motionJson = '''
{
  "version": 1,
  "playbackStyle": "loop",
  "nodes": [
    {
      "node": "7:7",
      "timelineDurationMs": 3000,
      "fields": [
        {
          "field": "motionTranslationY@-1:-1",
          "keyframes": [
            {"timeMs": 0, "value": -100, "easingToNext": {"hold": true}},
            {"timeMs": 1000, "value": -100, "easingToNext": {"bezierValues": {"p1x": 0, "p1y": 0, "p2x": 0.58, "p2y": 1}}},
            {"timeMs": 3000, "value": 0}
          ]
        },
        {
          "field": "opacity@-1:-1",
          "keyframes": [
            {"timeMs": 0, "value": 0, "easingToNext": {"hold": true}},
            {"timeMs": 1500, "value": 0, "easingToNext": {"bezierValues": {"p1x": 0, "p1y": 0, "p2x": 0.58, "p2y": 1}}},
            {"timeMs": 3000, "value": 100}
          ]
        }
      ]
    }
  ]
}
''';

void main() {
  test('parses Figma Motion JSON and evaluates keyframes', () {
    final motion = FigmaMotion.fromJsonString(_motionJson);
    final node = motion['7:7']!;

    expect(motion.loops, isTrue);
    expect(motion.durationMs, 3000);
    expect(node.valueFor('motionTranslationY', 500, 0), -100);
    expect(node.valueFor('motionTranslationY', 3000, 0), 0);
    expect(node.valueFor('opacity', 1500, 100), 0);
    expect(node.valueFor('opacity', 3000, 100), 100);
  });

  testWidgets(
    'wraps child in motion transforms without requiring native code',
    (tester) async {
      final motion = FigmaMotion.fromJsonString(_motionJson);

      await tester.pumpWidget(
        MaterialApp(
          home: FigmaMotionWidget(
            motion: motion,
            nodeId: '7:7',
            loop: false,
            child: const SizedBox(width: 10, height: 10),
          ),
        ),
      );

      expect(find.byType(Transform), findsWidgets);
      expect(find.byType(Opacity), findsOneWidget);
    },
  );
}
