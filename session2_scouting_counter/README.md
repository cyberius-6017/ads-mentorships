# Match Piece Counter — Sesión 2 de Mentoría

App de práctica para la sesión 2: recap de Dart, concepto de widget tree,
`StatelessWidget` vs `StatefulWidget`, y widgets de layout básicos
(`Container`, `Row`, `Column`, `Padding`, `Center`, `SizedBox`).

Simula el conteo de piezas anotadas durante un match de FRC: Gol Alto,
Gol Bajo y Fallado, con un total en vivo y un botón de reinicio.

Sin paquetes externos — solo el SDK de Flutter. Alcanza con
`flutter create` + `flutter run` para seguir la sesión.

## Qué demuestra cada archivo

- **`lib/widgets/match_header.dart`** — `MatchHeader`, un
  `StatelessWidget`. Muestra el número de match y equipo, datos que no
  cambian en pantalla. Usa `Container` (caja con color de fondo),
  `Center` (para centrar contenido dentro de un Container más ancho que
  el texto), `Column` (apilar dos textos verticalmente) y `SizedBox`
  (espacio fijo entre ellos).

- **`lib/widgets/counter_card.dart`** — `CounterCard`, un
  `StatefulWidget`. Cada tarjeta guarda su propio conteo (`_conteo`) y lo
  actualiza con `setState()` al tocar "+1". Avisa el cambio hacia arriba
  con el callback `onCambio`. Es el corazón de la clase: acá se ve en
  vivo la diferencia entre Stateless (el header) y Stateful (esto).

- **`lib/widgets/total_display.dart`** — `TotalDisplay`, un
  `StatelessWidget` que solo *muestra* un número que recibe por
  parámetro. No guarda nada: el estado real vive en `HomeScreen`. Esto
  enseña el patrón de "levantar el estado" (lifting state up).

- **`lib/main.dart`** — `MatchPieceCounterApp` (Stateless, configura
  tema y título) y `HomeScreen` (Stateful, dueña de los tres conteos y
  del total). Arma la pantalla completa con `Column` (secciones
  apiladas), `Row` (los tres `CounterCard` lado a lado, como botones
  físicos de un scout) y `Padding` (separar el contenido de los bordes
  de la pantalla). Acá se ve cómo un solo cambio de estado (tocar "+1"
  en una tarjeta) puede actualizar dos partes distintas de la UI a la
  vez: la tarjeta y el total.

## Orden sugerido para armar la app en vivo (sesión de 2 horas)

1. **Recap de Dart** (20 min) — variables, tipos, funciones, clases,
   fuera del código de Flutter, en un `.dart` suelto o en DartPad.
2. **`flutter create` + explorar `main.dart` por defecto** (10 min) —
   mostrar `runApp`, `MaterialApp`, y el concepto de "árbol de widgets".
3. **`MatchHeader`** (20 min) — primer widget custom, Stateless. Armar
   `Container` + `Center` + `Column` + `SizedBox` paso a paso, mostrando
   hot reload después de cada cambio.
4. **`CounterCard` sin estado, solo layout** (15 min) — armar el
   `Container` con el título, número fijo en 0, y el botón, ANTES de
   agregar `setState`. Mostrar que tocar el botón no hace nada todavía.
5. **Convertir a StatefulWidget** (20 min) — el momento clave de la
   clase: agregar `State`, la variable `_conteo`, y `setState()` dentro
   de `_incrementar()`. Mostrar que ahora sí el número cambia en
   pantalla.
6. **Tres `CounterCard` en un `Row`** (15 min) — armar `HomeScreen`,
   meter los tres contadores en un `Row` con `Expanded` y `SizedBox`
   entre ellos.
7. **`TotalDisplay` y levantar el estado** (15 min) — agregar el
   callback `onCambio`, el `Map` de conteos en `HomeScreen`, y el
   getter `_total`. Mostrar que el total se actualiza solo.
8. **Botón "Reiniciar Match"** (15 min) — segundo uso de `setState()`,
   y el truco de cambiar la `key` para reiniciar los `CounterCard`.
9. **Cierre y preguntas** (10 min).

## Preguntas de control (checkpoints)

1. Después del paso 5 (convertir `CounterCard` a Stateful): *"¿Por qué
   `MatchHeader` puede seguir siendo Stateless pero `CounterCard` no?
   ¿Qué pasaría si `CounterCard` también fuera Stateless y tocáramos el
   botón +1?"*
2. Después del paso 7 (`TotalDisplay`): *"`TotalDisplay` es Stateless y
   nunca llama a `setState()`. Entonces, ¿cómo hace para mostrar un
   número distinto cada vez que tocamos un +1?"*
3. En cualquier punto del layout: *"¿Por qué en `HomeScreen` usamos
   `Column` para las secciones pero `Row` para los tres contadores? ¿Qué
   pasaría si los tres contadores estuvieran en una `Column` en vez de
   un `Row`?"*

## Por qué importa esto

Esta app es una versión mini y honesta de lo que van a construir de
verdad: la app de scouting del equipo va a tener las mismas ideas
centrales (una pantalla que recuerda datos mientras el scout mira un
match, y los actualiza en vivo con `setState`), solo que con más
pantallas, más datos y guardado persistente.
