// Pruebas básicas: los dos contadores empiezan en 0, cada botón sube
// SOLO su propio número (aunque los dos sean el mismo widget), y el
// resumen junta los cuatro datos.

import 'package:flutter/material.dart';
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

  testWidgets('El formulario junta los cuatro datos al guardar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    await tester.enterText(find.byType(TextField), '6017');
    await tester.ensureVisible(find.byType(CounterButton).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CounterButton).last); // teleoperado
    await tester.pump();

    // El botón queda fuera de la pantalla en el tamaño del test:
    // scrolleamos hasta él antes de tocarlo.
    await tester.ensureVisible(find.text('Guardar reporte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar reporte'));
    await tester.pumpAndSettle();

    // Buscamos dentro del diálogo: "6017" también está en el campo de
    // texto de atrás, y "Ofensivo" en el dropdown.
    final dialogo = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialogo, matching: find.text('6017')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialogo, matching: find.text('Ofensivo')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialogo, matching: find.text('Teleoperado')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialogo, matching: find.text('Total del match')),
      findsOneWidget,
    );
  });
}
