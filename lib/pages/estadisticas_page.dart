import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:taller_sensortrack/services/supabase_service.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  void _recargar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    'Error al cargar estadísticas:\n${snapshot.error}',
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
        final totalRegistros = registros.length;

        final accList = registros
            .where((r) => r['sensor_type'] == 'accelerometer')
            .toList();
        final gyroList = registros
            .where((r) => r['sensor_type'] == 'gyroscope')
            .toList();
        final gpsList = registros
            .where((r) => r['sensor_type'] == 'gps')
            .toList();

        // Valores maximos y minimos del acelerometro (considerando X, Y y Z)
        double? accMax;
        double? accMin;
        for (final r in accList) {
          for (final eje in ['x', 'y', 'z']) {
            final num? valor = r[eje] as num?;
            if (valor != null) {
              final double v = valor.toDouble();
              if (accMax == null || v > accMax) accMax = v;
              if (accMin == null || v < accMin) accMin = v;
            }
          }
        }

        // Ultima ubicacion registrada (la lista viene ordenada descendente)
        final Map<String, dynamic>? ultimaUbicacion = gpsList.isNotEmpty
            ? gpsList.first
            : null;

        // Puntos para el grafico de evolucion del acelerometro (en orden cronologico)
        final accOrdenado = accList.reversed.toList();
        final List<FlSpot> spotsX = [];
        final List<FlSpot> spotsY = [];
        final List<FlSpot> spotsZ = [];

        for (int i = 0; i < accOrdenado.length; i++) {
          final r = accOrdenado[i];
          final double x = (r['x'] as num?)?.toDouble() ?? 0;
          final double y = (r['y'] as num?)?.toDouble() ?? 0;
          final double z = (r['z'] as num?)?.toDouble() ?? 0;
          spotsX.add(FlSpot(i.toDouble(), x));
          spotsY.add(FlSpot(i.toDouble(), y));
          spotsZ.add(FlSpot(i.toDouble(), z));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resumen general',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _recargar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Total de registros y conteo por sensor
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cantidad total de registros: $totalRegistros',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Text('Acelerómetro: ${accList.length} mediciones'),
                      const SizedBox(height: 4),
                      Text('Giroscopio: ${gyroList.length} mediciones'),
                      const SizedBox(height: 4),
                      Text('GPS / Ubicación: ${gpsList.length} mediciones'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Maximos y minimos del acelerometro
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valores del acelerómetro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (accList.isEmpty)
                        const Text('Aún no hay registros de acelerómetro.')
                      else ...[
                        Text(
                          'Valor máximo registrado: ${accMax?.toStringAsFixed(2)} m/s²',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Valor mínimo registrado: ${accMin?.toStringAsFixed(2)} m/s²',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Ultima ubicacion registrada
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Última ubicación registrada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (ultimaUbicacion == null)
                        const Text('Aún no hay registros de ubicación GPS.')
                      else ...[
                        Text(
                          'Latitud: ${(ultimaUbicacion['latitude'] as num?)?.toStringAsFixed(6) ?? '-'}°',
                        ),
                        Text(
                          'Longitud: ${(ultimaUbicacion['longitude'] as num?)?.toStringAsFixed(6) ?? '-'}°',
                        ),
                        Text(
                          'Precisión: ${(ultimaUbicacion['accuracy'] as num?)?.toStringAsFixed(2) ?? '-'} m',
                        ),
                        Text(
                          'Fecha: ${formatearFecha(ultimaUbicacion['recorded_at'])}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Grafico de evolucion de las mediciones (fl_chart)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gráfico de evolución (Acelerómetro)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 12, color: Colors.red),
                          SizedBox(width: 4),
                          Text('X'),
                          SizedBox(width: 14),
                          Icon(Icons.circle, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text('Y'),
                          SizedBox(width: 14),
                          Icon(Icons.circle, size: 12, color: Colors.blue),
                          SizedBox(width: 4),
                          Text('Z'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (spotsX.length < 2)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Guarda al menos 2 mediciones del acelerómetro para ver la evolución en el gráfico.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true),
                              borderData: FlBorderData(show: true),
                              titlesData: const FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spotsX,
                                  isCurved: true,
                                  color: Colors.red,
                                  barWidth: 2,
                                ),
                                LineChartBarData(
                                  spots: spotsY,
                                  isCurved: true,
                                  color: Colors.green,
                                  barWidth: 2,
                                ),
                                LineChartBarData(
                                  spots: spotsZ,
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
