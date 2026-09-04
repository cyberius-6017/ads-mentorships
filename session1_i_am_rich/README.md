# I Am Rich (réplica educativa)

Réplica minimalista de **"I Am Rich"**, una app para iPhone publicada en agosto
de 2008 por el desarrollador Armin Heinrich. Costaba **999.99 USD** y su única
"función" era mostrar una imagen fija de un rubí/diamante rojo brillante a
pantalla completa. No tenía ningún otro botón, menú ni funcionalidad: existía
puramente como un símbolo de estatus (comprarla solo para demostrar que
podías pagar mil dólares por nada). Apple la retiró de la App Store poco
después de su lanzamiento, pero se convirtió en un caso de estudio clásico
sobre diseño mínimo, precio como señal social, y "apps inútiles" con
propósito puramente simbólico.

Este proyecto la recrea con **fines didácticos**: sirve como el ejemplo más
simple posible de una app Flutter completa (un solo widget, una sola
imagen, sin manejo de estado ni paquetes externos), pensado para quien nunca
ha visto Flutter/Dart antes. Todo el código en `lib/main.dart` está
comentado línea por línea explicando qué hace cada parte.

Este es un proyecto Flutter **estándar y completo**, generado con
`flutter create`: incluye las carpetas nativas para todas las plataformas
soportadas (`android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/`), la
carpeta `lib/` con el código Dart, y `test/` con una prueba básica.

## Requisitos previos

- Tener instalado el [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Verificar que todo esté correctamente instalado con:

```bash
flutter doctor
```

## Cómo correr el proyecto

1. Entra a la carpeta del proyecto:

   ```bash
   cd i_am_rich
   ```

2. Descarga las dependencias declaradas en `pubspec.yaml`:

   ```bash
   flutter pub get
   ```

3. Corre la app (con un emulador/simulador abierto, un dispositivo físico
   conectado, o en modo escritorio/web si tu entorno lo soporta):

   ```bash
   flutter run
   ```

4. Verás una única pantalla negra con la imagen del diamante rojo centrada y
   cubriendo toda la pantalla. Eso es todo lo que hace la app, ¡tal como el
   original!

## Estructura del proyecto

```
i_am_rich/
├── android/                  # Proyecto nativo de Android (generado por Flutter)
├── ios/                      # Proyecto nativo de iOS (generado por Flutter)
├── linux/, macos/, windows/  # Soporte para escritorio (generado por Flutter)
├── web/                      # Soporte para web (generado por Flutter)
├── assets/
│   └── images/
│       └── diamond.png        # La imagen del diamante rojo
├── lib/
│   └── main.dart               # Toda la lógica de la app (comentada línea por línea)
├── test/
│   └── widget_test.dart        # Prueba básica: verifica que la imagen se muestra
├── pubspec.yaml                 # Configuración del proyecto y declaración de assets
└── README.md                    # Este archivo
```

Las carpetas nativas (`android/`, `ios/`, etc.) son generadas automáticamente
por Flutter y normalmente no necesitas tocarlas para este proyecto; solo se
usan cuando compilas para esa plataforma específica (por ejemplo,
`flutter build apk` para Android o `flutter build ios` para iOS).

## Experimenta con hot reload

Con la app corriendo (`flutter run`), prueba cambiar algo en
`lib/main.dart` (por ejemplo el color de fondo `Colors.black` por
`Colors.blue`), guarda el archivo y presiona `r` en la terminal donde
corre Flutter. Verás el cambio reflejado casi al instante, sin reiniciar la
app por completo. Esto se explica con más detalle en los comentarios al
final de `lib/main.dart`.
