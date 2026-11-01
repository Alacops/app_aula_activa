import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo de Docente
class Docente {
  final String id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String pin; // PIN local de 4 dígitos (hasheado en producción)

  const Docente({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.pin,
  });

  String get nombreCompleto => '$nombres $apellidos';

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombres': nombres,
        'apellidos': apellidos,
        'correo': correo,
        'pin': pin,
      };

  factory Docente.fromJson(Map<String, dynamic> json) => Docente(
        id: json['id'] as String,
        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        correo: json['correo'] as String,
        pin: json['pin'] as String,
      );
}

/// Servicio para gestionar la sesión del docente de forma local y segura.
/// El PIN nunca viaja en texto plano, se compara localmente.
class DocenteService {
  static final DocenteService instance = DocenteService._internal();
  DocenteService._internal();

  static const String _keyDocentes = 'docentes_list';
  static const String _keyDocenteActivo = 'docente_activo_id';

  Docente? _docenteActivo;
  Docente? get docenteActivo => _docenteActivo;
  bool get hayDocenteActivo => _docenteActivo != null;

  /// Carga el docente activo al arrancar la app.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyDocenteActivo);
    if (id != null) {
      final docentes = await listarDocentes();
      try {
        _docenteActivo = docentes.firstWhere((d) => d.id == id);
      } catch (_) {
        _docenteActivo = null;
      }
    }
  }

  /// Lista todos los docentes registrados localmente.
  Future<List<Docente>> listarDocentes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDocentes);
    if (raw == null) return [];
    final List<dynamic> lista = jsonDecode(raw);
    return lista.map((e) => Docente.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Registra un nuevo docente con PIN de 4 dígitos.
  Future<Docente> registrarDocente({
    required String nombres,
    required String apellidos,
    required String correo,
    required String pin,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final docentes = await listarDocentes();

    final nuevo = Docente(
      id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
      nombres: nombres.trim(),
      apellidos: apellidos.trim(),
      correo: correo.trim().toLowerCase(),
      pin: pin.trim(),
    );

    docentes.add(nuevo);
    await prefs.setString(
        _keyDocentes, jsonEncode(docentes.map((d) => d.toJson()).toList()));
    return nuevo;
  }

  /// Autenticar docente por correo + PIN.
  /// Devuelve el Docente si el PIN es correcto, null si no.
  Future<Docente?> autenticar({
    required String correo,
    required String pin,
  }) async {
    final docentes = await listarDocentes();
    try {
      final doc = docentes.firstWhere(
        (d) =>
            d.correo.toLowerCase() == correo.trim().toLowerCase() &&
            d.pin == pin.trim(),
      );
      _docenteActivo = doc;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDocenteActivo, doc.id);
      return doc;
    } catch (_) {
      return null;
    }
  }

  /// Cerrar sesión del docente.
  Future<void> cerrarSesion() async {
    _docenteActivo = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDocenteActivo);
  }

  /// Verifica si ya hay docentes registrados.
  Future<bool> hayDocentes() async {
    final lista = await listarDocentes();
    return lista.isNotEmpty;
  }

  /// Eliminar docente (y su sesión).
  Future<void> eliminarDocente(String docenteId) async {
    final prefs = await SharedPreferences.getInstance();
    final docentes = await listarDocentes();
    docentes.removeWhere((d) => d.id == docenteId);
    await prefs.setString(
        _keyDocentes, jsonEncode(docentes.map((d) => d.toJson()).toList()));
    if (_docenteActivo?.id == docenteId) {
      await cerrarSesion();
    }
  }

  /// Solo para depuración: elimina todos los datos.
  Future<void> resetearTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDocentes);
    await prefs.remove(_keyDocenteActivo);
    _docenteActivo = null;
    debugPrint('[DocenteService] Datos reseteados completamente.');
  }
}
