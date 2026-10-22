import 'package:flutter/material.dart';
import 'package:session6_rest_api/colores.dart';

// Una página "molde": la misma pantalla sirve para varias pestañas,
// solo cambia el título, que llega por el constructor.
class TemplatePage extends StatelessWidget {
  final String title;

  const TemplatePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: kNaranja,
          ),
        ),
        backgroundColor: kTinta,
      ),
      backgroundColor: kFondo,
      body: Center(
        child: Text(
          "This page is for $title",
          style: const TextStyle(
            color: kTintaNaranja,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
