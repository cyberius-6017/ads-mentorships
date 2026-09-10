import 'package:flutter/material.dart';

// Importamos NUESTRO propio widget. Igual que 'package:flutter/material.dart'
// trae widgets que escribió el equipo de Flutter, esta línea trae el widget
// que escribimos nosotros en lib/widgets/counter_button.dart.
// El nombre 'session3_match_scouting_form' es el `name:` del pubspec.yaml.
import 'package:session3_match_scouting_form/widgets/counter_button.dart';

// ---------------------------------------------------------------------
// LOS COLORES DEL EQUIPO, EN UN SOLO LUGAR
// ---------------------------------------------------------------------
// Son los mismos colores de ads.team6017.com, para que la app se sienta
// parte de la familia Cyberius. Escribirlos una vez arriba (y no
// "0xFF006EB6" regado por todo el archivo) es la misma idea que sacar el
// botón a su propio archivo: si el color cambia, se cambia aquí.
const Color kAzul = Color(0xFF006EB6); // azul Cyberius: acción principal
const Color kFondo = Color(0xFFC9EDFF); // azul claro: fondo de la pantalla
const Color kNaranja = Color(0xFFF96815); // naranja: los botones de contar
const Color kTinta = Color(0xFF003D63); // azul muy oscuro: el texto
const Color kTintaSuave = Color(0xFF46708F); // azul apagado: texto secundario
// Los botones naranjas llevan texto casi negro y no blanco: el blanco
// sobre naranja se lee mal bajo el sol de las gradas.
const Color kTintaNaranja = Color(0xFF12293D);

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
      // ---------------------------------------------------------------
      // EL TEMA: el uniforme del equipo
      // ---------------------------------------------------------------
      // Todo lo que pongamos aquí lo heredan TODOS los widgets de la app,
      // por más abajo que estén. Por eso counter_button.dart no tiene ni
      // un color escrito: se viste solo con lo que definimos aquí.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kAzul),
        scaffoldBackgroundColor: kFondo,

        // Estilo de TODOS los ElevatedButton de la app (o sea: los dos
        // CounterButton). Uno solo lo va a sobrescribir a propósito: el
        // de "Guardar", más abajo.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kNaranja,
            foregroundColor: kTintaNaranja,
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // Estilo de TODAS las cajas de formulario: el TextField del
        // número de equipo y el dropdown del rol. Definirlo aquí es lo
        // que hace que los dos se vean exactamente iguales, que es
        // justo lo que espera el ojo en un formulario.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: kTintaSuave),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0x33006EB6), width: 1.5),
          ),
          // El borde grueso azul marca dónde está el cursor. Sin esto,
          // con el teclado abierto no se sabe qué campo se está llenando.
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kAzul, width: 2),
          ),
        ),
      ),
      home: const MatchScoutingScreen(),
    );
  }
}

// Esta pantalla es Stateful porque tiene CUATRO cosas que recordar
// mientras el scouter llena el formulario:
//   1. el número de equipo que está escribiendo
//   2. el rol que eligió en el dropdown
//   3. cuántos elementos anotó en autónomo
//   4. cuántos anotó en teleoperado
//
// Importante: los cuatro datos viven AQUÍ, en la pantalla papá. Ninguno
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

  // ---------------------------------------------------------------
  // 2) EL VALOR DEL DROPDOWN
  // ---------------------------------------------------------------
  // La lista de opciones del menú. Es `const` porque nunca cambia: son
  // siempre los mismos tres roles.
  static const List<String> _roles = ['Ofensivo', 'Defensivo', 'Soporte'];

  // El rol que está seleccionado AHORA MISMO. Empieza en el primero de
  // la lista para que el dropdown nunca aparezca vacío.
  // Igual que el contador: es una variable del State, no del Widget.
  String _rolSeleccionado = _roles.first;

  // ---------------------------------------------------------------
  // 3) LOS DOS CONTADORES
  // ---------------------------------------------------------------
  // Dos variables distintas, cada una con su propio número. Las van a
  // mover dos botones que son EL MISMO widget (CounterButton), solo que
  // con distinto label y distinto callback.
  int _puntosAutonomo = 0;
  int _puntosTeleoperado = 0;

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

  // Junta los cuatro datos y los muestra en un diálogo.
  // Fíjate que aquí podemos leer los cuatro sin problema: TODOS viven en
  // este mismo State. Si el contador viviera adentro del botón, esta
  // función no tendría manera de saber en qué número va.
  void _guardar() {
    // Baja el teclado antes de mostrar el diálogo; si no, el resumen
    // aparece encima del teclado y se ve a medias.
    FocusScope.of(context).unfocus();

    // `.text` es lo que el usuario escribió en el TextField, leído desde
    // el controller. Si no escribió nada mostramos una rayita, para que
    // el resumen no aparezca con un hueco raro.
    final String equipo = _equipoController.text.isEmpty
        ? '—'
        : _equipoController.text;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Reporte del match',
            style: TextStyle(color: kTinta, fontWeight: FontWeight.w800),
          ),
          content: Column(
            // mainAxisSize.min: que el diálogo sea del alto de su
            // contenido y no trate de ocupar toda la pantalla.
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Los cuatro datos, cada uno en su renglón. _filaResumen()
              // está más abajo: es una función que arma un renglón, así
              // no escribimos el mismo Row cuatro veces. (Misma idea que
              // el CounterButton, en su versión más chiquita.)
              _filaResumen('Equipo', equipo),
              _filaResumen('Rol', _rolSeleccionado),
              _filaResumen('Autónomo', '$_puntosAutonomo'),
              _filaResumen('Teleoperado', '$_puntosTeleoperado'),
              const SizedBox(height: 14),
              // Los dos contadores sumados: otro dato que solo se puede
              // calcular porque ambos viven en el mismo lugar.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: kFondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total del match',
                      style: TextStyle(
                        color: kTinta,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_puntosAutonomo + _puntosTeleoperado}',
                      style: const TextStyle(
                        color: kTinta,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              // Navigator.pop() cierra el diálogo que está encima.
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: kAzul),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Un renglón "etiqueta ..... valor" del resumen. No es un widget
  // aparte: es solo una función que devuelve widgets, suficiente para
  // algo que se usa nada más dentro de este archivo.
  Widget _filaResumen(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(color: kTintaSuave, fontSize: 15),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: kTinta,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      // Aquí conectamos la cajita con su memoria. Sin esta
                      // línea el usuario podría escribir, pero nosotros
                      // nunca podríamos leer lo que escribió.
                      controller: _equipoController,
                      // Le pedimos al celular que abra el teclado numérico:
                      // los números de equipo de FRC son números.
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: kTinta,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        hintText: '6017',
                        // El "#" fijo a la izquierda deja claro, sin
                        // explicar nada, que ahí va un número de equipo.
                        prefixText: '# ',
                        prefixStyle: TextStyle(
                          color: kTintaSuave,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------------------------------------------------
                    // DROPDOWN: rol del robot en el match
                    // ---------------------------------------------------
                    _etiqueta('Rol del robot'),
                    const SizedBox(height: 8),
                    // InputDecorator es la "cajita" del TextField sin el
                    // TextField adentro. La usamos para que el dropdown
                    // herede exactamente el mismo borde, relleno y esquinas
                    // que definimos en el tema, y los dos campos se vean
                    // como hermanos y no como dos inventos distintos.
                    InputDecorator(
                      decoration: const InputDecoration(),
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
                          isExpanded: true,
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
                      child: ElevatedButton.icon(
                        // Este es el único botón que NO usa el naranja del
                        // tema: se viste de azul a propósito. Los naranjas
                        // se tocan muchas veces durante el match; este se
                        // toca una sola vez, al final, y conviene que no se
                        // confunda con los otros.
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAzul,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _guardar,
                        icon: const Icon(Icons.assignment_turned_in_rounded),
                        label: const Text('Guardar reporte'),
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
