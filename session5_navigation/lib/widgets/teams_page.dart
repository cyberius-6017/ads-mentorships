import 'package:flutter/material.dart';

import 'package:session5_navigation/widgets/team_card.dart';

// La pestaña Teams: un buscador y la lista de equipos.
// Stateful porque tiene que recordar lo que se escribió en el buscador.
class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  // NUEVO: un Map guarda parejas "llave: valor". Aquí la llave es el
  // número del equipo y el valor es su nombre. Con un número encuentras
  // el nombre, como en un diccionario.
  final Map<int, String> _teams = {
    6017: 'Cyberius',
    254: 'The Cheesy Poofs',
    1678: 'Citrus Circuits',
    118: 'Robonauts',
    2056: 'OP Robotics',
    971: 'Spartan Robotics',
    1323: 'MadTown Robotics',
    148: 'Robowranglers',
    3478: 'LamBot',
    4635: 'Botbusters',
  };

  // Lo que está escrito en el buscador, en minúsculas.
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          // NUEVO: cada vez que cambia el texto, lo guardamos con setState
          // para que la lista se vuelva a dibujar ya filtrada.
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar número o nombre',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (String text) {
              setState(() {
                _search = text.toLowerCase();
              });
            },
          ),
        ),
        // Expanded: la lista ocupa todo el espacio que sobra debajo del
        // buscador (un ListView dentro de una Column lo necesita).
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // NUEVO: .entries da las parejas del Map; cada una tiene
            // .key (el número) y .value (el nombre).
            // .where() se queda SOLO con las que cumplen la condición, y
            // .map() convierte cada una que quedó en una TeamCard.
            children: _teams.entries
                .where((entry) {
                  return '${entry.key} ${entry.value}'.toLowerCase().contains(
                    _search,
                  );
                })
                .map((entry) {
                  return TeamCard(teamNumber: entry.key, teamName: entry.value);
                })
                .toList(),
          ),
        ),
      ],
    );
  }
}
