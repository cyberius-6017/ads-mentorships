// Prueba básica de widget: solo verifica que la app arranca correctamente
// y que el widget raíz (DiamondApp) se construye sin errores.
//
// Como esta app no tiene interacción ni estado (a diferencia de la app de
// ejemplo "contador" que trae Flutter por defecto), no hay nada más que
// probar aquí: no hay botones que tocar ni texto que cambie.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:i_am_rich/main.dart';

void main() {
  testWidgets('La app muestra la imagen del diamante', (
    WidgetTester tester,
  ) async {
    // Construye la app y dispara un primer "frame" (cuadro de renderizado).
    await tester.pumpWidget(const DiamondApp());

    // Verifica que exista exactamente un widget Image en la pantalla:
    // el diamante.
    expect(find.byType(Image), findsOneWidget);
  });
}
