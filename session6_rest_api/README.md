# REST API (traer los equipos del servidor)

Hasta la sesión 5, la lista de equipos estaba **escrita a mano** en el
código. Si llegaba un equipo nuevo a la competencia, había que cambiar
el código y volver a instalar la app. Una app de scouting de verdad no
funciona así: los datos viven en un **servidor** y la app se los pide.

En esta sesión la pestaña Teams deja de usar la lista escrita a mano y
le pide los equipos al servidor de scouting de Cyberius,
`scout.team6017.com`, por medio de su **API**.

Lo nuevo es:

- **Qué es una API REST**: cómo se habla con un servidor (petición y
  respuesta, métodos, URL, headers, status codes y JSON).
- **El paquete `http`**: hace la petición `GET` desde Dart.
- **`async`, `await` y `Future`**: esperar algo que tarda sin congelar
  la app.
- **`jsonDecode`**: convierte el texto JSON en listas y `Map`s de Dart.
- **`initState`**: el lugar para pedir los datos una sola vez, cuando
  aparece la página.
- **`try` / `catch`**: si no hay internet o el servidor falla, mostrar
  un mensaje en vez de que se caiga la app.
- **`CircularProgressIndicator`**: la ruedita de "cargando".

## ¿Qué es una API?

Piensa en un **restaurante**. Tú (la app) no entras a la cocina (el
servidor y su base de datos) a sacar la comida. Le pides al **mesero**,
y el mesero te trae lo que pediste. La **API** es el mesero: la forma
acordada de pedirle cosas al servidor. El **menú** es la documentación:
dice qué se puede pedir y cómo.

API significa *Application Programming Interface*: una "ventanilla"
para que un programa hable con otro programa.

El menú de nuestra API está en
[scout.team6017.com/docs](https://scout.team6017.com/docs). Ahí se ven
todos los endpoints y se pueden probar desde el navegador.

## ¿Y qué es REST?

REST es un estilo para diseñar APIs que usa lo mismo que la web. Cada
cosa (equipos, matches, reportes) tiene su propia **dirección (URL)**, y
lo que quieres hacer con ella lo dice el **método**:

- **GET**: dame algo (leer). Es el que usamos hoy.
- **POST**: aquí va algo nuevo (crear), por ejemplo un reporte de match.
- **PUT** / **PATCH**: cambia algo que ya existe.
- **DELETE**: borra algo.

## Una petición, pieza por pieza

Este es el `curl` (un programa de la terminal que hace peticiones) que
pide la lista de equipos:

```bash
curl -X 'GET' \
  'https://scout.team6017.com/api/v1/teams/' \
  -H 'accept: */*' \
  -H 'X-Admin-Api-Key: <la llave>'
```

- `-X 'GET'`: el **método**. Solo queremos leer.
- `https://scout.team6017.com/api/v1/teams/`: la **URL** o
  **endpoint**. `scout.team6017.com` es el servidor, `/api/v1/` dice que
  es la versión 1 de la API, y `teams/` es la cosa que queremos.
- `-H '...'`: los **headers**, datos extra que viajan con la petición.
  `accept: */*` dice "acepto cualquier formato". `X-Admin-Api-Key` es
  la **llave de la API**: demuestra que tenemos permiso. Sin ella, el
  servidor no nos da nada.

## La respuesta

El servidor contesta con dos cosas importantes:

- El **status code**, un número que dice cómo le fue a la petición:
  **200** todo bien, **401** no autorizado (falta la llave o está mal),
  **404** eso no existe, **500** el servidor falló. Regla fácil: los 200
  son éxito, los 400 son culpa de quien pide, los 500 son culpa del
  servidor.
- El **body** (cuerpo): los datos, escritos en **JSON**.

JSON es texto con dos formas de agrupar datos:

- `[ ... ]` es una **lista**, igual que una `List` de Dart.
- `{ "llave": valor }` es un **objeto**: parejas llave-valor, que en
  Dart es un `Map`. Con la llave encuentras el valor, como en un
  diccionario.

Nuestra respuesta es una lista de objetos, uno por equipo:

```json
[
  {"number": 6017, "name": "PrepaTec - Cyberius", "city": "Santa Catarina", "country": "Mexico"},
  {"number": 4635, "name": "PrepaTec - Botbusters", "city": "Monterrey", "country": "Mexico"}
]
```

En Dart, después de `jsonDecode`, el primer equipo es `teams[0]` y su
nombre es `teams[0]['name']`.

## Los archivos

- `lib/api.dart`: **nuevo**. La URL, la llave y `fetchTeams()`, la
  función que hace el `GET`. Es el único archivo que habla con internet.
- `lib/teams_page.dart`: ahora es `StatefulWidget`. Pide los equipos en
  `initState` y muestra la ruedita, el error o la lista.
- `lib/team_card.dart` y `lib/team_page.dart`: reciben también el
  nombre del equipo.
- `lib/main.dart`, `lib/template_page.dart`, `lib/colores.dart`: igual
  que en la sesión 5.

## Paso a paso

Empieza donde terminó la sesión 5 en vivo: la lista de números escrita a
mano, las `TeamCard` con flecha y la `TeamPage` con el cronómetro. Cada
paso termina con la app corriendo.

### Paso 0: limpieza

En `main.dart`, mover `selectedIndex`, `paginas` y `destinations` adentro
de `_MainAppState` (antes de `build`), poner `selectedIndex = 0` para
abrir en Teams, cambiar la etiqueta `"teams"` por `"Teams"` y quitar el
`print`.

Correr: la app abre en la lista de equipos.

### Paso 1: probar la API sin Flutter

Abrir [scout.team6017.com/docs](https://scout.team6017.com/docs), buscar
`GET /api/v1/teams/`, poner la llave en **Authorize** y darle **Try it
out** → **Execute**. Ver el status code y el JSON.

Luego, en la terminal, el mismo `GET` con `curl`. Primero **sin** la
llave:

```bash
curl -i 'https://scout.team6017.com/api/v1/teams/'
```

Sale `401`. Después con el `-H 'X-Admin-Api-Key: ...'`: sale `200` y el
JSON. Pregunta para la clase: ¿qué es la lista y qué es cada equipo en
ese texto? (Los `[ ]` y los `{ }`.)

### Paso 2: el paquete http

```bash
flutter pub add http
```

Correr: la app sigue igual; solo agregamos la herramienta.

### Paso 3: el primer GET desde Dart

Crear `lib/api.dart` con `kTeamsUrl`, `kApiKey` y `fetchTeams()`. Poner
el `curl` y el `http.get` lado a lado: cada `-H` es una pareja en
`headers`.

Convertir `TeamsPage` en `StatefulWidget` y, en `initState`, pedir los
equipos e imprimirlos:

```dart
@override
void initState() {
  super.initState();
  _loadTeams();
}

Future<void> _loadTeams() async {
  List<dynamic> teams = await fetchTeams();
  debugPrint(teams.toString());
}
```

Correr: la lista en pantalla sigue siendo la escrita a mano, pero en la
terminal sale el JSON que mandó el servidor. Aquí se explica `async`,
`await` y por qué la petición va en `initState` y no en `build`.

### Paso 4: mostrar los equipos del servidor

Borrar `_teamNumbers`. Agregar `List<dynamic> _teams = []` al `State`,
guardarla con `setState` en `_loadTeams`, y en el `ListView` sacar el
número de cada `Map`:

```dart
setState(() {
  _teams = teams;
});
```

```dart
children: _teams.map((team) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: TeamCard(teamNumber: team['number']),
  );
}).toList(),
```

Correr: un instante la lista está vacía y luego aparecen los equipos
del servidor. Pregunta: ¿por qué empieza vacía? (`build` corre antes de
que llegue la respuesta; `setState` lo vuelve a correr cuando llega.)

### Paso 5: el nombre de cada equipo

Agregar `final String teamName` a `TeamCard` y a `TeamPage`. Pasarlo
con `teamName: team['name']` y en el `Navigator.push`. En la tarjeta,
el nombre va en un `Expanded` entre el número y la flecha, para que los
nombres largos no se salgan. En `TeamPage`, un `Text` debajo del número.

Correr: cada tarjeta y cada página muestran el nombre que mandó el
servidor. Lo que antes era imposible sin escribirlo a mano.

### Paso 6: cargando y errores

Agregar `bool _loading = true` y `String _error = ''`. En `build`,
antes de la lista:

```dart
if (_loading) {
  return const Center(child: CircularProgressIndicator());
}
if (_error != '') {
  return Center(child: Text('No se pudieron cargar los equipos:\n$_error'));
}
```

Envolver `_loadTeams` en `try` / `catch`, y antes de cada `setState`
poner `if (!mounted) return;` (si el usuario cambió de pestaña mientras
esperábamos, la página ya no existe).

Correr: sale la ruedita y luego la lista. Para ver el error, cambiar una
letra de la llave: sale "El servidor respondió 401". Volver a dejarla
bien.

## Para el mentor

- La llave está escrita en `lib/api.dart` y se publica dentro del build
  web, así que cualquiera que abra la demo la puede ver.
- Si en Chrome sale `ClientException: Failed to fetch`, es **CORS**: el
  servidor solo acepta peticiones desde los orígenes que tiene
  permitidos. `localhost` (`flutter run -d chrome`) sí está permitido;
  la demo publicada necesita `https://ads.team6017.com` en la lista del
  servidor.
- Cada vez que se regresa a la pestaña Teams, la página se crea de nuevo
  y vuelve a pedir los equipos.

## Para probar

```bash
flutter pub get
flutter run -d chrome
flutter test
```

Las pruebas no van a internet: usan un `MockClient` del paquete `http`
que contesta en lugar del servidor.
