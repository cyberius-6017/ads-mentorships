import 'package:flutter/material.dart';

import 'package:session5_navigation/widgets/colors.dart';
import 'package:session5_navigation/widgets/teams_page.dart';
import 'package:session5_navigation/widgets/template_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cyberius Scouting',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

// Stateful porque tiene que recordar qué pestaña está seleccionada.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // La pestaña seleccionada: 0 es la primera, 4 la última.
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // NUEVO: una página por pestaña, en el MISMO orden que la navbar.
    // Así _selectedIndex sirve para escoger cuál mostrar.
    final List<Widget> pages = [
      const TemplatePage(title: 'Match Scouting', buttonLabel: 'Nuevo reporte'),
      const TemplatePage(title: 'Pit Scouting', buttonLabel: 'Revisar robot'),
      // La lista de equipos con su buscador vive en su propio archivo.
      const TeamsPage(),
      const TemplatePage(title: 'Picklist', buttonLabel: 'Armar picklist'),
      const TemplatePage(title: 'Matches', buttonLabel: 'Ver matches'),
    ];

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        title: const Text('Cyberius 6017'),
      ),
      // El body cambia según la pestaña seleccionada.
      body: pages[_selectedIndex],
      // NUEVO: la barra de navegación de abajo.
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: kOrange,
        // Qué pestaña se ve marcada.
        selectedIndex: _selectedIndex,
        // Al tocar una pestaña, Flutter nos dice su número (index).
        // Lo guardamos con setState para que la pantalla se redibuje.
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note),
            label: 'Match Scouting',
          ),
          NavigationDestination(icon: Icon(Icons.build), label: 'Pit Scouting'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Teams'),
          NavigationDestination(
            icon: Icon(Icons.format_list_numbered),
            label: 'Picklist',
          ),
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Matches'),
        ],
      ),
    );
  }
}
