import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio singleton para manejar la conexión con Supabase.
/// Las credenciales NUNCA se almacenan en el código fuente.
/// Solo el docente autenticado puede configurarlas.
class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  static const String _keyUrl = 'supabase_url';
  static const String _keyAnon = 'supabase_anon_key';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }

  /// Inicializa Supabase solo si hay credenciales guardadas en el dispositivo.
  /// Nunca usa credenciales hardcodeadas.
  Future<bool> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString(_keyUrl) ?? '';
      final anon = prefs.getString(_keyAnon) ?? '';

      if (url.isNotEmpty && anon.isNotEmpty) {
        if (!_isInitialized) {
          await Supabase.initialize(
            url: url,
            // ignore: deprecated_member_use
            anonKey: anon,
            realtimeClientOptions: const RealtimeClientOptions(
              eventsPerSecond: 10,
            ),
          );
          _isInitialized = true;
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error al inicializar Supabase: $e');
    }
    return false;
  }

  /// Guarda y activa nuevas credenciales (solo accesible desde la pantalla de docente).
  Future<bool> saveCredentials(String url, String anonKey) async {
    if (url.trim().isEmpty || anonKey.trim().isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUrl, url.trim());
    await prefs.setString(_keyAnon, anonKey.trim());
    _isInitialized = false;
    try {
      await Supabase.initialize(
        url: url.trim(),
        // ignore: deprecated_member_use
        anonKey: anonKey.trim(),
        realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
      );
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error guardando credenciales: $e');
      return false;
    }
  }

  /// Verifica si hay credenciales guardadas (sin exponer su valor).
  Future<bool> tieneCredencialesGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_keyUrl) ?? '';
    final anon = prefs.getString(_keyAnon) ?? '';
    return url.isNotEmpty && anon.isNotEmpty;
  }

  /// Solo para uso interno del diálogo de configuración del docente.
  Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'url': prefs.getString(_keyUrl) ?? '',
      'anonKey': prefs.getString(_keyAnon) ?? '',
    };
  }

  /// Elimina las credenciales guardadas (desconexión).
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUrl);
    await prefs.remove(_keyAnon);
    _isInitialized = false;
  }
}
