import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_figma_motion_example/main.dart';

void main() {
  testWidgets('loads the Figma Motion JSON sample', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MOVEFIT'), findsOneWidget);
    expect(find.text('Build a routine\nthat sticks'), findsOneWidget);
    expect(find.text('Start my first workout'), findsOneWidget);
  });
}
