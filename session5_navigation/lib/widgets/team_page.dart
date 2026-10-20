import 'package:flutter/material.dart';

import 'package:session5_navigation/widgets/colors.dart';

// La página que se abre al tocar "Ver" en una TeamCard.
// Stateful porque tiene que recordar cuánto duró el último tiempo.
class TeamPage extends StatefulWidget {
  final int teamNumber;
  final String teamName;

  const TeamPage({super.key, required this.teamNumber, required this.teamName});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // NUEVO: un Stopwatch es un cronómetro: start, stop, reset, y nos dice
  // cuánto tiempo pasó.
  final Stopwatch _stopwatch = Stopwatch();

  // El último tiempo medido, en segundos.
  double _seconds = 0;

  @override
  Widget build(BuildContext context) {
    // Es una página completa, así que lleva su propio Scaffold.
    return Scaffold(
      backgroundColor: kBackground,
      // Como esta página llegó con Navigator.push, el AppBar pone solito
      // la flecha de regresar. Tocarla hace Navigator.pop(context): quita
      // esta página de encima y volvemos a la lista.
      // En un State, los parámetros del widget se leen con widget.algo.
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        title: Text(widget.teamName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NUEVO: el mismo tag que en la TeamCard, así Flutter sabe
            // que este número es "el mismo" y lo anima de una página a
            // la otra.
            Hero(
              tag: widget.teamNumber,
              // Mientras vuela, el número no está dentro de ninguna
              // página: Material le da el estilo de texto normal (sin
              // él sale amarillo y subrayado) y FittedBox lo encoge
              // para que quepa en el tamaño que va creciendo.
              child: Material(
                type: MaterialType.transparency,
                child: FittedBox(
                  child: Text(
                    '${widget.teamNumber}',
                    style: const TextStyle(
                      color: kInk,
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // NUEVO: GestureDetector avisa cuando el dedo toca
            // (onTapDown) y cuando se suelta (onTapUp). Un botón normal
            // solo avisa al soltar, por eso no nos sirve.
            GestureDetector(
              onTapDown: (details) {
                _stopwatch.reset();
                _stopwatch.start();
              },
              onTapUp: (details) {
                _stopwatch.stop();
                setState(() {
                  // elapsedMilliseconds son milésimas: entre 1000 da
                  // segundos.
                  _seconds = _stopwatch.elapsedMilliseconds / 1000;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                color: kOrange,
                child: const Text(
                  'Mantén presionado',
                  style: TextStyle(color: kInkOnOrange, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // toStringAsFixed(1): con un solo decimal, 2.4 y no 2.437.
            Text(
              '${_seconds.toStringAsFixed(1)} s',
              style: const TextStyle(color: kInk, fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }
}
