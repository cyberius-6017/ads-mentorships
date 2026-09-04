// Prueba básica: el contador empieza en 0 y sube a 1 al presionar
// "Incrementar".

import 'package:flutter_test/flutter_test.dart';

import 'package:session2_scouting_counter/main.dart';

void main() {
  testWidgets('El contador empieza en 0 y sube al presionar Incrementar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Incrementar'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
