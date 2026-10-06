import 'package:flutter/material.dart';

// Importamos NUESTRO propio widget. Igual que 'package:flutter/material.dart'
// trae widgets que escribió el equipo de Flutter, esta línea trae el widget
// que escribimos nosotros en lib/widgets/counter_button.dart.
// El nombre 'session3_match_scouting_form' es el `name:` del pubspec.yaml.
import 'package:session3_match_scouting_form/widgets/counter_button.dart';
// Los colores del equipo, los botones naranja y azul, y el estilo de las
// cajas del formulario (lib/widgets/estilos.dart).
import 'package:session3_match_scouting_form/widgets/estilos.dart';

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

// Esta pantalla es Stateful porque tiene TRES cosas que recordar
// mientras el scouter llena el formulario:
//   1. el rol que eligió en el dropdown
//   2. cuántos elementos anotó en autónomo
//   3. cuántos anotó en teleoperado
//
// (¿Y el número de equipo? El TextField deja escribirlo, pero todavía no
// tenemos manera de LEERLO desde aquí. Eso es lo primero de la sesión 4.)
//
// Importante: los datos viven AQUÍ, en la pantalla papá. Ninguno
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
  // 1) EL VALOR DEL DROPDOWN
  // ---------------------------------------------------------------
  // La lista de opciones del menú. Es `const` porque nunca cambia: son
  // siempre los mismos tres roles.
  static const List<String> _roles = ['Ofensivo', 'Defensivo', 'Soporte'];

  // El rol que está seleccionado AHORA MISMO. Empieza en el primero de
  // la lista para que el dropdown nunca aparezca vacío.
  // Igual que el contador: es una variable del State, no del Widget.
  String _rolSeleccionado = _roles.first;

  // ---------------------------------------------------------------
  // 2) LOS DOS CONTADORES
  // ---------------------------------------------------------------
  // Dos variables distintas, cada una con su propio número. Las van a
  // mover dos botones que son EL MISMO widget (CounterButton), solo que
  // con distinto label y distinto callback.
  int _puntosAutonomo = 0;
  int _puntosTeleoperado = 0;

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

  // Por ahora no hace nada. Fíjate que desde aquí podríamos leer el rol
  // y los contadores sin problema: TODOS viven en este mismo State. En la
  // sesión 4 aquí vamos a juntarlos en un reporte.
  void _guardar() {}

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
                    // Por ahora el TextField solo dibuja la cajita: se
                    // puede escribir en ella, pero nosotros todavía no
                    // podemos leer lo que escribió el usuario.
                    TextField(
                      // Le pedimos al celular que abra el teclado numérico:
                      // los números de equipo de FRC son números.
                      keyboardType: TextInputType.number,
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
