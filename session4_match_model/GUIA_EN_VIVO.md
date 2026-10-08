# Guía en vivo: de la sesión 3 a la sesión 4

Guía para el mentor. Se parte del código de `session3_match_scouting_form`
(con `_guardar()` vacía y el `TextField` sin controller) y se programa en clase, paso a paso, hasta llegar
a lo que hay en esta carpeta.

**Meta de la clase:** al tocar "Guardar reporte", juntar los datos del
formulario en un objeto `MatchReport` e imprimirlo en la terminal.

Cada paso deja la app **compilando y funcionando**: si la clase se corta
en cualquier punto, nadie se queda con la app rota. Los errores en rojo
que aparecen en el camino son **a propósito**, porque cada uno enseña algo.

Los fragmentos van sin comentarios para que se escriban rápido. Las
explicaciones están en "Qué decir". La versión comentada completa está en
`lib/` de esta carpeta, por si algún alumno se pierde.

## Resumen: qué es lo nuevo

| # | Qué se programa | Concepto |
|---|---|---|
| 1 | `TextEditingController` para el campo de equipo | leer lo que escribe el usuario, `dispose()` |
| 2 | Juntar los datos: ¿cómo? | motivación |
| 3 | `lib/models/match_report.dart` | clase, `final`, constructor con parámetros nombrados, `required` |
| 4 | Crear un `MatchReport` en `_guardar()`, imprimirlo, `toString()` | objeto desde la UI |
| 5 | `lib/utils/reporte_utils.dart` con `campoQueFalta()` + filtro de dígitos | validar con `if` y `return` |
| 6 | `flutter pub add` + `avisarQueFalta()` | usar un paquete de pub.dev |
| 7 | El rol pasa a `String?` | validar el dropdown, `!` |
| 8 | Campo "Número de match" | agregar un campo: `required` nos guía |
| 9 | Prueba final | |

## Paso 0: preparar (antes de la clase)

Copia la carpeta de la sesión 3 y trabaja sobre la copia. **No le cambies
el nombre al proyecto**: así los `import 'package:session3_match_scouting_form/...'`
siguen funcionando y no pierdes tiempo de clase en eso.

```bash
cp -r session3_match_scouting_form clase_sesion4
cd clase_sesion4
flutter pub get
flutter run -d chrome
```

Ten a la mano la terminal donde corre `flutter run`: ahí van a salir los
reportes impresos y los errores.

## Paso 1: leer lo que se escribe (`TextEditingController`)

**Hacer:** escribe un número de equipo en la app.

**Preguntar:** *"Si en `_guardar()` quisiera imprimir ese número, ¿qué
escribo?"* No hay manera: el `TextField` dibuja la cajita y deja
escribir, pero no tiene ninguna variable que podamos leer.

**Qué decir:** igual que en la sesión 2 el contador vivía en una variable
`int`, el texto necesita algo que lo **recuerde**. Eso es el
`TextEditingController`: guarda lo que escribe el usuario y nos lo presta
cuando le pedimos `.text`.

**Hacer:** en el State, arriba de `_roles`:

```dart
  final TextEditingController _equipoController = TextEditingController();
```

En el `TextField` del equipo, como primera línea:

```dart
                      controller: _equipoController,
```

Y llena `_guardar()` para probarlo:

```dart
  void _guardar() {
    debugPrint(_equipoController.text);
  }
```

**Qué decir:**
- `final` porque el controller nunca se cambia por otro; lo que cambia es
  el texto que tiene adentro.
- `controller:` conecta la cajita con su memoria. Sin esa línea el
  usuario escribe, pero el controller se queda vacío.

**Probar:** hot restart (`R`), escribe `6017` y toca "Guardar reporte":
la terminal imprime `6017`. Quita a propósito la línea `controller:`,
haz hot reload y guarda otra vez: se imprime una línea vacía.
Vuelve a ponerla.

**Hacer:** el controller reserva memoria, así que hay que liberarlo.
Debajo de `_puntosTeleoperado`:

```dart
  @override
  void dispose() {
    _equipoController.dispose();
    super.dispose();
  }
```

**Qué decir:** `dispose()` corre cuando la pantalla se destruye. Es el
"apaga la luz al salir". Si no liberamos el controller, la memoria se
queda ocupada aunque la pantalla ya no exista (una *fuga de memoria*).
Regla: **todo controller que creas, lo liberas en `dispose()`**.
`super.dispose()` va al final: primero limpiamos lo nuestro y luego deja
que Flutter limpie lo suyo.

## Paso 2: el problema

**Preguntar:** *"Ya podemos leer el equipo. ¿Qué debería hacer el botón
de Guardar?"* Juntar **los cuatro datos** (equipo, rol, autónomo y
teleoperado) en **un reporte**. Pero son cuatro variables sueltas: si
mañana queremos una lista de reportes o mandarlos a internet, ¿qué
guardamos?

**Qué decir:** en la hoja de scouting de papel nadie anota el equipo en un
papelito y los puntos en otro: hay **una hoja** con casillas impresas.
Hoy hacemos esa hoja en Dart. El molde de la hoja se llama **clase** y
cada hoja llena se llama **objeto**.

## Paso 3: la clase

**Hacer:** crea la carpeta `lib/models/` y adentro el archivo
`match_report.dart`. Escribe primero **solo los campos**:

```dart
class MatchReport {
  final int teamNumber;
  final String role;
  final int autoPoints;
  final int teleopPoints;
}
```

Son las mismas cosas que ya captura el formulario. El número de match lo
agregamos al final (paso 8).

**Error a propósito:** salen cuatro rayas rojas:
`The final variable 'teamNumber' must be initialized`.

**Qué decir:**
- `final` = la casilla se llena una sola vez y ya no cambia. Un reporte
  guardado no se edita por accidente.
- Dart se queja porque las casillas están vacías y nadie las llena. Para
  eso existe el **constructor**: la función que fabrica una hoja nueva.

**Hacer:** agrega el constructor debajo de los campos:

```dart
  const MatchReport({
    required this.teamNumber,
    required this.role,
    required this.autoPoints,
    required this.teleopPoints,
  });
```

**Qué decir:**
- Las **llaves `{ }`** hacen que los parámetros sean **nombrados**. Al
  usarlo se escribe `autoPoints: 3, teleopPoints: 5` y no solo `3, 5`.
  Pregunta: *"si fuera `MatchReport(6017, 'Ofensivo', 3, 5)`, ¿cuál es
  autónomo y cuál teleoperado?"* Con nombres no hay manera de confundirlos.
- `required` es el mismo del `CounterButton`: si falta un dato, el editor
  lo marca **antes** de correr la app.
- `this.teamNumber` = "lo que me pasen, guárdalo en mi casilla
  `teamNumber`".
- Este archivo no importa Flutter: no dibuja nada, es Dart puro. Un
  modelo solo sabe **qué datos hay**.

## Paso 4: fabricar el objeto e imprimirlo

**Hacer:** en `main.dart`, arriba, debajo de los otros imports:

```dart
import 'package:session3_match_scouting_form/models/match_report.dart';
```

Reemplaza lo que tiene `_guardar()`:

```dart
  void _guardar() {
    FocusScope.of(context).unfocus();

    final MatchReport reporte = MatchReport(
      teamNumber: int.parse(_equipoController.text),
      role: _rolSeleccionado,
      autoPoints: _puntosAutonomo,
      teleopPoints: _puntosTeleoperado,
    );

    debugPrint('$reporte');
  }
```

**Qué decir:**
- `unfocus()` baja el teclado.
- Aquí llenamos la hoja con lo que hay en pantalla: el controller del
  paso 1, el dropdown y los dos contadores. Todos viven en el mismo State, por eso
  los podemos leer (es la idea de la sesión 3).
- `int.parse()`: el `TextField` nos da **texto** (`'6017'`) y el modelo
  pide un **número** (`6017`). `int.parse` convierte uno en el otro.
- `debugPrint` escribe en la terminal.
- **Por ahora, siempre escriban un número de equipo.** Ya veremos qué
  pasa si no (paso 5).

**Probar:** hot reload (`r`), llena el equipo, toca "Guardar reporte" y
mira la terminal: dice `Instance of 'MatchReport'`.

**Preguntar:** *"¿Eso nos sirve?"* No: Dart sabe que es un MatchReport,
pero no sabe cómo escribirlo. Se lo enseñamos con `toString()`.

**Hacer:** en `match_report.dart`, debajo del constructor:

```dart
  @override
  String toString() {
    return 'Equipo: $teamNumber\n'
        'Rol: $role\n'
        'Autónomo: $autoPoints\n'
        'Teleoperado: $teleopPoints';
  }
```

**Qué decir:** todas las clases traen un `toString()` de fábrica (el que
escribe "Instance of..."). `@override` = "reemplazo el de fábrica por el
mío". El `\n` es un salto de línea, y los textos pegados uno junto al otro
se juntan en uno solo. `'$reporte'` usa este `toString()` para convertir
el objeto en texto.

**Probar:** hot reload y guardar otra vez: ahora la terminal escribe el
reporte completo. **La meta de la clase ya funciona**; lo que sigue es
hacerla a prueba de errores.

## Paso 5: romperlo y validar

**Hacer:** borra el número de equipo y toca "Guardar reporte".

**Qué pasa:** no se imprime nada, y en la terminal sale un error
`FormatException`. `int.parse('')` no sabe qué número es un texto vacío.

**Qué decir:** antes de fabricar el reporte hay que **revisar** que no
falte nada. Y tiene que ser **antes**: si revisamos después, el error ya
pasó. Esa revisión la vamos a poner en su propio archivo, igual que
sacamos el botón a `counter_button.dart`: `main.dart` se queda corto y
cada archivo hace una cosa.

**Hacer:** crea la carpeta `lib/utils/` y adentro `reporte_utils.dart`:

```dart
String? campoQueFalta({required String equipo}) {
  if (equipo.isEmpty) {
    return 'Escribe el número de equipo';
  }
  return null;
}
```

**Qué decir:**
- Regresa el mensaje de lo que falta, o `null` si no falta nada. Por eso
  es `String?`: el `?` significa "puede estar vacío".
- `return` termina la función **ahí mismo**.
- Recibe el texto ya leído, no el controller: esta función no necesita
  saber nada de la pantalla.

**Hacer:** en `main.dart`, el import:

```dart
import 'package:session3_match_scouting_form/utils/reporte_utils.dart';
```

Y en `_guardar()`, entre el `unfocus()` y el `final MatchReport reporte`:

```dart
    final String? falta = campoQueFalta(equipo: _equipoController.text);
    if (falta != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(falta)),
      );
      return;
    }
```

**Qué decir:**
- Si algo falta, mostramos el aviso y el `return` termina `_guardar()`:
  nunca se llega a la línea que crea el reporte.
- Un `SnackBar` es el aviso que sale abajo de la pantalla. Este es el que
  trae Flutter; en el paso 6 lo cambiamos por uno más bonito.

**Probar:** hot reload, equipo vacío, guardar: sale el aviso y no truena.

**Segunda forma de romperlo** (hazla en la laptop, no en el celular):
escribe `abc` en el campo de equipo y guarda. Otra vez `FormatException`.
El teclado numérico es solo una sugerencia; en una computadora se puede
escribir cualquier cosa.

**Hacer:** arriba de `main.dart`, debajo del import de material:

```dart
import 'package:flutter/services.dart';
```

En el `TextField` del equipo, debajo de `keyboardType: TextInputType.number,`:

```dart
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
```

**Qué decir:** ahora el campo **solo deja escribir dígitos**, y máximo 5
(el número de equipo más alto de FRC tiene 5 cifras). Por eso `int.parse`
ya no puede fallar.

**Probar:** intenta escribir `abc`: no entra nada.

## Paso 6: un paquete de pub.dev

**Qué decir:** abre [pub.dev](https://pub.dev) en el proyector y busca
`awesome_snackbar_content`. Es la "tienda" de código de Dart: hay paquetes
que otras personas ya escribieron y podemos usar.

**Hacer:** detén la app (`q` en la terminal) y corre:

```bash
flutter pub add awesome_snackbar_content
```

Abre `pubspec.yaml` y muestra que apareció la línea
`awesome_snackbar_content:` en `dependencies:`. Eso es lo único que hizo
el comando. Vuelve a correr la app con `flutter run -d chrome`: un paquete
nuevo **no entra con hot reload**.

**Hacer:** en `reporte_utils.dart`, arriba de todo:

```dart
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
```

Y abajo de `campoQueFalta`, una función nueva:

```dart
void avisarQueFalta(BuildContext context, String mensaje) {
  final SnackBar snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: AwesomeSnackbarContent(
      title: 'Faltan datos',
      message: mensaje,
      contentType: ContentType.failure,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
```

En `_guardar()`, cambia el `ScaffoldMessenger...` del `if` por:

```dart
      avisarQueFalta(context, falta);
```

**Qué decir:**
- Es el mismo `SnackBar` de Flutter, pero invisible (transparente, sin
  sombra) y flotando, con el diseño del paquete adentro. Así lo pide la
  documentación del paquete.
- `ContentType.failure` = rojo con ícono de error. También hay `success`,
  `warning` y `help`.
- ¿Por qué pide `context`? Adentro del State, `context` ya estaba ahí
  solito. Este archivo no es una pantalla, así que no sabe **en qué
  pantalla** mostrar el aviso: se lo tenemos que pasar.

**Probar:** equipo vacío, guardar: sale el aviso rojo. Ahora **toca
"Guardar" cinco veces seguidas**: los avisos se forman en fila y tardan en
irse.

**Hacer:** cambia la última línea de `avisarQueFalta` por:

```dart
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
```

**Qué decir:** los dos puntos `..` significan "y luego, sobre el mismo
objeto". Primero quita el aviso que hay, luego muestra el nuevo.

**Probar:** cinco toques seguidos: ahora solo se ve uno.

## Paso 7: el rol también se valida

**Preguntar:** *"Si el scouter no toca el dropdown, ¿qué rol se guarda?"*
"Ofensivo", aunque nadie lo eligió. Ese dato es mentira.

**Hacer:** cambia la variable del rol:

```dart
  String? _rolSeleccionado;
```

(Era `String _rolSeleccionado = _roles.first;`.)

**Error a propósito:** en `role: _rolSeleccionado,` sale
`The argument type 'String?' can't be assigned to the parameter type 'String'`.

**Qué decir:** el modelo pide un `String` seguro, y le estamos dando un
`String?` que puede estar vacío. Dart no nos deja guardar un reporte sin
rol. Hay que revisarlo antes, igual que el equipo.

**Hacer:** en `reporte_utils.dart`, `campoQueFalta` recibe el rol:

```dart
String? campoQueFalta({
  required String equipo,
  required String? rol,
}) {
```

**Error a propósito:** en `main.dart` sale
`The named parameter 'rol' is required, but there's no corresponding argument`.
Otra vez `required` nos avisa qué falta.

**Hacer:** en `_guardar()`, pásale el rol:

```dart
    final String? falta = campoQueFalta(
      equipo: _equipoController.text,
      rol: _rolSeleccionado,
    );
```

En `campoQueFalta`, antes del `return null;`:

```dart
  if (rol == null) {
    return 'Elige el rol del robot';
  }
```

Y en la creación del reporte, agrega un `!`:

```dart
      role: _rolSeleccionado!,
```

**Qué decir:** el `!` le dice a Dart "ya revisé que no es null, confía en
mí". Dart no puede saberlo solo, porque la revisión pasó en **otra
función**. Pero es verdad: si fuera null, ya nos habríamos salido con el
`return`.

**Hacer:** en el `DropdownButton`, debajo de `value: _rolSeleccionado,`:

```dart
                          hint: const Text(
                            'Elige un rol',
                            style: TextStyle(color: kTintaSuave),
                          ),
```

**Probar:** aquí hay que hacer **hot restart (`R` mayúscula)**, no hot
reload. El hot reload conserva el valor viejo de las variables y el rol
seguiría en "Ofensivo". Con `R` la app arranca de cero y se ve "Elige un
rol". Guarda sin elegir: aviso "Elige el rol del robot".

## Paso 8: un campo nuevo, guiado por los errores

**Qué decir:** a nuestro reporte le falta algo importante: ¿de qué match
es? Vamos a ver cómo `required` nos guía al agregar un campo.

**Hacer:** en `match_report.dart`, agrega el campo y su línea del
constructor:

```dart
  final String matchNumber;
```

```dart
    required this.matchNumber,
```

**Error a propósito:** en `main.dart`, la creación del reporte se pone en
rojo: `The named parameter 'matchNumber' is required, but there's no
corresponding argument`.

**Qué decir:** el editor nos dice exactamente qué falta y dónde. Para
darle ese dato necesitamos un campo de texto nuevo. Es la misma receta que
ya usamos para el equipo:

**Hacer, 8a:** arriba de `main.dart`, debajo de los imports. Es la clave
del evento en The Blue Alliance y cambia en cada competencia:

```dart
const String kEvento = '2026cc';
```

**Hacer, 8b:** un controller nuevo, debajo de `_equipoController`:

```dart
  final TextEditingController _matchController = TextEditingController();
```

**Hacer, 8c:** su `dispose()`, debajo del del equipo. Pregunta antes:
*"¿qué regla vimos en el paso 1?"* Todo controller que creas, lo
liberas.

```dart
    _matchController.dispose();
```

**Hacer, 8d:** el `TextField`. Copia el del equipo, pégalo después del
`SizedBox(height: 24)` que le sigue, y cambia lo que es distinto: la
etiqueta, el controller, el hint y el prefijo. (Al del match le dejamos
solo el filtro de dígitos: no hace falta el límite de 5 porque no se
convierte a número.)

```dart
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
                      decoration: decoracionCampo(
                        hintText: '67',
                        prefixText: '${kEvento}_qm',
                      ),
                    ),

                    const SizedBox(height: 24),
```

**Qué decir:** `decoracionCampo()` (de `estilos.dart`) le da la misma
cajita que al del equipo, sin escribir ni un borde. El `prefixText` es el
mismo truco del `'# '`: se ve escrito pero no hay que teclearlo. El
scouter solo pone `67`.

**Hacer, 8e:** en `reporte_utils.dart`, `campoQueFalta` recibe el match
(entre `equipo` y `rol`) y lo revisa **entre** los dos `if` (mismo orden
que en pantalla):

```dart
  required String match,
```

```dart
  if (match.isEmpty) {
    return 'Escribe el número de match';
  }
```

**Error a propósito:** en `main.dart`, `campoQueFalta(...)` se pone en
rojo pidiendo `match`. Pásaselo:

```dart
      match: _matchController.text,
```

**Hacer, 8f:** ahora sí, el dato que pedía el primer error rojo, en la
creación del reporte, debajo de `teamNumber:`:

```dart
      matchNumber: '${kEvento}_qm${_matchController.text}',
```

**Qué decir:** aquí pegamos los tres pedazos: `'2026cc'` + `'_qm'` +
`'67'` = `'2026cc_qm67'`, que es justo como The Blue Alliance nombra los
matches.

**Hacer, 8g:** en `toString()`, agrega una línea **al principio**:

```dart
    return 'Match $matchNumber\n'
        'Equipo: $teamNumber\n'
```

**Probar:** hot restart (`R`): agregamos un controller nuevo y conviene
arrancar de cero.

## Paso 9: prueba final con todos

Que cada quien pruebe en su app:

- [ ] Guardar con todo vacío: "Escribe el número de equipo".
- [ ] Llenar solo el equipo: "Escribe el número de match".
- [ ] Llenar equipo y match: "Elige el rol del robot".
- [ ] Llenar todo: en la terminal se imprime `Match 2026cc_qm67` y los demás datos.
- [ ] Intentar escribir letras en equipo o match: no entran.
- [ ] Tocar "Guardar" muchas veces con un campo vacío: solo un aviso a la vez.

**Cierre:** hoy el reporte dejó de ser cuatro variables sueltas y se
volvió un objeto. Pregunta para la próxima: *"ahora que tenemos el
reporte en un objeto, ¿cómo lo mostraríamos en pantalla? ¿Y cómo
guardaríamos todos los del día?"*

Para los que acaben antes, están los retos al final del `README.md`.

## Si algo falla en vivo

| Síntoma | Solución |
|---|---|
| Hice un cambio y no se ve | Hot restart con `R` mayúscula |
| `_equipoController.text` imprime vacío | Falta `controller: _equipoController,` en el `TextField` |
| No veo lo que imprime | Mira la terminal donde corre `flutter run` (o la Debug Console de VS Code) |
| `Target of URI doesn't exist` en el import del paquete | Faltó `flutter pub add`, o la app no se reinició después |
| `Undefined name 'FilteringTextInputFormatter'` | Falta `import 'package:flutter/services.dart';` en `main.dart` |
| `Undefined name 'campoQueFalta'` | Falta el import de `utils/reporte_utils.dart` en `main.dart` |
| El rol sigue diciendo "Ofensivo" después del paso 7 | Hot restart con `R` |
| `FormatException` en la terminal | El `if` quedó **después** del `int.parse`, o falta el `inputFormatters` |
| Rojo en `role: _rolSeleccionado` | Falta el `!` (paso 7) |
