import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/core/constants.dart';
import 'package:museo_app/core/services/push_notification_service.dart';
import 'package:museo_app/features/auth/screens/login_screen.dart';
import 'package:museo_app/features/museum/screens/splash_screen.dart';
import 'package:museo_app/features/museum/screens/home_screen.dart';
import 'firebase_options.dart'; // Generado por FlutterFire CLI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase con las opciones del proyecto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  // Inicializa notificaciones push en background (no bloquea el arranque)
  PushNotificationService().initialize().catchError((e) {
    print('Push notifications no disponibles: $e');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Museo App',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.deepPurple),
      
      // 1. Que la app arranque con el Splash que hizo tu compañero
      home: const SplashScreen(), 
      
      // 2. Definimos rutas para que sea fácil saltar entre pantallas
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}