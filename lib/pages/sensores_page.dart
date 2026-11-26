import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:taller_sensortrack/services/supabase_service.dart';

class SensoresPage extends StatefulWidget {
  const SensoresPage({super.key});

  @override
  State<SensoresPage> createState() => _SensoresPageState();
}

class _SensoresPageState extends State<SensoresPage> {
  // Valores del acelerometro
  double accX = 0;
  double accY = 0;
  double accZ = 0;

  // Valores del giroscopio
  double gyroX = 0;
  double gyroY = 0;
  double gyroZ = 0;

  bool monitoreando = false;
  bool guardandoAcc = false;
  bool guardandoGyro = false;
  String? errorAcelerometro;
  String? errorGiroscopio;

  StreamSubscription<AccelerometerEvent>? _accSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  @override
  void initState() {
    super.initState();
    _iniciarMonitoreo();
  }

  void _iniciarMonitoreo() {
    _accSubscription?.cancel();
    _gyroSubscription?.cancel();

    setState(() {
      monitoreando = true;
      errorAcelerometro = null;
      errorGiroscopio = null;
    });

    _accSubscription = accelerometerEventStream().listen(
      (event) {
        if (!mounted) return;
        setState(() {
          accX = event.x;
          accY = event.y;
          accZ = event.z;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          errorAcelerometro = 'Acelerómetro no disponible en este dispositivo.';
        });
      },
    );

    _gyroSubscription = gyroscopeEventStream().listen(
      (event) {
        if (!mounted) return;
        setState(() {
          gyroX = event.x;
          gyroY = event.y;
          gyroZ = event.z;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          errorGiroscopio = 'Giroscopio no disponible en este dispositivo.';
        });
      },
    );
  }

  void _detenerMonitoreo() {
    _accSubscription?.cancel();
    _gyroSubscription?.cancel();
    _accSubscription = null;
    _gyroSubscription = null;

    setState(() {
      monitoreando = false;
    });
  }

  Future<void> _guardarMedicionAcelerometro() async {
    setState(() {
      guardandoAcc = true;
    });

    try {
      await guardarAcelerometro(accX, accY, accZ);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medición de acelerómetro guardada en Supabase'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar acelerómetro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          guardandoAcc = false;
        });
      }
    }
  }

  Future<void> _guardarMedicionGiroscopio() async {
    setState(() {
      guardandoGyro = true;
    });

    try {
      await guardarGiroscopio(gyroX, gyroY, gyroZ);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medición de giroscopio guardada en Supabase'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar giroscopio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          guardandoGyro = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _accSubscription?.cancel();
    _gyroSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Control para iniciar o detener el monitoreo
          ElevatedButton.icon(
            onPressed: monitoreando ? _detenerMonitoreo : _iniciarMonitoreo,
            style: ElevatedButton.styleFrom(
              backgroundColor: monitoreando ? Colors.orange : Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: Icon(monitoreando ? Icons.pause : Icons.play_arrow),
            label: Text(
              monitoreando ? 'Detener monitoreo' : 'Iniciar monitoreo',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta del Acelerometro
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.speed, color: Colors.teal, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Acelerómetro (m/s²)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (errorAcelerometro != null)
                    Text(
                      errorAcelerometro!,
                      style: const TextStyle(color: Colors.red),
                    )
                  else ...[
                    Text(
                      'Eje X: ${accX.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Eje Y: ${accY.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Eje Z: ${accZ.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (guardandoAcc || errorAcelerometro != null)
                          ? null
                          : _guardarMedicionAcelerometro,
                      icon: guardandoAcc
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Guardar medición'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta del Giroscopio
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.screen_rotation,
                        color: Colors.indigo,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Giroscopio (rad/s)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (errorGiroscopio != null)
                    Text(
                      errorGiroscopio!,
                      style: const TextStyle(color: Colors.red),
                    )
                  else ...[
                    Text(
                      'Eje X: ${gyroX.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Eje Y: ${gyroY.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Eje Z: ${gyroZ.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (guardandoGyro || errorGiroscopio != null)
                          ? null
                          : _guardarMedicionGiroscopio,
                      icon: guardandoGyro
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Guardar medición'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
