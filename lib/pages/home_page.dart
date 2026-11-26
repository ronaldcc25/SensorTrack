import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:taller_sensortrack/services/supabase_service.dart';

class HomePage extends StatefulWidget {
  final Function(int) cambiarPantalla;

  const HomePage({super.key, required this.cambiarPantalla});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool cargandoConexion = true;
  bool supabaseConectado = false;

  bool acelerometroDisponible = false;
  bool giroscopioDisponible = false;
  bool gpsDisponible = false;

  @override
  void initState() {
    super.initState();
    _comprobarEstadoInicial();
  }

  Future<void> _comprobarEstadoInicial() async {
    setState(() {
      cargandoConexion = true;
    });

    final conectado = await verificarConexionSupabase();
    final gpsActivo = await Geolocator.isLocationServiceEnabled();
    final tieneAcelerometro = await _probarStream(accelerometerEventStream());
    final tieneGiroscopio = await _probarStream(gyroscopeEventStream());

    if (!mounted) return;
    setState(() {
      supabaseConectado = conectado;
      gpsDisponible = gpsActivo;
      acelerometroDisponible = tieneAcelerometro;
      giroscopioDisponible = tieneGiroscopio;
      cargandoConexion = false;
    });
  }

  Future<bool> _probarStream(Stream<dynamic> stream) async {
    try {
      await stream.first.timeout(const Duration(seconds: 2));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado SensorTrack
          Card(
            elevation: 4,
            color: const Color.fromARGB(255, 232, 248, 250),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(
                    Icons.sensors,
                    size: 48,
                    color: Color.fromARGB(255, 1, 169, 184),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SensorTrack',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Monitoreo en tiempo real de sensores físicos y almacenamiento en Supabase.',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Estado de conexion con Supabase
          Card(
            elevation: 3,
            child: ListTile(
              leading: cargandoConexion
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      supabaseConectado ? Icons.cloud_done : Icons.cloud_off,
                      color: supabaseConectado ? Colors.green : Colors.red,
                      size: 32,
                    ),
              title: const Text(
                'Conexión con Supabase',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                cargandoConexion
                    ? 'Verificando conexión...'
                    : (supabaseConectado
                          ? 'Conectado correctamente a sensor_readings'
                          : 'Sin conexión o error de permisos RLS'),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reintentar conexión',
                onPressed: _comprobarEstadoInicial,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sensores disponibles en el dispositivo
          const Text(
            'Sensores disponibles en el dispositivo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 3,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.speed, color: Colors.teal),
                  title: const Text('Acelerómetro'),
                  subtitle: const Text('Aceleración en ejes X, Y, Z'),
                  trailing: Text(
                    cargandoConexion
                        ? '...'
                        : (acelerometroDisponible
                              ? 'Disponible'
                              : 'No detectado'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: acelerometroDisponible
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.screen_rotation,
                    color: Colors.indigo,
                  ),
                  title: const Text('Giroscopio'),
                  subtitle: const Text('Velocidad angular en ejes X, Y, Z'),
                  trailing: Text(
                    cargandoConexion
                        ? '...'
                        : (giroscopioDisponible
                              ? 'Disponible'
                              : 'No detectado'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: giroscopioDisponible
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gps_fixed, color: Colors.redAccent),
                  title: const Text('GPS / Ubicación'),
                  subtitle: const Text('Latitud, longitud y precisión'),
                  trailing: Text(
                    cargandoConexion
                        ? '...'
                        : (gpsDisponible ? 'Activo' : 'Desactivado'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gpsDisponible ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Accesos rapidos del menu principal
          const Text(
            'Accesos rápidos',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.cambiarPantalla(1),
                  icon: const Icon(Icons.sensors),
                  label: const Text('Sensores'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.cambiarPantalla(2),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Ubicación'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.cambiarPantalla(3),
                  icon: const Icon(Icons.history),
                  label: const Text('Historial'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.cambiarPantalla(4),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Estadísticas'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
