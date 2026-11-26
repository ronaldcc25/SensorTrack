import 'package:flutter/material.dart';
import 'package:taller_sensortrack/pages/estadisticas_page.dart';
import 'package:taller_sensortrack/pages/historial_page.dart';
import 'package:taller_sensortrack/pages/home_page.dart';
import 'package:taller_sensortrack/pages/sensores_page.dart';
import 'package:taller_sensortrack/pages/ubicacion_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  void cambiarPantalla(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(cambiarPantalla: cambiarPantalla),
      const SensoresPage(),
      const UbicacionPage(),
      const HistorialPage(),
      const EstadisticasPage(),
    ];

    final titulos = [
      'SensorTrack',
      'Monitoreo de Sensores',
      'Ubicación GPS',
      'Historial de Mediciones',
      'Estadísticas',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titulos[selectedIndex],
          style: const TextStyle(color: Colors.white, fontSize: 21),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 169, 184),
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedItemColor: const Color.fromARGB(255, 1, 169, 184),
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Sensores'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Ubicación',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}
