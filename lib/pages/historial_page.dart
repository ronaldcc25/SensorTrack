import 'package:flutter/material.dart';
import 'package:taller_sensortrack/services/supabase_service.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  void _recargar() {
    setState(() {});
  }

  IconData _iconoPorSensor(String? tipo) {
    switch (tipo) {
      case 'accelerometer':
        return Icons.speed;
      case 'gyroscope':
        return Icons.screen_rotation;
      case 'gps':
        return Icons.location_on;
      default:
        return Icons.sensors;
    }
  }

  String _resumenValores(Map<String, dynamic> registro) {
    final String? tipo = registro['sensor_type']?.toString();
    if (tipo == 'gps') {
      final lat = (registro['latitude'] as num?)?.toStringAsFixed(5) ?? '-';
      final lon = (registro['longitude'] as num?)?.toStringAsFixed(5) ?? '-';
      final acc = (registro['accuracy'] as num?)?.toStringAsFixed(1) ?? '-';
      return 'Lat: $lat, Lon: $lon (±$acc m)';
    } else {
      final x = (registro['x'] as num?)?.toStringAsFixed(2) ?? '-';
      final y = (registro['y'] as num?)?.toStringAsFixed(2) ?? '-';
      final z = (registro['z'] as num?)?.toStringAsFixed(2) ?? '-';
      return 'X: $x | Y: $y | Z: $z';
    }
  }

  void _mostrarDetalle(Map<String, dynamic> registro) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(nombreSensor(registro['sensor_type']?.toString())),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${registro['id'] ?? '-'}'),
              const SizedBox(height: 6),
              Text('Tipo: ${registro['sensor_type'] ?? '-'}'),
              const SizedBox(height: 6),
              Text('Fecha y hora: ${formatearFecha(registro['recorded_at'])}'),
              const Divider(),
              if (registro['sensor_type'] == 'gps') ...[
                Text('Latitud: ${registro['latitude'] ?? '-'}'),
                Text('Longitud: ${registro['longitude'] ?? '-'}'),
                Text('Precisión: ${registro['accuracy'] ?? '-'} m'),
              ] else ...[
                Text('Eje X: ${registro['x'] ?? '-'}'),
                Text('Eje Y: ${registro['y'] ?? '-'}'),
                Text('Eje Z: ${registro['z'] ?? '-'}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registros en Supabase',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _recargar,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: getMediciones(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Error al cargar historial:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _recargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final registros = snapshot.data ?? [];
              if (registros.isEmpty) {
                return const Center(
                  child: Text(
                    'Aún no hay mediciones guardadas en Supabase.',
                    style: TextStyle(fontSize: 15),
                  ),
                );
              }

              return ListView.builder(
                itemCount: registros.length,
                itemBuilder: (context, index) {
                  final registro = registros[index];
                  final tipo = registro['sensor_type']?.toString();
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(
                        _iconoPorSensor(tipo),
                        color: const Color.fromARGB(255, 1, 169, 184),
                        size: 30,
                      ),
                      title: Text(
                        nombreSensor(tipo),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_resumenValores(registro)),
                          Text(
                            formatearFecha(registro['recorded_at']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _mostrarDetalle(registro),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
