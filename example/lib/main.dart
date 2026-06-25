import 'package:figma_motion_test/figma_motion_test.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MotionJsonExample(),
    );
  }
}

class MotionJsonExample extends StatelessWidget {
  const MotionJsonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef1e9),
      body: Center(
        child: FigmaMotionAsset(
          asset: 'assets/motions/workout_onboarding_motion.json',
          loading: const CircularProgressIndicator(),
          builder: (context, motion) => FigmaMotionScene(
            motion: motion,
            builder: (context, motion, controller) => WorkoutOnboardingPreview(
              motion: motion,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}

class WorkoutOnboardingPreview extends StatelessWidget {
  const WorkoutOnboardingPreview({
    super.key,
    required this.motion,
    required this.controller,
  });

  final FigmaMotion motion;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 390,
        height: 844,
        color: const Color(0xfff6f7f2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _motion('7:2', _box(474, 470, const Color(0xff17382f), radius: 42)),
            _circle(213, 77, 180, const Color(0x4739d98a)),
            _circle(-47, 189, 190, const Color(0x332db88d)),
            const Positioned(
              left: 28,
              top: 56,
              child: Text(
                'MOVEFIT',
                style: TextStyle(
                  color: Color(0xffd7ff79),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Positioned(
              right: 28,
              top: 56,
              child: Text(
                'Skip',
                style: TextStyle(color: Color(0xffd6e8dd), fontSize: 14),
              ),
            ),
            _motion(
              '7:7',
              _circleBox(66, const Color(0xffd7ff79), child: _timerText()),
            ),
            _motion(
              '7:9',
              Transform.rotate(
                angle: -0.052,
                child: _box(238, 30, const Color(0xffb7f34b), radius: 15),
              ),
            ),
            _motion('7:10', _circleBox(48, const Color(0xfff4c7a1))),
            _motion(
              '7:11',
              Transform.rotate(
                angle: -0.14,
                child: _box(84, 112, Colors.white, radius: 28),
              ),
            ),
            _motion('7:12', _limb(88, 18, const Color(0xfff4c7a1), -0.42)),
            _motion('7:13', _limb(88, 18, const Color(0xfff4c7a1), 0.35)),
            _motion('7:14', _limb(112, 22, const Color(0xff202b34), 0.28)),
            _motion('7:15', _limb(112, 22, const Color(0xff202b34), -0.31)),
            _motion('7:16', _limb(44, 18, const Color(0xffff7a59), 0.28)),
            _motion('7:17', _limb(44, 18, const Color(0xffff7a59), -0.31)),
            _motion(
              '7:18',
              _box(342, 334, Colors.white, radius: 30, shadow: true),
            ),
            _positionedMotion('7:19', 50, 492, _eyebrow()),
            _positionedMotion('7:20', 50, 532, _title()),
            _positionedMotion('7:21', 50, 646, _body()),
            _motionChip(
              '7:22',
              '7:23',
              50,
              712,
              92,
              'Strength',
              const Color(0xffeaf8d5),
              const Color(0xff256b3f),
            ),
            _motionChip(
              '7:24',
              '7:25',
              151,
              712,
              78,
              'Cardio',
              const Color(0xffeef6ff),
              const Color(0xff2563eb),
            ),
            _motionChip(
              '7:26',
              '7:27',
              238,
              712,
              78,
              'Habit',
              const Color(0xfffff1e8),
              const Color(0xffc45b31),
            ),
            _positionedMotion(
              '7:28',
              50,
              764,
              _box(290, 56, const Color(0xff17382f), radius: 28),
            ),
            _positionedMotion('7:29', 50, 782, _ctaLabel()),
          ],
        ),
      ),
    );
  }

  Widget _motion(String nodeId, Widget child) {
    return FigmaMotionWidget(
      motion: motion,
      nodeId: nodeId,
      controller: controller,
      child: child,
    );
  }

  Widget _positionedMotion(
    String nodeId,
    double left,
    double top,
    Widget child,
  ) {
    return Positioned(left: left, top: top, child: _motion(nodeId, child));
  }

  Widget _motionChip(
    String chipNode,
    String labelNode,
    double left,
    double top,
    double width,
    String label,
    Color bg,
    Color fg,
  ) {
    return Stack(
      children: [
        _positionedMotion(chipNode, left, top, _box(width, 34, bg, radius: 17)),
        _positionedMotion(
          labelNode,
          left,
          top + 10,
          SizedBox(
            width: width,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _box(
  double width,
  double height,
  Color color, {
  double radius = 0,
  bool shadow = false,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow
          ? const [
              BoxShadow(
                color: Color(0x240d1424),
                blurRadius: 36,
                offset: Offset(0, 18),
                spreadRadius: -10,
              ),
            ]
          : null,
    ),
  );
}

Widget _circle(double left, double top, double size, Color color) {
  return Positioned(left: left, top: top, child: _circleBox(size, color));
}

Widget _circleBox(double size, Color color, {Widget? child}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: child,
  );
}

Widget _limb(double width, double height, Color color, double angle) {
  return Transform.rotate(
    angle: angle,
    child: _box(width, height, color, radius: height / 2),
  );
}

Widget _timerText() {
  return const Text(
    '03',
    style: TextStyle(
      color: Color(0xff17382f),
      fontSize: 20,
      fontWeight: FontWeight.w800,
    ),
  );
}

Widget _eyebrow() {
  return const SizedBox(
    width: 220,
    child: Text(
      'DAY 1 ONBOARDING',
      style: TextStyle(
        color: Color(0xff22a06b),
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

Widget _title() {
  return const SizedBox(
    width: 292,
    child: Text(
      'Build a routine\nthat sticks',
      style: TextStyle(
        color: Color(0xff121a16),
        fontSize: 36,
        height: 1.08,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

Widget _body() {
  return const SizedBox(
    width: 292,
    child: Text(
      'Start with guided warmups and track every small win without clutter.',
      style: TextStyle(color: Color(0xff607069), fontSize: 15, height: 1.32),
    ),
  );
}

Widget _ctaLabel() {
  return const SizedBox(
    width: 290,
    child: Text(
      'Start my first workout',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
