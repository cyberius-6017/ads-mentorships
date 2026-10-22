// NUEVO: este archivo es el único que habla con internet. Si algún día
// cambia la dirección del servidor o la llave, solo se cambia aquí.

// dart:convert trae jsonDecode, que convierte el texto JSON en listas y
// Maps de Dart.
import 'dart:convert';

// El paquete http (de pub.dev) sabe hacer peticiones a internet.
// "as http" le pone apellido: todo lo que viene de él se escribe
// http.algo, y así se nota qué cosas vienen del paquete.
import 'package:http/http.dart' as http;

// La dirección (URL) del "endpoint": la ventanilla del servidor que
// entrega la lista de equipos. Es la misma que en el curl.
const String kTeamsUrl = 'https://scout.team6017.com/api/v1/teams/';

// La llave de la API. El servidor solo contesta si se la mandamos en un
// header; sin ella responde 401 (no autorizado).
const String kApiKey = 'ZoU_soVC3b2nn31zO5VwXJGQAxgCBDNdY2KS-rrSS1U';

// Pide al servidor la lista de equipos.
//
// NUEVO: async y Future. Pedir algo a internet tarda (a veces un
// segundo, a veces más) y la app no se puede congelar mientras tanto.
// - async: esta función puede "esperar" sin trabar la app.
// - Future<List<dynamic>>: una promesa de que, más tarde, llegará una
//   lista.
// - await: "espera aquí a que llegue la respuesta y luego sigue".
Future<List<dynamic>> fetchTeams() async {
  // El GET: "dame lo que hay en esta dirección". Es el mismo curl de la
  // terminal, escrito en Dart:
  //   curl -X 'GET' '<url>' -H 'accept: */*' -H 'X-Admin-Api-Key: <llave>'
  final http.Response response = await http.get(
    // Uri.parse convierte el texto de la dirección en una Uri, que es lo
    // que pide http.get.
    Uri.parse(kTeamsUrl),
    // Los headers son datos extra de la petición; cada -H del curl es
    // una pareja aquí.
    headers: {'accept': '*/*', 'X-Admin-Api-Key': kApiKey},
  );

  // El status code dice cómo le fue a la petición: 200 = todo bien.
  // Cualquier otro (401 llave mala, 404 no existe, 500 el servidor
  // falló) lo convertimos en un error para que la pantalla lo muestre.
  if (response.statusCode != 200) {
    throw Exception('El servidor respondió ${response.statusCode}');
  }

  // response.body es el JSON como texto: '[{"number":6017,...}, ...]'.
  // jsonDecode lo convierte en una List de Maps de Dart.
  return jsonDecode(response.body);
}
