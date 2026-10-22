import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:session6_rest_api/colores.dart';

// La página que se abre al tocar una TeamCard.
class TeamPage extends StatefulWidget {
  final int teamNumber;
  // NUEVO: el nombre que llegó del servidor.
  final String teamName;

  const TeamPage({super.key, required this.teamNumber, required this.teamName});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // Un cronómetro: start, stop, reset, y nos dice cuánto tiempo pasó.
  final Stopwatch _stopwatch = Stopwatch();

  double seconds = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: Hero(
          tag: widget.teamNumber,
          child: Text("Team ${widget.teamNumber}"),
        ),
        backgroundColor: kAzul,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              widget.teamNumber.toString(),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ).animate().rotate(),

            // NUEVO: el nombre del equipo, debajo del número.
            Text(
              widget.teamName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, color: kTinta),
            ),

            GestureDetector(
              onTapDown: (details) {
                _stopwatch.reset();
                _stopwatch.start();
              },
              onTap: () {
                setState(() {
                  seconds = _stopwatch.elapsedMilliseconds / 1000;
                });
              },
              onTapUp: (details) {
                _stopwatch.stop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: kNaranja,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(8),
                child: const Text(
                  "Count Time",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            Text("$seconds s", style: const TextStyle(fontSize: 30)),
          ],
        ),
      ),
    );
  }
}
