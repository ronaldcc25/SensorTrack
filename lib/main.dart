import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_sensortrack/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gkpriutpgqxqcoogoort.supabase.co',
    publishableKey: 'sb_publishable_8SQu_wNE0Yxd6ZeRQvluTw_ijoI1KEZ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SensorTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 1, 169, 184),
        ),
        useMaterial3: true,
      ),
      home: const Splash(),
    );
  }
}
