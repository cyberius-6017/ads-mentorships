// Prueba básica: los dos contadores empiezan en 0 y cada botón sube
// SOLO su propio número (aunque los dos sean el mismo widget).

import 'package:flutter_test/flutter_test.dart';

import 'package:session3_match_scouting_form/main.dart';
import 'package:session3_match_scouting_form/widgets/counter_button.dart';

void main() {
  testWidgets('Cada botón sube su propio contador', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    // Los dos contadores y el total arrancan en 0.
    expect(find.text('0'), findsNWidgets(3));

    // El primer CounterButton de la pantalla es el de autónomo.
    await tester.tap(find.byType(CounterButton).first);
    await tester.pump();

    // Sube uno solo: el otro contador es otra variable del State.
    expect(find.text('1'), findsNWidgets(2)); // autónomo y el total
    expect(find.text('0'), findsOneWidget); // teleoperado sigue en 0
  });
}
