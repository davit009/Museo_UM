import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/main.dart' as import_main;

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    // Esto hace que la notificación se vea incluso con la app abierta (especialmente útil en iOS)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 1. Solicitar permisos (Importante para iOS y Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos de notificación concedidos.');
      
      // 2. Obtener el token del dispositivo
      String? token = await _fcm.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _saveTokenToSupabase(token);
      }

      // 3. Escuchar si el token cambia (por si caduca y se genera uno nuevo)
      _fcm.onTokenRefresh.listen(_saveTokenToSupabase);
      
      // 4. Cuando la app está en PRIMER PLANO
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Mensaje recibido en primer plano: ${message.notification?.title}');
        
        if (message.notification != null) {
          import_main.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('${message.notification!.title}: ${message.notification!.body}'),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.deepPurple,
              action: SnackBarAction(
                label: 'Cerrar',
                textColor: Colors.white,
                onPressed: () {
                  import_main.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      });

      // 5. Cuando el usuario TOCA la notificación y la app estaba en segundo plano
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('¡El usuario tocó la notificación!');
        // Aquí puedes navegar a una pantalla específica dependiendo del payload
      });
    } else {
      print('Permisos de notificación denegados.');
    }
  }

  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final user = _supabase.auth.currentUser;
      // Solo guardamos el token si hay un usuario logueado
      if (user != null) {
        // Asumiendo que crearás una tabla llamada 'fcm_tokens' en Supabase
        await _supabase.from('fcm_tokens').upsert({
          'user_id': user.id,
          'token': token,
          // 'platform': Platform.operatingSystem, // Opcional, para saber si es android/ios
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Token guardado exitosamente en Supabase para el usuario ${user.id}');
      }
    } catch (e) {
      print('Error al guardar el token en Supabase: $e');
    }
  }
}
