import 'package:flutter/material.dart';

// Este archivo tiene UN SOLO widget: el botón que ya usábamos en la
// sesión 2, pero sacado de main.dart para poder reusarlo.
//
// La idea nueva de esta sesión es COMPOSICIÓN: en vez de escribir el
// mismo botón dos veces (uno para autónomo y otro para teleoperado), lo
// escribimos UNA vez aquí y lo usamos las veces que queramos. Si mañana
// el equipo decide que los botones son verdes, se cambia en un solo
// lugar y cambian todos.

// Fíjate que es StatelessWidget, NO StatefulWidget.
//
// Esto es a propósito y es el punto de la sesión: este botón es "tonto".
// No sabe cuántas veces lo apretaron, no sabe en qué número va el
// contador, no recuerda nada. Solo sabe dos cosas, y las dos se las pasa
// el papá por el constructor:
//   1. qué texto mostrar (label)
//   2. a quién avisarle cuando lo tocan (onPressed)
class CounterButton extends StatelessWidget {
  // `final` = una vez que el widget se construye con estos valores, ya
  // no cambian. Un StatelessWidget no puede cambiar sus propios datos;
  // si el papá quiere otro texto, construye un CounterButton nuevo.
  final String label;

  // Este es el tipo más raro de la sesión, así que va despacio:
  // `VoidCallback` es "una función que no recibe nada y no devuelve
  // nada". O sea: una acción. El papá nos manda la acción y nosotros la
  // ejecutamos cuando el dedo toca el botón, sin saber qué hace.
  //
  // Es como el radio en las gradas: el scouter aprieta el botón y avisa
  // "¡anotaron!", pero quien lleva la cuenta en la libreta es otra
  // persona. El botón avisa; el papá cuenta.
  final VoidCallback onPressed;

  // `required` obliga a que quien use este widget pase los dos datos.
  // Si se te olvida uno, el error sale al escribir el código (subrayado
  // rojo en el editor), no en media competencia con la app corriendo.
  const CounterButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 54 de alto porque este botón se aprieta con el pulgar, parado en
    // las gradas y sin ver la pantalla: si es chiquito, se falla.
    // El ANCHO no lo decidimos aquí a propósito: double.infinity
    // significa "todo el ancho que me dé mi papá". Así el mismo botón
    // sirve angosto o ancho según dónde lo pongan.
    return SizedBox(
      height: 54,
      width: double.infinity,
      // ElevatedButton.icon = ícono + texto en el mismo botón. El ícono
      // de "+" hace obvio qué pasa al tocarlo, aun sin leer.
      child: ElevatedButton.icon(
        // Aquí NO hay setState() ni ninguna variable que cambie.
        // Simplemente le entregamos a ElevatedButton la función que nos
        // dieron. Cuando el usuario toca, Flutter llama a onPressed, que
        // es código que vive en la pantalla papá.
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 24),
        // El texto tampoco lo decidimos nosotros: viene del papá. Por
        // eso el MISMO widget dice "Autónomo" en un lugar y
        // "Teleoperado" en otro.
        label: Text(label),
      ),
    );
    // ¿Y los colores? No están aquí, y es a propósito. Viven en el
    // `theme:` del MaterialApp (main.dart). Este botón hereda el estilo
    // del equipo automáticamente, igual que un jugador se pone el
    // uniforme sin tener que diseñarlo. Así ningún archivo repite el
    // mismo naranja escrito a mano.
  }
}
