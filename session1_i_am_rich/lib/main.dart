import 'package:flutter/material.dart';

// Punto de entrada de la app: Flutter llama a main() al arrancar.
void main() {
  // Aqui va todo el pre procesamiento necesario antes de que abra la app
  // Por ejemplo cargar una base de datos local, contactar un servidor, authenticacion, etc, etc
  // runApp() toma un widget raíz y lo dibuja en pantalla.
  runApp(const DiamondApp());
}

// Widget raíz de la app. Es "Stateless" porque nunca cambia: siempre
// muestra lo mismo, sin estado que actualizar.
class DiamondApp extends StatelessWidget {
  const DiamondApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configura la app (título, tema, pantalla inicial, etc.).
    return MaterialApp(
      title: 'I Am Rich',

      // Con esto se quita la cinta que dice "DEBUG" arriba a la derecha de tu app cuando estas desarrolando
      debugShowCheckedModeBanner: false,

      // Unica pantalla de la app.
      home: Scaffold(
      backgroundColor: Colors.black,

      body: SizedBox(
        // Ocupa toda la pantalla disponible.
        width: double.infinity,
        height: double.infinity,
        
        // Es child ya que va adentro (o abajo) de la SizedBox
        // Image.asset carga la imagen desde tus assets definidos en pubspec.yaml
        // Si cargas un nuevo asset al proyecto, tienes que parar la aplicacion y volverla a correr
        // BoxFit.cover hace que la imagen cubra todo el espacio,
        
        child: Image.asset("assets/images/rayo.jpeg", fit: BoxFit.cover,),
        // Image.network carga la imagen desde una URL externa.
        // recortando lo que sobre si la proporción no coincide.
        // child: Image.network(
        //   'https://i.etsystatic.com/38852001/r/il/d11654/4454191033/il_fullxfull.4454191033_9wkm.jpg',
        //   fit: BoxFit.cover,
        // ),
      ),
    ),
    );
  }
}

