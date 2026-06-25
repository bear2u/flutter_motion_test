# figma_motion_test

Play Figma Motion Dev Mode JSON with Flutter widgets.

This package does not generate Flutter UI from Figma. It reads the Motion JSON
export and applies the animation tracks to Flutter widgets you already built.

## What It Does

- Parses Figma Motion Dev Mode JSON.
- Maps Figma node IDs to Flutter widgets.
- Applies translation, scale, rotation, and opacity.
- Shares one timeline controller across many animated layers.
- Supports looping via `playbackStyle: "loop"`.
- Uses Figma cubic bezier values as Flutter `Cubic` curves.

## Basic Usage

Add the Motion JSON file to your app assets:

```yaml
flutter:
  assets:
    - assets/motions/workout_onboarding_motion.json
```

Load the JSON and build a scene:

```dart
FigmaMotionAsset(
  asset: 'assets/motions/workout_onboarding_motion.json',
  builder: (context, motion) {
    return FigmaMotionScene(
      motion: motion,
      builder: (context, motion, controller) {
        return Stack(
          children: [
            FigmaMotionWidget(
              motion: motion,
              nodeId: '7:18',
              controller: controller,
              child: const OnboardingCard(),
            ),
            FigmaMotionWidget(
              motion: motion,
              nodeId: '7:20',
              controller: controller,
              child: const OnboardingTitle(),
            ),
          ],
        );
      },
    );
  },
)
```

## Recommended App Structure

Use the package at the screen level, usually inside a `Scaffold`.

```dart
Scaffold(
  body: FigmaMotionAsset(
    asset: 'assets/motions/intro_motion.json',
    loading: const CircularProgressIndicator(),
    builder: (context, motion) {
      return FigmaMotionScene(
        motion: motion,
        builder: (context, motion, controller) {
          return SizedBox(
            width: 390,
            height: 844,
            child: Stack(
              children: [
                FigmaMotionWidget(
                  motion: motion,
                  nodeId: 'hero-card-node-id',
                  controller: controller,
                  child: const HeroCard(),
                ),
                FigmaMotionWidget(
                  motion: motion,
                  nodeId: 'cta-node-id',
                  controller: controller,
                  child: const StartButton(),
                ),
              ],
            ),
          );
        },
      );
    },
  ),
)
```

`FigmaMotionScene` owns one `AnimationController`. Pass that same controller to
every `FigmaMotionWidget` in the scene so all layers stay synchronized.

## API

### `FigmaMotion`

Parsed representation of the Figma Motion JSON.

```dart
final motion = FigmaMotion.fromJsonString(jsonString);
```

You can also parse a decoded map:

```dart
final motion = FigmaMotion.fromJson(jsonMap);
```

### `FigmaMotionAsset`

Loads a JSON asset and gives you a parsed `FigmaMotion`.

```dart
FigmaMotionAsset(
  asset: 'assets/motions/intro_motion.json',
  loading: const SizedBox.shrink(),
  builder: (context, motion) => YourScene(motion: motion),
)
```

### `FigmaMotionScene`

Creates a shared timeline controller for a full motion scene.

```dart
FigmaMotionScene(
  motion: motion,
  loop: true,
  builder: (context, motion, controller) {
    return YourAnimatedLayout(controller: controller);
  },
)
```

If `loop` is not provided, the scene follows `playbackStyle` from the JSON.

### `FigmaMotionWidget`

Applies one Figma node's motion tracks to one Flutter child.

```dart
FigmaMotionWidget(
  motion: motion,
  nodeId: '7:20',
  controller: controller,
  child: const Text('Build a routine'),
)
```

If the node ID does not exist in the JSON, the child is returned unchanged.

## Supported Figma Fields

The current runtime supports these Figma Motion fields:

| Figma JSON field | Flutter mapping |
| --- | --- |
| `motionTranslationX` | `Transform.translate(dx: ...)` |
| `motionTranslationY` | `Transform.translate(dy: ...)` |
| `motionScaleX` | `Transform.scale(scaleX: ...)` |
| `motionScaleY` | `Transform.scale(scaleY: ...)` |
| `motionRotation` | `Transform.rotate(angle: ...)` |
| `opacity` | `Opacity(opacity: ...)` |

Supported easing:

- `easingToNext.hold`
- `easingToNext.bezierValues`

Supported playback:

- one-shot playback
- loop playback with `playbackStyle: "loop"`

## Not Supported Yet

These can be added, but they need real Figma Motion JSON examples so the field
names and value formats are known:

- color animation
- width/height animation
- blur animation
- shadow animation
- path trim animation
- shader property animation
- automatic Flutter UI generation from Figma node IDs

## How Node Mapping Works

Figma Motion JSON references nodes by ID:

```json
{
  "node": "7:20",
  "fields": [
    {
      "field": "opacity@-1:-1",
      "keyframes": []
    }
  ]
}
```

Your Flutter code must wrap the matching widget with the same `nodeId`:

```dart
FigmaMotionWidget(
  motion: motion,
  nodeId: '7:20',
  controller: controller,
  child: const Text('Build a routine'),
)
```

The package intentionally does not guess which Flutter widget belongs to which
Figma node. Keep that mapping explicit.

## Example

The bundled example app loads:

[example/assets/motions/workout_onboarding_motion.json](example/assets/motions/workout_onboarding_motion.json)

Run it with:

```bash
cd example
flutter run
```

The example builds a workout onboarding screen and applies the JSON animation
tracks to multiple Flutter widgets using one shared scene controller.

## Extending Field Support

Add new fields in `lib/src/figma_motion.dart`.

The usual flow is:

1. Export a Figma Motion JSON that contains the new animated property.
2. Check the field name, for example `motionTranslationX@-1:-1`.
3. Add a value lookup in `FigmaMotionWidget`.
4. Map it to the closest Flutter primitive.

Examples:

- Color fields can use `ColorTween`.
- Blur fields can use `ImageFiltered.blur`.
- Shadow fields can use `BoxShadow.lerp`.
- Path trim needs a `CustomPainter`.

Keep support field-driven. Do not add guessed fields without a real JSON sample.
