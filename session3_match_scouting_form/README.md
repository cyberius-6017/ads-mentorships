# Match Scouting Form (formulario de scouting)

La sesión 2 fue un botón y un número. Esta es la app completa que usaría
un scouter en las gradas: escribe el número del equipo que está viendo,
elige qué rol jugó el robot, cuenta lo que anotó en autónomo y en
teleoperado, y al final guarda el reporte. Tres conceptos nuevos, todos
construidos encima de lo que ya sabes (`StatefulWidget` y `setState()`):

1. **Composición de widgets**: sacar el botón a su propio archivo y usarlo
   dos veces.
2. **`TextField` + `TextEditingController`**: capturar texto que escribe
   el usuario.
3. **`DropdownButton`**: elegir una opción de una lista.

## ¿Por qué esta app y no otra cosa?

Porque es la primera vez que la pantalla tiene **más de un dato al mismo
tiempo**, y ahí aparece la pregunta que de verdad importa: *¿dónde vive
cada dato?*

En la sesión 2 había un solo número y un solo botón, así que no había
nada que decidir. Aquí hay cuatro datos (equipo, rol, autónomo,
teleoperado) y dos botones que son el mismo widget. Si cada botón
guardara su propio número, el botón de "Guardar" no tendría manera de
leerlos para armar el reporte. Ese problema —y su solución— es toda la
sesión.

Además, es la primera app del mentorship que se parece a algo que el
equipo usaría en una competencia de verdad.

## El truco que hay que entender: por qué el hijo no puede tener su propio estado

Mira el widget `CounterButton` (`lib/widgets/counter_button.dart`). Es un
`StatelessWidget`: **no recuerda nada**. Solo recibe dos cosas por el
constructor:

```dart
CounterButton(
  label: 'Autónomo',            // qué texto mostrar
  onPressed: _incrementarAutonomo, // a quién avisarle cuando lo toquen
)
```

La tentación del principiante es hacerlo `StatefulWidget` y meterle su
propio `int _contador` adentro. Funcionaría... hasta que necesitas el
número en otro lado. Y siempre lo necesitas: para mostrarlo en la
pantalla, para sumar autónomo + teleoperado, para guardar el reporte.
Un widget hijo no puede pasarle datos hacia arriba a su papá; solo puede
**avisarle** que algo pasó.

Por eso el número vive en el papá (`MatchScoutingScreen`) y el botón solo
avisa:

- el papá guarda `_puntosAutonomo` y `_puntosTeleoperado`;
- el papá le presta al botón la función `_incrementarAutonomo`;
- el botón la llama cuando lo tocan, sin saber qué hace;
- el papá corre `setState()` y se redibuja la pantalla, incluido el
  número.

Esto se llama **"lifting state up"** (subir el estado): *el dato vive en
el widget más arriba que necesite leerlo*. Es la regla más útil de
Flutter y no requiere ningún paquete: con `setState()` alcanza.

La misma idea aplica a los otros dos widgets nuevos:

- El **`TextField`** tampoco recuerda por su cuenta lo que escribiste: lo
  recuerda un `TextEditingController` que creamos nosotros y que
  liberamos en `dispose()`. Es un objeto que reserva memoria; si no lo
  liberas al salir, esa memoria se queda ocupada (una *fuga de memoria*).
  Regla simple: **todo controller que creas, lo liberas en `dispose()`**.
- El **`DropdownButton`** tampoco recuerda cuál opción elegiste: solo
  muestra lo que le pasamos en `value:`. La memoria es nuestra variable
  `_rolSeleccionado`, y se actualiza en `onChanged` con `setState()`.
  Si se te olvida ese `setState()`, el menú se abre, eliges... y se queda
  en la opción vieja. Vale la pena provocarlo a propósito para verlo.

## Requisitos previos

- Tener instalado el [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Confirmar que todo esté bien instalado:

  ```bash
  flutter doctor
  ```

- Haber visto `session2_scouting_counter`: aquí damos por sabido
  `StatefulWidget` y `setState()`.

## Cómo correr el proyecto

1. Entra a la carpeta del proyecto:

   ```bash
   cd session3_match_scouting_form
   ```

2. Baja las dependencias:

   ```bash
   flutter pub get
   ```

3. Corre la app (con un emulador, un celular conectado, o en modo web/escritorio
   si tu entorno lo soporta):

   ```bash
   flutter run
   ```

4. Escribe un número de equipo, elige un rol, toca los dos botones
   naranjas unas cuantas veces y dale a "Guardar reporte": el resumen
   junta los cuatro datos.

También puedes correr las pruebas, que verifican justamente que cada
botón mueve **solo** su propio contador:

```bash
flutter test
```

## Estructura del proyecto

```
session3_match_scouting_form/
├── android/, ios/, linux/, macos/, windows/, web/  # generado por Flutter
├── lib/
│   ├── main.dart                 # colores del equipo, tema y MatchScoutingScreen
│   └── widgets/
│       └── counter_button.dart   # el botón reusable, sin estado propio
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md                     # este archivo
```

Dos archivos, dos responsabilidades: `main.dart` sabe **qué datos hay**,
`counter_button.dart` sabe **cómo se ve un botón de contar**. Los colores
del equipo están definidos una sola vez, arriba de `main.dart`, y se
reparten a toda la app por el `theme:` del `MaterialApp`; por eso el
archivo del botón no tiene ni un color escrito a mano.

## Para experimentar

Con la app corriendo (`flutter run`), prueba estos cambios, guarda y
presiona `r` en la terminal para ver el resultado al instante (hot
reload):

- **Agrega un tercer contador** para otro elemento de juego (por ejemplo
  "Escalada" o "Notas altas") **sin copiar el código del botón**:
  necesitas una variable nueva `int _puntosEscalada = 0;`, una función
  `_incrementarEscalada()` con su `setState()`, y otra llamada a
  `_panelContador(...)`. El widget `CounterButton` no se toca. Si tuviste
  que abrir `counter_button.dart`, algo se copió de más.
- **Quita el `onPressed:` al usar `CounterButton`** y mira qué pasa: el
  editor marca error *antes* de correr la app, porque el parámetro es
  `required`. Ahora prueba lo contrario: déjalo pero pásale `null` (para que Dart te
  deje, en `counter_button.dart` el tipo tiene que pasar de
  `VoidCallback` a `VoidCallback?` y perder el `required`). El botón se dibuja **gris y no
  responde**: así avisa Flutter que un botón sin acción está deshabilitado.
  Es un buen recordatorio de que el botón no hace nada por sí solo.
- **Valida el número de equipo**: que "Guardar reporte" no muestre el
  resumen si el campo está vacío. En `_guardar()`, antes del diálogo,
  pregunta `if (_equipoController.text.isEmpty)` y muestra un aviso con
  `ScaffoldMessenger.of(context).showSnackBar(...)`. Cuando eso funcione,
  intenta lo más difícil: que el campo se ponga rojo con un mensaje
  debajo (pista: una variable `String? _errorEquipo` en el State, pasada
  a `errorText:` del `InputDecoration`, y actualizada con `setState()`).
- **Cambia los roles** de la lista `_roles` por alianzas ("Alianza Roja",
  "Alianza Azul") o por lo que necesite el equipo esta temporada. Fíjate
  que no hay que tocar nada más: el menú se arma solo a partir de la
  lista.
- **Rompe el `setState()` a propósito** en `onChanged` del dropdown y
  mira cómo la selección "no cambia" aunque sí cambió por dentro. Es el
  mismo bug de la sesión 2, con otro disfraz.
