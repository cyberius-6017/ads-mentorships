import 'package:flutter/material.dart';
import 'package:session6_rest_api/team_page.dart';

// Una tarjeta por equipo.
class TeamCard extends StatelessWidget {
  final int teamNumber;
  // NUEVO: el nombre, que ahora sí tenemos porque lo manda el servidor.
  final String teamName;

  const TeamCard({super.key, required this.teamNumber, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push pone la página del equipo ENCIMA de la lista.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TeamPage(teamNumber: teamNumber, teamName: teamName),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: Row(
            children: [
              Hero(tag: teamNumber, child: Text(teamNumber.toString())),
              const SizedBox(width: 16),
              // Expanded: el nombre ocupa el espacio de en medio y empuja
              // la flecha a la derecha. Si el nombre es largo, se parte en
              // dos renglones en vez de salirse de la tarjeta.
              Expanded(child: Text(teamName)),
              const Icon(Icons.arrow_right),
            ],
          ),
        ),
      ),
    );
  }
}
