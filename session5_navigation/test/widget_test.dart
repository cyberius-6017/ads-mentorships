import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:session5_navigation/main.dart';

void main() {
  testWidgets('La navbar cambia de página', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('Nuevo reporte'), findsOneWidget);

    await tester.tap(find.text('Picklist'));
    await tester.pump();
    expect(find.text('Armar picklist'), findsOneWidget);
    expect(find.text('Nuevo reporte'), findsNothing);
  });

  testWidgets('Ver un equipo abre su página y la flecha regresa', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('Teams'));
    await tester.pump();
    expect(find.text('Cyberius'), findsOneWidget);

    await tester.tap(find.text('Ver').first);
    // A media animación el Hero no debe lanzar errores.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(find.text('6017'), findsOneWidget);
    expect(find.text('Cyberius'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Ver'), findsWidgets);
  });

  testWidgets('El buscador filtra por número o nombre', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('Teams'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'poofs');
    await tester.pump();
    expect(find.text('The Cheesy Poofs'), findsOneWidget);
    expect(find.text('Cyberius'), findsNothing);

    await tester.enterText(find.byType(TextField), '6017');
    await tester.pump();
    expect(find.text('Cyberius'), findsOneWidget);
    expect(find.text('Ver'), findsOneWidget);
  });

  testWidgets('El timer mide cuánto se mantuvo presionado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('Teams'));
    await tester.pump();
    await tester.tap(find.text('Ver').first);
    await tester.pumpAndSettle();
    expect(find.text('0.0 s'), findsOneWidget);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Mantén presionado')),
    );
    await gesture.up();
    await tester.pump();
    expect(find.textContaining(' s'), findsOneWidget);
  });
}
