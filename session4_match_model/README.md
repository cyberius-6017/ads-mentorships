# Match Report Model (modelar el reporte)

En la sesión 3 el formulario ya capturaba todo: equipo, rol, autónomo y
teleoperado. Pero el botón "Guardar reporte" no hacía nada: los datos
seguían siendo **variables sueltas**. Esta sesión les da forma: al tocar
"Guardar", los juntamos en **un solo objeto**, un `MatchReport`, y lo
imprimimos en la terminal.

Misma pantalla, mismos widgets, mismos colores. Lo nuevo es:

1. **`TextEditingController`**: en la sesión 3 se podía escribir el
   número de equipo, pero no leerlo. El controller guarda lo que escribe
   el usuario y nos lo da con `.text`. Todo controller que creas, lo
   liberas en `dispose()`.
2. **Una clase en Dart** (`lib/models/match_report.dart`): el molde del
   reporte, con campos `final`, un constructor con **parámetros
   nombrados** y `required`, y su propio `toString()`.
3. **Crear un objeto desde la UI**: leer los controllers, el dropdown y
   los contadores, y armar con ellos un `MatchReport`.
4. **Validar con un `if`**: si falta un dato, no se guarda y se avisa.
   La revisión y el aviso viven en su propio archivo,
   `lib/utils/reporte_utils.dart`.
5. **Usar un paquete de pub.dev**: `awesome_snackbar_content`, para el
   aviso rojo de "Faltan datos".

Además, el formulario gana un campo: el **número de match**. El scouter
escribe solo `67` y la app arma la clave completa, como la usa The Blue
Alliance: `2026cc_qm67`.

En el código, todo lo que cambió respecto a la sesión 3 está marcado con
`// NUEVO en sesión 4:`. Busca esa frase para ver el "diff" de un vistazo.

## ¿Por qué un modelo?

Piensa en la hoja de scouting de papel. Nadie anota el equipo en un
papelito, el rol en otro y los puntos en un tercero: hay **una hoja** con
sus casillas impresas, y cada match se llena una hoja nueva.

La clase `MatchReport` es esa hoja impresa (el molde) y cada reporte
guardado es una hoja ya llena (un objeto). Teniendo el reporte en un solo
objeto, después se puede guardar en una lista, mandar a otra pantalla o
subir a internet... pero eso viene en las siguientes sesiones. Hoy solo
aprendemos a fabricarlo.

## La clase, pieza por pieza

```dart
class MatchReport {
  final int teamNumber;
  final String matchNumber;
  final String role;
  final int autoPoints;
  final int teleopPoints;

  const MatchReport({
    required this.teamNumber,
    required this.matchNumber,
    required this.role,
    required this.autoPoints,
    required this.teleopPoints,
  });
}
```

- **`final`**: cada casilla se llena una sola vez, al crear el reporte, y
  ya no cambia. Un reporte guardado no se edita por accidente.
- **Las llaves `{ }`** hacen que los parámetros sean **nombrados**: se
  escribe `teamNumber: 6017` y no solo `6017`. Con dos números seguidos
  (autónomo y teleoperado) es facilísimo invertirlos sin darse cuenta;
  con nombres, imposible.
- **`required`**: si se te olvida un dato, el editor lo marca en rojo
  antes de correr la app. Es el mismo `required` del `CounterButton` de la
  sesión 3.
- **`toString()`**: decide qué texto sale al convertir el objeto en
  `String`. El que trae Dart de fábrica dice `Instance of 'MatchReport'`;
  el nuestro escribe el reporte completo, y es justo lo que sale en la
  terminal con `debugPrint('$reporte')`.

Y así se fabrica uno desde la pantalla, en `_guardar()`:

```dart
final MatchReport reporte = MatchReport(
  teamNumber: int.parse(_equipoController.text),
  matchNumber: '${kEvento}_qm${_matchController.text}',
  role: _rolSeleccionado!,
  autoPoints: _puntosAutonomo,
  teleopPoints: _puntosTeleoperado,
);
```

`int.parse()` convierte el texto `'6017'` en el número `6017`. No puede
fallar porque el campo tiene un filtro que solo deja escribir dígitos.

## Validar sin complicarse

Antes de fabricar el reporte, `_guardar()` le pregunta a
`campoQueFalta()` (en `lib/utils/reporte_utils.dart`) si falta algo.
Adentro es un `if` por campo, en el orden en que aparecen en pantalla:

```dart
if (equipo.isEmpty) {
  return 'Escribe el número de equipo';
}
```

Si regresa un mensaje, `_guardar()` muestra el aviso rojo con
`avisarQueFalta()` y se detiene:

```dart
if (falta != null) {
  avisarQueFalta(context, falta);
  return;
}
```

El `return` termina `_guardar()` ahí mismo: si falta algo, nunca se llega
a crear el reporte. Solo se avisa del **primer** dato que falte; cuando el
scouter lo corrige y vuelve a tocar "Guardar", se avisa del siguiente.

Para que esto funcione con el dropdown, `_rolSeleccionado` pasó de
`String` a `String?` y empieza en `null` (en la sesión 3 empezaba en
"Ofensivo"). Así, si el scouter no elige rol, nos damos cuenta, en vez de
guardar un "Ofensivo" que nadie escogió.

## Requisitos previos

- Tener instalado el [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Confirmar que todo esté bien instalado:

  ```bash
  flutter doctor
  ```

- Haber visto `session3_match_scouting_form`: aquí damos por sabido
  `TextField`, `DropdownButton` y "lifting state up".

## Cómo correr el proyecto

1. Entra a la carpeta del proyecto:

   ```bash
   cd session4_match_model
   ```

2. Baja las dependencias (esta vez incluye un paquete de pub.dev):

   ```bash
   flutter pub get
   ```

3. Corre la app:

   ```bash
   flutter run
   ```

4. Toca "Guardar reporte" sin llenar nada: sale el aviso rojo. Llena el
   equipo, el match y el rol, cuenta unos puntos y guarda: el reporte se
   imprime en la terminal donde corre `flutter run`.

Las pruebas verifican que el aviso salga cuando falta algo y que el
reporte se arme bien cuando no:

```bash
flutter test
```

## Estructura del proyecto

```
session4_match_model/
├── android/, ios/, linux/, macos/, windows/, web/  # generado por Flutter
├── lib/
│   ├── main.dart                 # MatchScoutingScreen (con _guardar)
│   ├── models/
│   │   └── match_report.dart     # NUEVO: la clase MatchReport, Dart puro
│   ├── utils/
│   │   └── reporte_utils.dart    # NUEVO: campoQueFalta() y avisarQueFalta()
│   └── widgets/
│       ├── counter_button.dart   # el botón reusable, igual que en la sesión 3
│       └── estilos.dart          # colores, botones y la cajita de los campos
├── test/
│   └── widget_test.dart
├── pubspec.yaml                  # ahora con awesome_snackbar_content
├── GUIA_EN_VIVO.md               # paso a paso para el mentor, desde la sesión 3
└── README.md                     # este archivo
```

Cada carpeta, una responsabilidad: `models/` sabe **qué datos hay**,
`utils/` sabe **revisar y avisar**, `widgets/` sabe **cómo se ve un
pedazo de pantalla**, y `main.dart` los conecta. Fíjate que `match_report.dart` ni siquiera importa Flutter: un
modelo no dibuja nada.

## Guion de clase

Para seguir en vivo, partiendo de una copia de la sesión 3. El paso a
paso completo, con el código de cada paso y qué explicar, está en
`GUIA_EN_VIVO.md`.

- [ ] Leer el campo de texto: escribir un equipo y preguntar cómo lo
  leemos. Crear el `TextEditingController`, conectarlo al `TextField`
  con `controller:`, liberarlo en `dispose()` e imprimir `.text` en
  `_guardar()`.
- [ ] Ver el problema: con un solo dato está bien, pero ¿cómo juntamos
  los cuatro en un reporte?
- [ ] Crear `lib/models/match_report.dart` con los cuatro campos `final`
  y ver el error "must be initialized".
- [ ] Agregar el constructor con `{ }` y `required`.
- [ ] Crear un `MatchReport` en `_guardar()` y hacer `debugPrint`: sale
  `Instance of 'MatchReport'`. Agregar `toString()` y repetir.
- [ ] Romperlo: guardar con el equipo vacío (`FormatException`). Crear
  `lib/utils/reporte_utils.dart` con `campoQueFalta()`, y en `_guardar()`
  el `if` con `return` y un `SnackBar` normal.
- [ ] Romperlo otra vez escribiendo `abc` en la laptop. Agregar
  `FilteringTextInputFormatter.digitsOnly`.
- [ ] Instalar el paquete y mostrar cómo apareció en `pubspec.yaml`:

  ```bash
  flutter pub add awesome_snackbar_content
  ```

- [ ] Volver a correr la app (un paquete nuevo no entra con hot reload) y
  escribir `avisarQueFalta()` en `reporte_utils.dart` con
  `AwesomeSnackbarContent`.
- [ ] Tocar "Guardar" cinco veces y ver los avisos en fila. Arreglarlo con
  `..hideCurrentSnackBar()`.
- [ ] Pasar `_rolSeleccionado` a `String?`, leer el error rojo, agregar
  `rol` a `campoQueFalta()` con su `if`, el `!` y el `hint:`. Hot restart
  con `R`.
- [ ] Agregar `matchNumber` al modelo y seguir los errores rojos:
  `kEvento`, controller, `dispose()`, `TextField`, `match` en
  `campoQueFalta()` y la línea en `toString()`.
- [ ] Prueba final: guardar con cada campo vacío, uno a la vez, y ver que
  el aviso diga cuál falta; con todo lleno, ver el reporte en la terminal.

## Reto extra

Para los que terminen antes:

- **Aviso de éxito**: al guardar bien, muestra otro `AwesomeSnackbarContent`
  con `ContentType.success` y un título como "¡Reporte guardado!". Pista:
  `avisarQueFalta()` ya hace casi todo; ¿cómo la harías servir para los
  dos casos sin copiarla? (Una idea: que reciba también el título y el
  `ContentType`.)
- **Un campo nuevo**: agrega "¿Escaló al final?" al modelo y al formulario.
  Son cuatro pasos y conviene hacerlos en este orden: el campo `final bool
  climbed` en `MatchReport` (el editor marcará en rojo dónde falta el dato:
  esa es la gracia del `required`), una variable `bool _escalo = false` en
  el State, un `Switch` o `Checkbox` en la pantalla con su `setState()`, y
  la línea nueva en `toString()`.
- **El total en el modelo**: el total del match se calcula sumando dos
  campos que el reporte ya tiene. Agrégale a `MatchReport` un *getter*
  (`int get total => autoPoints + teleopPoints;`) y úsalo en `toString()`.
  Fíjate que no es un campo nuevo ni va en el constructor: se calcula
  cada vez que lo pides.
- **Mostrar el reporte en pantalla**: en vez de solo imprimirlo, guárdalo
  en una variable del State (`MatchReport? _ultimoReporte;`) con
  `setState()`, y abajo del botón pon un `Text` que muestre
  `_ultimoReporte.toString()`, o "Aún no hay reportes" si es `null`.
- **Limpiar el formulario** después de guardar bien: `_equipoController.clear()`,
  `_matchController.clear()`, los contadores a 0 y el rol a `null`, todo
  dentro del mismo `setState()`.
