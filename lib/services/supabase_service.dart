import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = Supabase.instance.client;

// Verifica si la aplicacion tiene conexion con la tabla sensor_readings en Supabase
Future<bool> verificarConexionSupabase() async {
  try {
    await supabase.from('sensor_readings').select('id').limit(1);
    return true;
  } catch (_) {
    return false;
  }
}

// Guarda una medicion del acelerometro en Supabase
Future<void> guardarAcelerometro(double x, double y, double z) async {
  await supabase.from('sensor_readings').insert({
    'sensor_type': 'accelerometer',
    'x': x,
    'y': y,
    'z': z,
  });
}

// Registra en la tabla existente un evento de aceleracion brusca.
Future<void> guardarEventoAceleracion(double x, double y, double z) async {
  await supabase.from('sensor_readings').insert({
    'sensor_type': 'acceleration_event',
    'x': x,
    'y': y,
    'z': z,
  });
}

// Guarda una medicion del giroscopio en Supabase
Future<void> guardarGiroscopio(double x, double y, double z) async {
  await supabase.from('sensor_readings').insert({
    'sensor_type': 'gyroscope',
    'x': x,
    'y': y,
    'z': z,
  });
}

// Guarda una ubicacion GPS en Supabase
Future<void> guardarUbicacion(
  double latitude,
  double longitude,
  double accuracy,
) async {
  await supabase.from('sensor_readings').insert({
    'sensor_type': 'gps',
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
  });
}

// Obtiene todos los registros almacenados ordenados del mas reciente al mas antiguo
Future<List<Map<String, dynamic>>> getMediciones() async {
  final List<dynamic> data = await supabase
      .from('sensor_readings')
      .select()
      .order('recorded_at', ascending: false);

  return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
}

// Formatea la fecha ISO de Supabase a un texto legible
String formatearFecha(dynamic fechaRaw) {
  if (fechaRaw == null) return 'Sin fecha';
  try {
    final DateTime fecha = DateTime.parse(fechaRaw.toString()).toLocal();
    final String dia = fecha.day.toString().padLeft(2, '0');
    final String mes = fecha.month.toString().padLeft(2, '0');
    final String anio = fecha.year.toString();
    final String hora = fecha.hour.toString().padLeft(2, '0');
    final String min = fecha.minute.toString().padLeft(2, '0');
    final String seg = fecha.second.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$min:$seg';
  } catch (_) {
    return fechaRaw.toString();
  }
}

// Traduce el tipo de sensor a un nombre legible en espanol
String nombreSensor(String? sensorType) {
  switch (sensorType) {
    case 'accelerometer':
      return 'Acelerómetro';
    case 'acceleration_event':
      return 'Aceleración brusca';
    case 'gyroscope':
      return 'Giroscopio';
    case 'gps':
      return 'GPS / Ubicación';
    default:
      return sensorType ?? 'Desconocido';
  }
}
