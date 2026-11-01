import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/curso.dart';
import '../../models/estudiante.dart';

/// Servicio para gestionar cursos y listas de alumnos por docente,
/// almacenados localmente con SharedPreferences.
class CursoService {
  static final CursoService instance = CursoService._internal();
  CursoService._internal();

  static const String _keyCursos = 'cursos_list';
  static const String _keyEstudiantes = 'estudiantes_list';

  // ─── CURSOS ────────────────────────────────────────────────────────────────

  Future<List<Curso>> listarCursosPorDocente(String docenteId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCursos);
    if (raw == null) return [];
    final List<dynamic> lista = jsonDecode(raw);
    return lista
        .map((e) => Curso.fromJson(e as Map<String, dynamic>))
        .where((c) => c.docenteId == docenteId)
        .toList();
  }

  Future<Curso> crearCurso({
    required String docenteId,
    required String docenteNombre,
    required String codigo,
    required String nombre,
    required String semestre,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCursos);
    final List<dynamic> lista = raw != null ? jsonDecode(raw) : [];
    final cursos = lista.map((e) => Curso.fromJson(e as Map<String, dynamic>)).toList();

    final nuevo = Curso(
      id: 'curso-${DateTime.now().millisecondsSinceEpoch}',
      docenteId: docenteId,
      codigo: codigo.trim().toUpperCase(),
      nombre: nombre.trim(),
      semestre: semestre.trim(),
      docente: docenteNombre,
    );

    cursos.add(nuevo);
    await prefs.setString(_keyCursos, jsonEncode(cursos.map((c) => c.toJson()).toList()));
    return nuevo;
  }

  Future<void> eliminarCurso(String cursoId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCursos);
    if (raw == null) return;
    final List<dynamic> lista = jsonDecode(raw);
    final cursos = lista
        .map((e) => Curso.fromJson(e as Map<String, dynamic>))
        .where((c) => c.id != cursoId)
        .toList();
    await prefs.setString(_keyCursos, jsonEncode(cursos.map((c) => c.toJson()).toList()));
    // También eliminar estudiantes de ese curso
    await eliminarEstudiantesDeCurso(cursoId);
  }

  // ─── ESTUDIANTES ────────────────────────────────────────────────────────────

  Future<List<Estudiante>> listarEstudiantesPorCurso(String cursoId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyEstudiantes);
    if (raw == null) return [];
    final List<dynamic> lista = jsonDecode(raw);
    return lista
        .map((e) => Estudiante.fromJson(e as Map<String, dynamic>))
        .where((e) => e.cursoId == cursoId)
        .toList()
      ..sort((a, b) => a.numeroOrden.compareTo(b.numeroOrden));
  }

  Future<Estudiante> agregarEstudiante({
    required String cursoId,
    required int numeroOrden,
    required String nombres,
    required String apellidos,
    String? codigoUnsaac,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyEstudiantes);
    final List<dynamic> lista = raw != null ? jsonDecode(raw) : [];
    final estudiantes = lista.map((e) => Estudiante.fromJson(e as Map<String, dynamic>)).toList();

    final nuevo = Estudiante(
      id: 'est-${DateTime.now().millisecondsSinceEpoch}',
      cursoId: cursoId,
      numeroOrden: numeroOrden,
      codigoUnsaac: codigoUnsaac?.trim().isNotEmpty == true
          ? codigoUnsaac!.trim()
          : '2026${numeroOrden.toString().padLeft(2, '0')}',
      nombres: nombres.trim(),
      apellidos: apellidos.trim(),
    );

    estudiantes.add(nuevo);
    await prefs.setString(
        _keyEstudiantes, jsonEncode(estudiantes.map((e) => e.toJson()).toList()));
    return nuevo;
  }

  Future<void> eliminarEstudiante(String estudianteId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyEstudiantes);
    if (raw == null) return;
    final List<dynamic> lista = jsonDecode(raw);
    final estudiantes = lista
        .map((e) => Estudiante.fromJson(e as Map<String, dynamic>))
        .where((e) => e.id != estudianteId)
        .toList();
    await prefs.setString(
        _keyEstudiantes, jsonEncode(estudiantes.map((e) => e.toJson()).toList()));
  }

  Future<void> eliminarEstudiantesDeCurso(String cursoId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyEstudiantes);
    if (raw == null) return;
    final List<dynamic> lista = jsonDecode(raw);
    final estudiantes = lista
        .map((e) => Estudiante.fromJson(e as Map<String, dynamic>))
        .where((e) => e.cursoId != cursoId)
        .toList();
    await prefs.setString(
        _keyEstudiantes, jsonEncode(estudiantes.map((e) => e.toJson()).toList()));
  }
}
