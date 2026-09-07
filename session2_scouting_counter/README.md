# Count Fuel (contador de scouting)

Una app chiquita con un solo botón: cada vez que lo tocas, un número sube de
uno en uno. Suena simple, pero es exactamente el mecanismo que usa un
scouter en una competencia de FRC para llevar la cuenta de cuántas veces un
robot metió un elemento de juego. Este proyecto existe para enseñar **una
sola idea**, la más importante de Flutter: la diferencia entre un widget
que nunca cambia y un widget que **recuerda** algo y se **redibuja** solo.

## ¿Por qué esta app y no otra cosa?

En la sesión anterior (`session1_i_am_rich`) vimos una app que solo muestra
una imagen fija: nunca cambia, nunca reacciona a nada. Esta app es el
siguiente paso: necesita **memoria**. El contador tiene que recordar en
qué número va, aunque toquemos el botón cien veces. Para eso Flutter tiene
dos tipos de widgets:

- **`StatelessWidget`**: se dibuja una vez y ya. No tiene memoria propia.
  Lo usamos para `MainApp`, que solo arma la app y no necesita recordar nada.
- **`StatefulWidget`**: sí tiene memoria (su `State`). Lo usamos para
  `CounterScreen`, porque necesita recordar el valor del contador entre un
  toque de botón y el siguiente.

Todo el código está en `lib/main.dart`, comentado línea por línea.

## El truco que hay que entender: `setState()`

Esta es la parte que más confunde al principio, así que va despacio:

```dart
void _incrementar() {
  setState(() {
    _contador++;
  });
}
```

Si solo hiciéramos `_contador++;` sin el `setState()`, el número
**sí cambiaría** en la memoria de la app... pero la pantalla nunca se
enteraría, porque Flutter no vuelve a dibujar nada a menos que se lo
pidas explícitamente. `setState()` es exactamente ese aviso: le dice a
Flutter "algo cambió adentro de este widget, vuelve a llamar a `build()`
y dibuja de nuevo con el valor nuevo". Sin `setState()`, el contador
estaría "roto" en la práctica aunque el número sí esté cambiando por
detrás.

## Requisitos previos

- Tener instalado el [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Confirmar que todo esté bien instalado:

  ```bash
  flutter doctor
  ```

## Cómo correr el proyecto

1. Entra a la carpeta del proyecto:

   ```bash
   cd session2_scouting_counter
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

4. Vas a ver el título "Count Fuel", un número en `0`, y un botón naranja
   que dice "Incrementar". Cada vez que lo toques, el número sube uno.

## Estructura del proyecto

```
session2_scouting_counter/
├── android/, ios/, linux/, macos/, windows/, web/  # generado por Flutter
├── lib/
│   └── main.dart      # toda la app: MainApp + CounterScreen, comentado
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md           # este archivo
```

## Para experimentar

Con la app corriendo (`flutter run`), prueba estos cambios en
`lib/main.dart`, guarda y presiona `r` en la terminal para ver el
resultado al instante (hot reload):

- Cambia `_contador++;` por `_contador += 5;` — el botón ahora suma de 5
  en 5.
- Agrega un segundo botón que reste, con su propia función `_decrementar()`
  que también use `setState()`.
- Cambia el texto `"Incrementar"` por `"Elemento anotado"`, como se vería
  en una app de scouting de verdad.

Si en algún cambio olvidas el `setState()` a propósito, vas a ver el bug
más común de Flutter: el valor cambia pero la pantalla se queda congelada
en el número viejo. Es una buena forma de sentir, en carne propia, por qué
existe `setState()`.
