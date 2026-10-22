import 'package:flutter/material.dart';
import 'package:session6_rest_api/api.dart';
import 'package:session6_rest_api/team_card.dart';

// La pestaña Teams. Antes la lista de números estaba escrita a mano;
// ahora llega del servidor.
// NUEVO: Stateful porque la lista empieza vacía y se llena cuando
// contesta el servidor.
class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  // Los equipos que mandó el servidor. Cada uno es un Map, por ejemplo:
  // {"number": 6017, "name": "PrepaTec - Cyberius", "city": "Santa Catarina", ...}
  // dynamic quiere decir "cualquier tipo": Dart no sabe de antemano qué
  // trae el JSON.
  List<dynamic> _teams = [];

  // true mientras esperamos la respuesta, para mostrar la ruedita.
  bool _loading = true;

  // Si algo sale mal, aquí guardamos el mensaje. Vacío = sin error.
  String _error = '';

  // NUEVO: initState corre UNA sola vez, cuando la página aparece.
  // Es el lugar para pedir los datos (en build no, porque build corre
  // cada vez que la pantalla se redibuja y pediríamos los equipos una y
  // otra vez).
  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    // try / catch: "intenta esto; si truena, en vez de que se caiga la
    // app, haz lo del catch". Sin internet, con la llave mala o con el
    // servidor caído, fetchTeams lanza un error y caemos en el catch.
    try {
      List<dynamic> teams = await fetchTeams();

      // Mientras esperábamos, el usuario pudo cambiar de pestaña y esta
      // página ya no existe (mounted = false). Llamar setState en una
      // página que ya no existe es un error, así que salimos.
      if (!mounted) return;

      setState(() {
        _teams = teams;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Todavía no contesta el servidor: la ruedita de "cargando".
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Algo salió mal: mostramos qué pasó en vez de una pantalla vacía.
    if (_error != '') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No se pudieron cargar los equipos:\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Llegaron los equipos: la misma lista de la sesión 5.
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Center(
          child: ListView(
            // .map() convierte cada Map del JSON en una TeamCard.
            // Con team['number'] sacamos el valor guardado con la llave
            // "number", igual que en el JSON.
            children: _teams.map((team) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TeamCard(
                  teamNumber: team['number'],
                  teamName: team['name'],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
