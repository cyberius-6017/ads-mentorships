import 'package:flutter/material.dart';

import 'package:session5_navigation/widgets/colors.dart';
import 'package:session5_navigation/widgets/team_page.dart';

// Una tarjeta por equipo. Necesita saber el número y el nombre.
class TeamCard extends StatelessWidget {
  final int teamNumber;
  final String teamName;

  const TeamCard({super.key, required this.teamNumber, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // NUEVO: Hero marca este número para que "vuele" hasta el
            // Hero con el mismo tag en TeamPage al abrirla.
            Hero(
              tag: teamNumber,
              child: Text(
                '$teamNumber',
                style: const TextStyle(
                  color: kInk,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Expanded: el nombre ocupa el espacio de en medio y empuja
            // el botón hasta la derecha.
            Expanded(
              child: Text(
                teamName,
                style: const TextStyle(color: kInk, fontSize: 16),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Navigator.push pone una página nueva ENCIMA de la
                // actual, como una carta sobre otra. La página de abajo
                // (con la navbar) sigue ahí esperando.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeamPage(teamNumber: teamNumber, teamName: teamName),
                  ),
                );
              },
              child: const Text('Ver'),
            ),
          ],
        ),
      ),
    );
  }
}
