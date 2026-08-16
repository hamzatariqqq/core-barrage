import 'package:flutter_test/flutter_test.dart';
import 'package:core_barrage/main.dart';

void main() {
  testWidgets('Core Barrage app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CoreBarrageApp());

    expect(find.byType(CoreBarrageApp), findsOneWidget);
  });
}