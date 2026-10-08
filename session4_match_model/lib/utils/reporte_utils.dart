import 'package:flutter/material.dart';

// Nuestro primer paquete de pub.dev, la "tienda" de código de Dart. Se
// instaló con `flutter pub add awesome_snackbar_content`, que lo anotó en
// el pubspec.yaml. Trae los avisos de colores que salen cuando falta un
// dato.
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// NUEVO en sesión 4: este archivo completo.
//
// Aquí van las funciones "de ayuda" de guardar el reporte: revisar qué
// falta y avisarle al scouter. Son la misma idea que sacar el botón a
// counter_button.dart en la sesión 3: main.dart se queda más corto y cada
// archivo hace una sola cosa.
//
// Ojo: _guardar() NO vive aquí. Usa setState() y los controllers, y esas
// dos cosas solo existen adentro del State de la pantalla.

// Revisa los datos del formulario y regresa el mensaje del PRIMER campo
// que falta, o null si no falta nada.
//
// `String?` (con signo de pregunta) porque a veces no hay nada que decir:
// si todo está completo, regresa null.
//
// Recibe los datos ya leídos (textos y el rol), no los controllers: así
// esta función no necesita saber nada de la pantalla.
String? campoQueFalta({
  required String equipo,
  required String match,
  required String? rol,
}) {
  // Un `if` por campo, en el mismo orden en que aparecen en pantalla.
  // `return` termina la función AHÍ MISMO: si falta el equipo, ni
  // siquiera revisamos lo demás.
  if (equipo.isEmpty) {
    return 'Escribe el número de equipo';
  }
  if (match.isEmpty) {
    return 'Escribe el número de match';
  }
  if (rol == null) {
    return 'Elige el rol del robot';
  }
  // Si llegamos hasta aquí, no falta nada.
  return null;
}

// Muestra el aviso rojo de "Faltan datos" con el mensaje que le pasemos.
//
// ¿Por qué pide `context`? Adentro del State, `context` ya estaba ahí
// solito. Este archivo no es una pantalla, así que no sabe EN QUÉ
// pantalla mostrar el aviso: quien lo llama se lo tiene que pasar.
void avisarQueFalta(BuildContext context, String mensaje) {
  // Así recomienda usarlo el paquete: un SnackBar normal de Flutter, pero
  // invisible (transparente, sin sombra) y flotando, con el diseño del
  // paquete adentro como contenido.
  final SnackBar snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: AwesomeSnackbarContent(
      title: 'Faltan datos',
      message: mensaje,
      // failure = rojo con ícono de error. También existen success,
      // warning y help.
      contentType: ContentType.failure,
    ),
  );

  // ScaffoldMessenger es el que muestra los SnackBar en pantalla.
  // Los dos puntos (..) son "y luego, sobre el mismo objeto":
  //   ..hideCurrentSnackBar() -> quita el aviso anterior, si hay uno
  //   ..showSnackBar()        -> muestra el nuevo
  // Sin lo primero, tocar "Guardar" cinco veces pone cinco avisos en
  // fila, uno detrás de otro.
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
