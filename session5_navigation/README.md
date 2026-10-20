# Navigation (navbar y cambiar de página)

Hasta la sesión 4, toda la app era **una sola pantalla**. Una app de
scouting de verdad tiene varias: scouting de match, scouting de pits, la
lista de equipos, la picklist... Esta sesión enseña a moverse entre ellas
de las dos formas que existen:

1. **Pestañas con una barra abajo** (`NavigationBar`): las páginas están
   "lado a lado" y la barra escoge cuál se ve.
2. **Una página encima de otra** (`Navigator.push` y `pop`): al tocar un
   botón se abre una página nueva *encima*, y la flecha de regresar la
   quita.

Lo nuevo es:

- **`NavigationBar`**: la barra de abajo. Recuerda la pestaña elegida en
  un `int` dentro de un `StatefulWidget`, igual que el contador de la
  sesión 2, y el `body` del `Scaffold` cambia según ese número.
- **`TemplatePage`**: una página "molde" con dos parámetros, `title` y
  `buttonLabel`. La misma clase sirve para cuatro pestañas distintas.
- **`ListView`**: una `Column` que se puede scrollear.
- **`.map(...).toList()`**: ya lo usamos en el dropdown de la sesión 4;
  ahora convierte una lista de números de equipo en una lista de
  `TeamCard`.
- **`Navigator.push` / `Navigator.pop`**: abrir la página de un equipo y
  regresar.
- **`Map`**: parejas "llave: valor", como un diccionario. Aquí guarda el
  nombre de cada equipo usando su número como llave.
- **`.where(...)`**: el hermano de `.map()`. `.map()` cambia cada
  elemento; `.where()` se queda solo con los que cumplen una condición.
  Con él hacemos el buscador.
- **`Hero`**: el número del equipo "vuela" de la tarjeta a su página.
- **`GestureDetector` + `Stopwatch`**: un cronómetro que mide cuánto
  tiempo mantienes presionado un botón (por ejemplo, cuánto tarda un
  robot en escalar).

## Dos formas de navegar

Piensa en la navbar como las **pestañas de un cuaderno**: todas las
secciones existen al mismo tiempo y tú escoges cuál abrir.

`Navigator.push` es como **poner una hoja encima de la pila**: la de
abajo sigue ahí, tapada. `Navigator.pop` quita la hoja de arriba y vuelve
a aparecer la de abajo, tal como la dejaste.

## Los archivos

- `lib/main.dart`: la app, la navbar y la lista de equipos.
- `lib/widgets/colors.dart`: los colores del equipo (los mismos de
  siempre).
- `lib/widgets/template_page.dart`: la página molde.
- `lib/widgets/teams_page.dart`: la pestaña Teams: el `Map` de equipos
  y el buscador.
- `lib/widgets/team_card.dart`: la tarjeta de un equipo, con el
  `Navigator.push` y el `Hero`.
- `lib/widgets/team_page.dart`: la página del equipo, con el número y el
  cronómetro.

## Paso a paso

Cada paso termina con la app corriendo. Si la clase se corta en
cualquier punto, nadie se queda con la app rota.

### Paso 1: la base

Crear el proyecto y copiar los colores a `lib/widgets/colors.dart`. En
`main.dart`, un `MaterialApp` con un `Scaffold` que tenga `AppBar` azul y
fondo azul claro.

Correr: se ve la barra azul y la pantalla vacía.

### Paso 2: TemplatePage

Escribir `TemplatePage` (un `StatelessWidget` con `title` y
`buttonLabel`) y ponerla como `body`:

```dart
body: const TemplatePage(title: 'Match Scouting', buttonLabel: 'Nuevo reporte'),
```

Correr: al tocar el botón, el texto sale en la terminal (`debugPrint`).
Cambiar los parámetros y ver que la misma página dice otra cosa.

### Paso 3: la navbar (todavía no cambia nada)

Convertir la pantalla en `StatefulWidget` con `int _selectedIndex = 0`.
Agregar `bottomNavigationBar: NavigationBar(...)` con las 5
`NavigationDestination` y, en `onDestinationSelected`, guardar el índice
con `setState`.

Correr: la pestaña marcada se mueve, pero la página sigue siendo la
misma. Pregunta para la clase: ¿por qué? (El `body` no usa
`_selectedIndex` todavía.)

### Paso 4: una página por pestaña

Hacer una lista `pages` con una página por pestaña, **en el mismo orden
que la navbar**, y usar el índice para escoger:

```dart
body: pages[_selectedIndex],
```

Por ahora la pestaña de en medio también es una `TemplatePage` con
título "Teams".

Correr: cada pestaña muestra su propia página.

### Paso 5: la lista de equipos

Escribir `TeamCard` (recibe `teamNumber`), con el botón "Ver" y
`onPressed: () {}` vacío por ahora. Agregar la lista de números y
cambiar la pestaña Teams por:

```dart
ListView(
  children: _teamNumbers.map((int number) {
    return TeamCard(teamNumber: number);
  }).toList(),
),
```

Correr: aparecen las 10 tarjetas y se puede scrollear.

### Paso 6: abrir la página del equipo

Escribir `TeamPage` (con su propio `Scaffold` y `AppBar`) y llenar el
`onPressed` de `TeamCard`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TeamPage(teamNumber: teamNumber),
  ),
);
```

Correr: "Ver" abre la página del equipo. El `AppBar` puso solito la
flecha de regresar, que hace `Navigator.pop(context)` por nosotros. Al
regresar, seguimos en la pestaña Teams: la página de abajo nunca se fue.

### Paso 7: nombres con un Map

Mover la lista a su propio widget `TeamsPage` y cambiar la `List<int>`
por un `Map<int, String>`:

```dart
final Map<int, String> _teams = {
  6017: 'Cyberius',
  254: 'The Cheesy Poofs',
};
```

Agregar `teamName` a `TeamCard` y a `TeamPage`, y recorrer el `Map` con
`.entries` (cada pareja tiene `.key` y `.value`):

```dart
children: _teams.entries.map((entry) {
  return TeamCard(teamNumber: entry.key, teamName: entry.value);
}).toList(),
```

Correr: cada tarjeta muestra número y nombre, y la página del equipo
tiene el nombre en el `AppBar`.

### Paso 8: el buscador

Convertir `TeamsPage` en `StatefulWidget` con `String _search = ''`.
Poner un `TextField` arriba de la lista (en una `Column`, con la lista
dentro de un `Expanded`) que guarde el texto con `setState`, y filtrar
antes del `.map()`:

```dart
.where((entry) {
  return '${entry.key} ${entry.value}'.toLowerCase().contains(_search);
})
```

Correr: escribir "poofs" o "6017" deja solo ese equipo.

### Paso 9: Hero

Envolver el número en `TeamCard` y en `TeamPage` con un `Hero` con el
**mismo** `tag`:

```dart
Hero(tag: teamNumber, child: ...)
```

En `TeamPage`, el hijo del `Hero` va dentro de
`Material(type: MaterialType.transparency, child: FittedBox(child: ...))`.
Mientras vuela, el número no está dentro de ninguna página: sin
`Material` sale amarillo y subrayado, y sin `FittedBox` no cabe.

Correr: al tocar "Ver", el número vuela de la tarjeta al centro.

### Paso 10: el cronómetro

Convertir `TeamPage` en `StatefulWidget` (los parámetros ahora se leen
con `widget.teamNumber`). Agregar un `Stopwatch` y un
`double _seconds = 0`, y un `GestureDetector` que arranque al tocar y
pare al soltar:

```dart
onTapDown: (details) {
  _stopwatch.reset();
  _stopwatch.start();
},
onTapUp: (details) {
  _stopwatch.stop();
  setState(() {
    _seconds = _stopwatch.elapsedMilliseconds / 1000;
  });
},
```

Correr: mantener presionado el botón naranja y ver los segundos.

## Para probar

```bash
flutter pub get
flutter run -d chrome
flutter test
```
