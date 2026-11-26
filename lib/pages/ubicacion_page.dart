import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taller_sensortrack/services/supabase_service.dart';

class UbicacionPage extends StatefulWidget {
  const UbicacionPage({super.key});

  @override
  State<UbicacionPage> createState() => _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  Position? posicionActual;
  DateTime? fechaCaptura;
  bool obteniendo = false;
  bool guardando = false;
  String? mensajeError;

  // Genera la URL del mosaico de OpenStreetMap (mismo metodo usado en list_lugares.dart)
  String obtenerUrlMapa(double lat, double lon, {int zoom = 16}) {
    final int x = ((lon + 180.0) / 360.0 * (1 << zoom)).floor();
    final double latRad = lat * pi / 180.0;
    final int y =
        ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * (1 << zoom))
            .floor();
    return 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
  }

  Future<void> _obtenerUbicacion() async {
    setState(() {
      obteniendo = true;
      mensajeError = null;
    });

    try {
      final bool servicioHabilitado =
          await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        setState(() {
          mensajeError =
              'El GPS está desactivado. Activa la ubicación en tu celular.';
          obteniendo = false;
        });
        return;
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          setState(() {
            mensajeError = 'Permiso de ubicación denegado por el usuario.';
            obteniendo = false;
          });
          return;
        }
      }

      if (permiso == LocationPermission.deniedForever) {
        setState(() {
          mensajeError =
              'Permiso de ubicación denegado permanentemente. Habilítalo en Ajustes.';
          obteniendo = false;
        });
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        posicionActual = pos;
        fechaCaptura = DateTime.now();
        obteniendo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensajeError = 'Error al obtener la ubicación: $e';
        obteniendo = false;
      });
    }
  }

  Future<void> _guardarUbicacionEnSupabase() async {
    if (posicionActual == null) return;

    setState(() {
      guardando = true;
    });

    try {
      await guardarUbicacion(
        posicionActual!.latitude,
        posicionActual!.longitude,
        posicionActual!.accuracy,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación GPS guardada en Supabase'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar ubicación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: obteniendo ? null : _obtenerUbicacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 1, 169, 184),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: obteniendo
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              obteniendo ? 'Obteniendo ubicación...' : 'Obtener ubicación GPS',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          if (mensajeError != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  mensajeError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),

          if (posicionActual == null && mensajeError == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.location_searching, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'Presiona el botón para capturar tu ubicación actual.\nSolo se guardará en Supabase cuando tú lo autorices.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          if (posicionActual != null) ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos de ubicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Latitud: ${posicionActual!.latitude.toStringAsFixed(6)}°',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longitud: ${posicionActual!.longitude.toStringAsFixed(6)}°',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Precisión: ${posicionActual!.accuracy.toStringAsFixed(2)} metros',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fecha y hora: ${formatearFecha(fechaCaptura?.toIso8601String())}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 14),

                    // Vista previa del mapa con OpenStreetMap
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              obtenerUrlMapa(
                                posicionActual!.latitude,
                                posicionActual!.longitude,
                              ),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.map_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: guardando
                            ? null
                            : _guardarUbicacionEnSupabase,
                        icon: guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: const Text('Guardar ubicación en Supabase'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
