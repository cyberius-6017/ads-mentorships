import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:session6_rest_api/main.dart';

// En las pruebas no vamos a internet: un MockClient contesta en lugar del
// servidor, y http.runWithClient hace que http.get use ese cliente.
final MockClient servidorFalso = MockClient((request) async {
  // Si la app no manda la llave, contestamos como el servidor real.
  if (request.headers['X-Admin-Api-Key'] == null) {
    return http.Response('', 401);
  }
  return http.Response(
    jsonEncode([
      {'number': 6017, 'name': 'PrepaTec - Cyberius'},
      {'number': 4635, 'name': 'PrepaTec - Botbusters'},
    ]),
    200,
  );
});

final MockClient servidorCaido = MockClient((request) async {
  return http.Response('', 500);
});

Future<void> abrirApp(WidgetTester tester, MockClient servidor) async {
  await http.runWithClient(() async {
    await tester.pumpWidget(const MainApp());
  }, () => servidor);
}

void main() {
  testWidgets('Muestra la ruedita y luego los equipos del servidor', (
    WidgetTester tester,
  ) async {
    await abrirApp(tester, servidorFalso);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('PrepaTec - Cyberius'), findsOneWidget);
    expect(find.text('4635'), findsOneWidget);
  });

  testWidgets('Si el servidor falla, se muestra el error', (
    WidgetTester tester,
  ) async {
    await abrirApp(tester, servidorCaido);
    await tester.pumpAndSettle();
    expect(find.textContaining('500'), findsOneWidget);
  });

  testWidgets('Tocar un equipo abre su página con el nombre', (
    WidgetTester tester,
  ) async {
    await abrirApp(tester, servidorFalso);
    await tester.pumpAndSettle();

    await tester.tap(find.text('PrepaTec - Botbusters'));
    await tester.pumpAndSettle();
    expect(find.text('Team 4635'), findsOneWidget);
    expect(find.text('PrepaTec - Botbusters'), findsOneWidget);
  });

  testWidgets('Cambiar de pestaña mientras carga no truena', (
    WidgetTester tester,
  ) async {
    await abrirApp(tester, servidorFalso);
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    expect(find.text('This page is for Pick'), findsOneWidget);
  });
}
