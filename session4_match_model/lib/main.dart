import 'package:flutter/material.dart';
// NUEVO en sesión 4: services.dart trae los "filtros" de teclado
// (FilteringTextInputFormatter), para que en los campos de número solo
// se puedan escribir dígitos.
import 'package:flutter/services.dart';

// Importamos NUESTRO propio widget. Igual que 'package:flutter/material.dart'
// trae widgets que escribió el equipo de Flutter, esta línea trae el widget
// que escribimos nosotros en lib/widgets/counter_button.dart.
// El nombre 'session4_match_model' es el `name:` del pubspec.yaml.
import 'package:session4_match_model/widgets/counter_button.dart';
// Los colores del equipo, los botones naranja y azul, y el estilo de las
// cajas del formulario (lib/widgets/estilos.dart).
import 'package:session4_match_model/widgets/estilos.dart';
// NUEVO en sesión 4: el molde del reporte (lib/models/match_report.dart).
import 'package:session4_match_model/models/match_report.dart';
// NUEVO en sesión 4: las funciones de ayuda para guardar (revisar qué
// falta y mostrar el aviso), en lib/utils/reporte_utils.dart.
import 'package:session4_match_model/utils/reporte_utils.dart';

// NUEVO en sesión 4: la clave del evento, como la usa The Blue Alliance
// (año + código del evento). El scouter solo escribe el número de la
// qualification (67) y la app arma la clave completa: 2026cc_qm67.
// Cambia en cada competencia, por eso vive aquí arriba: un solo lugar
// que editar.
const String kEvento = '2026cc';

// Punto de entrada: lo primero que corre en toda app Flutter.
void main() {
  runApp(const MainApp());
}

// MainApp sigue siendo Stateless, igual que en las sesiones 1 y 2:
// solo arma el MaterialApp y no recuerda nada.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scouting de Match',
      debugShowCheckedModeBanner: false,
      home: const MatchScoutingScreen(),
    );
  }
}

// Esta pantalla es Stateful porque tiene varias cosas que recordar
// mientras el scouter llena el formulario:
//   1. el número de equipo que está escribiendo (NUEVO en sesión 4)
//   2. el número de match (NUEVO en sesión 4)
//   3. el rol que eligió en el dropdown
//   4. cuántos elementos anotó en autónomo
//   5. cuántos anotó en teleoperado
//
// Importante: todos los datos viven AQUÍ, en la pantalla papá. Ninguno
// vive adentro del botón ni adentro del dropdown. Esa es la idea grande
// de la sesión y se llama "lifting state up" (subir el estado): el dato
// vive en el widget más arriba que necesite leerlo.
class MatchScoutingScreen extends StatefulWidget {
  const MatchScoutingScreen({super.key});

  @override
  State<MatchScoutingScreen> createState() => _MatchScoutingScreenState();
}

class _MatchScoutingScreenState extends State<MatchScoutingScreen> {
  // ---------------------------------------------------------------
  // 1) EL CONTROLLER DEL CAMPO DE TEXTO
  // ---------------------------------------------------------------
  // NUEVO en sesión 4: en la sesión 3 el TextField no tenía controller.
  //
  // Un TextField dibuja la cajita, pero por sí solo no nos deja LEER lo
  // que el usuario escribió. El TextEditingController es el que guarda
  // ese texto y nos lo presta cuando lo pedimos con `.text`.
  //
  // Es exactamente la misma idea del StatefulWidget de la sesión 2:
  // alguien tiene que RECORDAR algo entre un build y el siguiente. El
  // contador lo recuerda en una variable `int`; el campo de texto lo
  // recuerda en este controller.
  //
  // `final` porque el controller en sí nunca se cambia por otro; lo que
  // cambia es el texto que tiene adentro.
  final TextEditingController _equipoController = TextEditingController();

  // NUEVO en sesión 4: un segundo campo de texto = un segundo
  // controller. La regla es una cajita, un controller; cada uno guarda
  // su propio texto.
  final TextEditingController _matchController = TextEditingController();

  // ---------------------------------------------------------------
  // 2) EL VALOR DEL DROPDOWN
  // ---------------------------------------------------------------
  // La lista de opciones del menú. Es `const` porque nunca cambia: son
  // siempre los mismos tres roles.
  static const List<String> _roles = ['Ofensivo', 'Defensivo', 'Soporte'];

  // El rol que está seleccionado AHORA MISMO.
  // Igual que el contador: es una variable del State, no del Widget.
  //
  // NUEVO en sesión 4: en la sesión 3 empezaba en 'Ofensivo'. Ahora es
  // `String?` (con signo de pregunta = puede ser nulo) y empieza en null:
  // nadie ha elegido rol todavía. Así, si el scouter se olvida de
  // elegirlo, nos damos cuenta al guardar, en vez de mandar un
  // 'Ofensivo' que nadie escogió.
  String? _rolSeleccionado;

  // ---------------------------------------------------------------
  // 3) LOS DOS CONTADORES
  // ---------------------------------------------------------------
  // Dos variables distintas, cada una con su propio número. Las van a
  // mover dos botones que son EL MISMO widget (CounterButton), solo que
  // con distinto label y distinto callback.
  int _puntosAutonomo = 0;
  int _puntosTeleoperado = 0;

  // NUEVO en sesión 4: dispose(). En la sesión 3 no hacía falta porque
  // no había ningún controller que liberar.
  //
  // dispose() corre cuando esta pantalla se destruye (por ejemplo, si
  // navegamos a otra pantalla o cerramos la app). Es el "apaga la luz
  // al salir" de Flutter.
  //
  // El controller reserva memoria y se queda escuchando el teclado. Si
  // no lo liberamos, esa memoria sigue ocupada aunque la pantalla ya no
  // exista: eso es una fuga de memoria (memory leak). En una app
  // chiquita no se nota; en una app de scouting que abre y cierra la
  // pantalla en cada match, sí.
  //
  // Regla simple para recordar: TODO controller que creas, lo liberas
  // en dispose().
  @override
  void dispose() {
    _equipoController.dispose();
    _matchController.dispose(); // NUEVO en sesión 4: su controller, su dispose
    // super.dispose() al final: primero limpiamos lo nuestro, después
    // dejamos que Flutter limpie lo suyo.
    super.dispose();
  }

  // Estas dos funciones son las que le vamos a PRESTAR a los botones.
  // El botón no sabe qué hacen; solo las llama cuando lo tocan.
  void _incrementarAutonomo() {
    // setState() otra vez: sin él, el número sube en memoria pero la
    // pantalla se queda congelada. Es el mismo bug de la sesión 2.
    setState(() {
      _puntosAutonomo++;
    });
  }

  void _incrementarTeleoperado() {
    setState(() {
      _puntosTeleoperado++;
    });
  }

  // NUEVO en sesión 4: en la sesión 3, _guardar() estaba vacía. Ahora
  // hace dos cosas, en orden:
  //   1. REVISA que no falte nada (si falta algo, avisa y se detiene);
  //   2. ARMA un MatchReport con los datos y lo imprime.
  // Las dos funciones de ayuda (campoQueFalta y avisarQueFalta) viven en
  // lib/utils/reporte_utils.dart.
  void _guardar() {
    // Baja el teclado: si no, el aviso queda escondido detrás de él.
    FocusScope.of(context).unfocus();

    // --- 1) VALIDAR -----------------------------------------------
    // Le pasamos los datos a campoQueFalta() y nos dice qué falta, o
    // null si está todo.
    final String? falta = campoQueFalta(
      equipo: _equipoController.text,
      match: _matchController.text,
      rol: _rolSeleccionado,
    );
    // Si algo falta: avisamos y `return` termina _guardar() aquí mismo.
    // Nunca se llega a crear el reporte.
    if (falta != null) {
      avisarQueFalta(context, falta);
      return;
    }

    // --- 2) GUARDAR -----------------------------------------------
    // Si llegamos hasta aquí, no falta nada. Fabricamos el reporte con
    // el molde de lib/models/match_report.dart.
    final MatchReport reporte = MatchReport(
      // El TextField nos da texto ('6017'), pero el modelo pide un int.
      // int.parse() convierte el texto en número. No puede fallar porque
      // el campo solo deja escribir dígitos (ver el TextField de abajo).
      teamNumber: int.parse(_equipoController.text),
      // El scouter escribió solo '67'; aquí le pegamos lo que falta
      // para formar la clave completa: '2026cc' + '_qm' + '67'.
      matchNumber: '${kEvento}_qm${_matchController.text}',
      // El `!` le dice a Dart "ya revisé que no es null". Dart no puede
      // saberlo solo, porque la revisión pasó en OTRA función
      // (campoQueFalta), pero es verdad: si fuera null, ya nos habríamos
      // salido con el `return` de arriba.
      role: _rolSeleccionado!,
      autoPoints: _puntosAutonomo,
      teleopPoints: _puntosTeleoperado,
    );

    // Imprimimos el reporte en la terminal donde corre `flutter run`.
    // '$reporte' convierte el objeto en texto usando SU toString().
    // Sin el toString() de MatchReport, aquí saldría solo
    // "Instance of 'MatchReport'".
    debugPrint('$reporte');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondo,
      // SingleChildScrollView: cuando el teclado se abre para escribir el
      // número de equipo, la pantalla se hace "más chica" y el contenido
      // ya no cabe. Sin esto, Flutter pinta la franja amarilla y negra de
      // "overflow". Con esto, simplemente se puede scrollear.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------------------------------------------
            // ENCABEZADO
            // ---------------------------------------------------
            // No usamos AppBar: un bloque azul con las esquinas de abajo
            // redondeadas se parece más a la portada del sitio del
            // equipo, y deja espacio para explicar qué hace la pantalla.
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              decoration: const BoxDecoration(
                color: kAzul,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              // SafeArea: en celulares con "notch" o cámara al frente,
              // empuja el contenido para que el título no quede tapado.
              child: SafeArea(
                bottom: false,
                // _medida() limita el ancho: en una laptop, un formulario
                // estirado a 1400 px se lee pésimo. Se usa aquí y abajo
                // para que el título quede alineado con los campos.
                child: _medida(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'Scouting de match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Un robot por match. Cuenta lo que anota y guarda el reporte al final.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: _medida(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---------------------------------------------------
                    // CAMPO DE TEXTO: número de equipo
                    // ---------------------------------------------------
                    _etiqueta('Equipo scouteado'),
                    const SizedBox(height: 8),
                    TextField(
                      // NUEVO en sesión 4: aquí conectamos la cajita con su
                      // memoria. Sin esta línea el usuario podría escribir,
                      // pero nosotros nunca podríamos leer lo que escribió.
                      controller: _equipoController,
                      // Le pedimos al celular que abra el teclado numérico:
                      // los números de equipo de FRC son números.
                      keyboardType: TextInputType.number,
                      // NUEVO en sesión 4: el teclado numérico es solo una
                      // sugerencia (en una laptop se puede escribir "abc").
                      // Estos filtros sí lo garantizan: solo dígitos, y
                      // máximo 5 (el equipo más alto de FRC tiene 5). Por
                      // eso int.parse() en _guardar() nunca falla.
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      cursorColor: kAzul,
                      style: const TextStyle(
                        color: kTinta,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      // La cajita (fondo, borde, esquinas) viene de
                      // decoracionCampo(), en estilos.dart. Aquí solo
                      // decimos lo que cambia: el hint y el "#" fijo a la
                      // izquierda, que deja claro que va un número.
                      decoration: decoracionCampo(
                        hintText: '6017',
                        prefixText: '# ',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------------------------------------------------
                    // CAMPO DE TEXTO: número de match
                    // ---------------------------------------------------
                    // NUEVO en sesión 4: es el mismo TextField de arriba,
                    // con su propio controller.
                    _etiqueta('Número de match'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _matchController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      cursorColor: kAzul,
                      style: const TextStyle(
                        color: kTinta,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      // Mismo truco que el "# " del equipo: lo fijo se ve
                      // escrito pero no hay que teclearlo. El scouter solo
                      // pone el número; el resto lo pega _guardar().
                      decoration: decoracionCampo(
                        hintText: '67',
                        prefixText: '${kEvento}_qm',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------------------------------------------------
                    // DROPDOWN: rol del robot en el match
                    // ---------------------------------------------------
                    _etiqueta('Rol del robot'),
                    const SizedBox(height: 8),
                    // InputDecorator es la "cajita" del TextField sin el
                    // TextField adentro. Con la misma decoracionCampo()
                    // el dropdown lleva exactamente el mismo borde,
                    // relleno y esquinas, y los dos campos se ven como
                    // hermanos y no como dos inventos distintos.
                    InputDecorator(
                      decoration: decoracionCampo(),
                      // El dropdown trae por defecto una rayita subrayada
                      // que aquí sobra, porque ya tenemos el borde.
                      child: DropdownButtonHideUnderline(
                        // DropdownButton<String>: el <String> dice de qué
                        // tipo son las opciones. Aquí son textos; podrían
                        // ser números o cualquier otra cosa.
                        child: DropdownButton<String>(
                          // Qué opción se ve como seleccionada. Ojo: el
                          // dropdown NO recuerda tu elección por su cuenta.
                          // Solo muestra lo que le decimos aquí. La memoria
                          // es nuestra variable _rolSeleccionado, igual que
                          // con el contador.
                          value: _rolSeleccionado,
                          // NUEVO en sesión 4: lo que se ve mientras
                          // `value` es null, o sea, antes de elegir. Sin
                          // esto la caja se vería vacía.
                          hint: const Text(
                            'Elige un rol',
                            style: TextStyle(color: kTintaSuave),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          icon: const Icon(
                            Icons.expand_more_rounded,
                            color: kAzul,
                          ),
                          style: const TextStyle(
                            color: kTinta,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          // Convertimos cada texto de la lista en una
                          // opción del menú. `.map()` recorre la lista y
                          // transforma cada elemento; `.toList()` junta el
                          // resultado otra vez en una lista, que es lo que
                          // espera `items`.
                          items: _roles.map((String rol) {
                            return DropdownMenuItem<String>(
                              value: rol,
                              child: Text(rol),
                            );
                          }).toList(),
                          // onChanged se dispara cuando el usuario elige
                          // algo. Es la misma idea del onPressed del botón:
                          // el dropdown nos AVISA, y nosotros decidimos qué
                          // hacer.
                          //
                          // El valor llega como `String?` (con signo de
                          // pregunta = puede ser nulo) porque Flutter
                          // permite "deseleccionar". Como nosotros siempre
                          // queremos un rol elegido, si llega nulo
                          // simplemente no hacemos nada.
                          onChanged: (String? nuevoRol) {
                            if (nuevoRol == null) return;
                            setState(() {
                              _rolSeleccionado = nuevoRol;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ---------------------------------------------------
                    // CONTADORES: el mismo widget, dos veces
                    // ---------------------------------------------------
                    _etiqueta('Elementos anotados'),
                    const SizedBox(height: 12),

                    // Los dos bloques de abajo son idénticos salvo por
                    // cuatro cosas: título, ayuda, valor y qué función
                    // corre el botón. Los dejamos escritos completos (y no
                    // en otra función) para que se vea con los ojos que el
                    // ÚNICO widget compartido es CounterButton.
                    _panelContador(
                      titulo: 'Autónomo',
                      ayuda: 'Los primeros 15 segundos, sin piloto',
                      valor: _puntosAutonomo,
                      // Le pasamos la función SIN paréntesis:
                      //   _incrementarAutonomo   -> le damos la función
                      //   _incrementarAutonomo() -> la ejecutaríamos ya
                      // Queremos lo primero: que el botón la guarde y la
                      // llame él cuando lo toquen.
                      onPressed: _incrementarAutonomo,
                    ),

                    const SizedBox(height: 14),

                    // MISMO CounterButton adentro, distinto label y
                    // distinto callback. Cero código copiado: si el botón
                    // cambia de forma o de color, cambian los dos a la vez.
                    _panelContador(
                      titulo: 'Teleoperado',
                      ayuda: 'El resto del match, con piloto',
                      valor: _puntosTeleoperado,
                      onPressed: _incrementarTeleoperado,
                    ),

                    const SizedBox(height: 18),
                    // Una línea fina separa el total de las tarjetas: deja
                    // claro que es un resultado, no un tercer contador.
                    const Divider(color: Color(0x33006EB6), height: 1),
                    const SizedBox(height: 14),

                    // El total no es una quinta variable: se calcula al
                    // vuelo sumando las dos que ya tenemos. Guardar un dato
                    // que se puede calcular es pedir que algún día quede
                    // desactualizado.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total del match',
                          style: TextStyle(
                            color: kTintaSuave,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_puntosAutonomo + _puntosTeleoperado}',
                          style: const TextStyle(
                            color: kTinta,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ---------------------------------------------------
                    // GUARDAR
                    // ---------------------------------------------------
                    SizedBox(
                      height: 56,
                      // BotonAzul vive en estilos.dart: azul a propósito,
                      // para que no se confunda con los naranjas de contar.
                      child: BotonAzul(
                        label: 'Guardar reporte',
                        icon: Icons.assignment_turned_in_rounded,
                        onPressed: _guardar,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Limita el ancho del contenido y lo centra. En un celular no cambia
  // nada (la pantalla mide menos de 520); en una laptop evita que el
  // formulario se estire de lado a lado, que es donde se vuelve
  // incómodo de leer y de llenar.
  Widget _medida(Widget hijo) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        // width: infinity dentro de un máximo de 520 = "ocupa 520, o
        // toda la pantalla si es más angosta". Sin esto, la columna se
        // encogería al ancho de su texto más largo y el título quedaría
        // flotando en medio en vez de alineado con los campos.
        child: SizedBox(width: double.infinity, child: hijo),
      ),
    );
  }

  // Las etiquetas de cada sección del formulario. Otra función chiquita
  // para no repetir el mismo TextStyle tres veces.
  Widget _etiqueta(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: kTinta,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // La tarjeta blanca de un contador: el número grande, el nombre de la
  // fase y, abajo, el CounterButton.
  //
  // Fíjate en el `onPressed` que recibe: esta función no hace nada con
  // él, solo lo pasa de largo hasta el botón. Así viaja un callback en
  // Flutter, de mano en mano, hasta llegar al widget que de verdad lo va
  // a disparar.
  Widget _panelContador({
    required String titulo,
    required String ayuda,
    required int valor,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // La sombra lleva desplazamiento hacia abajo y desenfoque: así se
        // ve como una tarjeta apoyada sobre el fondo y no como un halo.
        boxShadow: [
          BoxShadow(
            color: kAzul.withValues(alpha: 0.10),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // El número, grande y en su propia cajita azul clara. Este
              // Text lo dibuja la PANTALLA, no el botón: el botón nunca
              // se entera de en qué número vamos.
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kFondo,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$valor',
                  style: const TextStyle(
                    color: kTinta,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Expanded: el texto se queda con todo el ancho que sobra,
              // y si el nombre de la fase es largo, se acomoda en dos
              // renglones en vez de desbordarse.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: kTinta,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ayuda,
                      style: const TextStyle(
                        color: kTintaSuave,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Aquí está el widget reusable de la sesión: el mismo archivo,
          // usado dos veces, con distinto texto y distinta función.
          CounterButton(label: titulo, onPressed: onPressed),
        ],
      ),
    );
  }
}
