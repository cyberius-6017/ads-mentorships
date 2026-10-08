// NUEVO en sesión 4: este archivo completo.
//
// Hasta la sesión 3, el reporte eran cinco variables sueltas regadas en
// el State de la pantalla. Aquí las juntamos en UNA cosa con nombre:
// un MatchReport. Es como pasar de cinco papelitos sueltos a una hoja de
// scouting con sus casillas impresas.
//
// Fíjate que este archivo NO importa Flutter: no dibuja nada. Es Dart
// puro. Un modelo solo sabe QUÉ datos hay, no cómo se ven en pantalla.

// `class` es el molde. Cada vez que alguien llena el formulario y toca
// "Guardar", con este molde se fabrica un objeto nuevo: un reporte.
class MatchReport {
  // Las casillas de la hoja, una por cada campo del formulario.
  //
  // `final` = se llenan UNA vez, al crear el reporte, y ya no cambian.
  // Un reporte guardado no debería poder editarse por accidente; si hay
  // un error, se hace un reporte nuevo.
  final int teamNumber; // el equipo que scouteamos, ej. 6017
  final String matchNumber; // la clave completa del match, ej. 2026cc_qm67
  final String role; // Ofensivo, Defensivo o Soporte
  final int autoPoints; // elementos anotados en autónomo
  final int teleopPoints; // elementos anotados en teleoperado

  // El constructor: la función que fabrica un reporte.
  //
  // Las llaves { } hacen que los parámetros sean NOMBRADOS: al usarlo se
  // escribe `teamNumber: 6017` y no solo `6017`. Con cinco datos, dos de
  // ellos números, es muy fácil confundir el orden; con nombres, no.
  //
  // `required` es el mismo del CounterButton de la sesión 3: si se te
  // olvida un dato, el editor lo marca en rojo antes de correr la app.
  //
  // `this.teamNumber` = "lo que me pasen, guárdalo directo en mi casilla
  // teamNumber". Ahorra escribir la asignación a mano.
  const MatchReport({
    required this.teamNumber,
    required this.matchNumber,
    required this.role,
    required this.autoPoints,
    required this.teleopPoints,
  });

  // toString() decide qué texto sale cuando convertimos el objeto en
  // String, por ejemplo con print(reporte) o con '$reporte'.
  //
  // Todas las clases de Dart ya traen uno, pero el de fábrica solo dice
  // "Instance of 'MatchReport'", que no sirve de nada. `@override`
  // significa "reemplazo el de fábrica por el mío".
  @override
  String toString() {
    // Varios textos uno junto al otro se pegan en uno solo. El \n es un
    // salto de línea.
    return 'Match $matchNumber\n'
        'Equipo: $teamNumber\n'
        'Rol: $role\n'
        'Autónomo: $autoPoints\n'
        'Teleoperado: $teleopPoints';
  }
}
