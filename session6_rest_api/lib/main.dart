import 'package:flutter/material.dart';
import 'package:session6_rest_api/teams_page.dart';
import 'package:session6_rest_api/template_page.dart';

void main() {
  runApp(const MainApp());
}

// Stateful porque tiene que recordar qué pestaña está seleccionada.
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // La pestaña seleccionada: 0 es la primera (Teams), 4 la última.
  int selectedIndex = 0;

  // Una página por pestaña, en el MISMO orden que la navbar.
  // Así selectedIndex sirve para escoger cuál mostrar.
  List<Widget> paginas = [
    const TeamsPage(),
    const TemplatePage(title: "Pick"),
    const TemplatePage(title: "Ask"),
    const TemplatePage(title: "Matches"),
    const TemplatePage(title: "More"),
  ];

  List<NavigationDestination> destinations = [
    const NavigationDestination(icon: Icon(Icons.people), label: "Teams"),
    const NavigationDestination(icon: Icon(Icons.list), label: "Pick"),
    const NavigationDestination(icon: Icon(Icons.question_mark), label: "Ask"),
    const NavigationDestination(
      icon: Icon(Icons.sports_esports),
      label: "Matches",
    ),
    const NavigationDestination(icon: Icon(Icons.plus_one), label: "More"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // El body cambia según la pestaña seleccionada.
        body: paginas[selectedIndex],

        bottomNavigationBar: NavigationBar(
          destinations: destinations,
          selectedIndex: selectedIndex,
          // Al tocar una pestaña, Flutter nos dice su número (value).
          // Lo guardamos con setState para que la pantalla se redibuje.
          onDestinationSelected: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
        ),
      ),
    );
  }
}
