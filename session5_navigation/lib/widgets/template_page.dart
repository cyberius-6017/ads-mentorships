import 'package:flutter/material.dart';

import 'package:session5_navigation/widgets/colors.dart';

// Una página "molde": la misma pantalla sirve para varias pestañas,
// solo cambian el título y el texto del botón, que llegan por el
// constructor (igual que el CounterButton de la sesión 3).
class TemplatePage extends StatelessWidget {
  final String title;
  final String buttonLabel;

  const TemplatePage({
    super.key,
    required this.title,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kInk,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrange,
              foregroundColor: kInkOnOrange,
            ),
            // Se imprime en la terminal donde corre `flutter run`.
            onPressed: () {
              debugPrint(buttonLabel);
            },
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
