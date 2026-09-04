import 'package:flutter/material.dart';

// Punto de entrada: lo primero que corre en toda app Flutter.
void main() {
  runApp(const MainApp());
}

// MainApp es Stateless porque solo arma el MaterialApp (tema, título).
// No tiene ningún dato que cambie con el tiempo.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterScreen(),
    );
  }
}

// CounterScreen es Stateful porque necesita RECORDAR un número (el
// contador) y ACTUALIZAR la pantalla cada vez que tocamos el botón.
// Un StatelessWidget no puede hacer esto: se construye una sola vez.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  // Esta variable vive en el State, no en el Widget: es el dato que
  // "recordamos" entre un build y el siguiente.
  int _contador = 0;

  void _incrementar() {
    // setState() le avisa a Flutter: "algo cambió, volvé a dibujar".
    // Si solo hiciéramos _contador++ sin setState(), el número
    // cambiaría en memoria pero la pantalla nunca se enteraría.
    setState(() {
      _contador++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(201, 237, 255, 1),
      body: Center(
        // Column: apilamos el título, el número y el botón uno debajo
        // del otro (eje vertical).
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Count Fuel",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            // SizedBox: deja un espacio fijo entre el título y el
            // número, sin necesidad de envolver nada en Padding.
            const SizedBox(height: 20),

            // Este Text muestra el valor de _contador. Cada vez que
            // setState() corre, este widget se reconstruye con el
            // valor nuevo.
            Text(
              "$_contador",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 100),

            // Container: le da un ancho fijo al botón, para que no
            // ocupe todo el ancho de la pantalla como haría por
            // defecto un ElevatedButton dentro de una Column.
            Container(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(249, 104, 21, 1),
                ),
                onPressed: (() {
                print("Boton apretado");
                _incrementar();
                print("funcion mandada a llamar");
                }),
                child: const Center(child: Text("Incrementar")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
