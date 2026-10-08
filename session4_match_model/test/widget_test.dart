// Pruebas básicas: cada botón sube SOLO su propio contador (igual que en
// la sesión 3), "Guardar" no imprime nada si falta un dato, y con todo
// completo imprime el reporte con la clave del match ya armada.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:session4_match_model/main.dart';
import 'package:session4_match_model/widgets/counter_button.dart';

void main() {
  testWidgets('Cada botón sube su propio contador', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    // Los dos contadores y el total arrancan en 0.
    expect(find.text('0'), findsNWidgets(3));

    // El primer CounterButton de la pantalla es el de autónomo. Con el
    // campo nuevo del match ya no cabe en la pantalla del test, así que
    // scrolleamos hasta él antes de tocarlo.
    await tester.ensureVisible(find.byType(CounterButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CounterButton).first);
    await tester.pump();

    // Sube uno solo: el otro contador es otra variable del State.
    expect(find.text('1'), findsNWidgets(2)); // autónomo y el total
    expect(find.text('0'), findsOneWidget); // teleoperado sigue en 0
  });

  testWidgets('Si falta un dato, avisa y no imprime nada', (
    WidgetTester tester,
  ) async {
    // Atrapamos lo que imprime debugPrint en una lista.
    final DebugPrintCallback original = debugPrint;
    final List<String> impreso = [];
    debugPrint = (String? mensaje, {int? wrapWidth}) => impreso.add('$mensaje');

    await tester.pumpWidget(const MainApp());

    // El botón queda fuera de la pantalla en el tamaño del test:
    // scrolleamos hasta él antes de tocarlo.
    await tester.ensureVisible(find.text('Guardar reporte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar reporte'));
    await tester.pumpAndSettle();

    // Avisa del PRIMER campo que falta, y no se imprimió ningún reporte.
    expect(find.text('Faltan datos'), findsOneWidget);
    expect(find.text('Escribe el número de equipo'), findsOneWidget);
    expect(impreso, isEmpty);

    debugPrint = original;
  });

  testWidgets('Con todo completo, imprime el reporte', (
    WidgetTester tester,
  ) async {
    final DebugPrintCallback original = debugPrint;
    final List<String> impreso = [];
    debugPrint = (String? mensaje, {int? wrapWidth}) => impreso.add('$mensaje');

    await tester.pumpWidget(const MainApp());

    // Dos TextField: el primero es el equipo, el segundo el match.
    await tester.enterText(find.byType(TextField).first, '6017');
    await tester.enterText(find.byType(TextField).last, '67');

    // Abrimos el dropdown y elegimos un rol. `.last` porque el menú
    // abierto dibuja las opciones encima de la caja.
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Defensivo').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(CounterButton).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CounterButton).last); // teleoperado
    await tester.pump();

    await tester.ensureVisible(find.text('Guardar reporte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar reporte'));
    await tester.pumpAndSettle();

    debugPrint = original;

    // Sin aviso de error, y se imprimió el toString() del reporte, con
    // la clave del match completa aunque solo escribimos '67'.
    expect(find.text('Faltan datos'), findsNothing);
    expect(impreso, hasLength(1));
    expect(impreso.first, contains('Match 2026cc_qm67'));
    expect(impreso.first, contains('Equipo: 6017'));
    expect(impreso.first, contains('Rol: Defensivo'));
    expect(impreso.first, contains('Teleoperado: 1'));
  });
}
