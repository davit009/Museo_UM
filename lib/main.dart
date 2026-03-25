import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/core/constants.dart';
import 'package:museo_app/features/auth/screens/login_screen.dart';
import 'package:museo_app/features/museum/screens/splash_screen.dart'; 
import 'package:museo_app/features/museum/screens/home_screen.dart';   

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase
  await Firebase.initializeApp();

  await Supabase.initialize(
    url: SupabaseConstants.url, 
    anonKey: SupabaseConstants.anonKey,
  );

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