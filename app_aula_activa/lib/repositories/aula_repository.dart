import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';
import '../core/services/curso_service.dart';
import '../models/curso.dart';
import '../models/estudiante.dart';
import '../models/estudiante_ranking.dart';
import '../models/participacion.dart';
import '../models/sesion.dart';

/// Repositorio de aula activa. Encapsula toda la lógica de datos de una sesión.
/// Es efímero: se recrea cuando el docente selecciona un curso y abre sesión.
class AulaRepository {
  static AulaRepository? _instance;

  static bool get isInicializado => _instance != null;

  static AulaRepository get instance {
    if (_instance == null) {
      throw StateError(
        'AulaRepository no ha sido inicializado. Inicie una sesión desde el panel docente o escanee el código QR del aula.',
      );
    }
    return _instance!;
  }

  /// Inicialización exclusiva para pruebas automatizadas
  static Future<AulaRepository> inicializarDemo() async {
    final cursoDemo = Curso(
      id: 'c-demo',
      docenteId: 'doc-demo',
      codigo: 'IF616AIN',
      nombre: 'Desarrollo de Software II',
      semestre: '2026-II',
      docente: 'Mtro. Ing. Yover Collantes Valer',
    );
    final repo = AulaRepository._internal(
      curso: cursoDemo,
      temaSesion: 'Sesión Demostrativa',
    );
    repo._estudiantes.addAll(estudiantesPredeterminados);
    _instance = repo;
    return repo;
  }

  /// Lista de estudiantes de prueba UNSAAC para funcionamiento fuera de línea o tests
  static final List<Estudiante> estudiantesPredeterminados = [
    Estudiante(
      id: 'e-1',
      cursoId: 'c-demo',
      numeroOrden: 1,
      codigoUnsaac: '174449',
      nombres: 'Edmil Jampier',
      apellidos: 'Saire Bustamante',
    ),
    Estudiante(
      id: 'e-2',
      cursoId: 'c-demo',
      numeroOrden: 2,
      codigoUnsaac: '221456',
      nombres: 'Diego Fernando',
      apellidos: 'Quispe Mamani',
    ),
    Estudiante(
      id: 'e-3',
      cursoId: 'c-demo',
      numeroOrden: 3,
      codigoUnsaac: '221457',
      nombres: 'Valeria Lucía',
      apellidos: 'Huamán Condori',
    ),
    Estudiante(
      id: 'e-4',
      cursoId: 'c-demo',
      numeroOrden: 4,
      codigoUnsaac: '221458',
      nombres: 'Carlos Eduardo',
      apellidos: 'Ramos Triveño',
    ),
    Estudiante(
      id: 'e-5',
      cursoId: 'c-demo',
      numeroOrden: 5,
      codigoUnsaac: '221459',
      nombres: 'Ana Belén',
      apellidos: 'Mendoza Choque',
    ),
  ];

  /// Inicializa el repositorio para un curso específico.
  static Future<AulaRepository> inicializar({
    required Curso curso,
    required String temaSesion,
  }) async {
    _instance?.dispose();
    final repo = AulaRepository._internal(curso: curso, temaSesion: temaSesion);
    await repo._cargarDatos();
    _instance = repo;
    return repo;
  }

  /// Limpia el repositorio al cerrar sesión.
  static void limpiar() {
    _instance?.dispose();
    _instance = null;
  }

  // ─── Estado Interno ─────────────────────────────────────────────────────────
  late final Curso _cursoActual;
  late final Sesion _sesionActual;
  final List<Estudiante> _estudiantes = [];
  final List<Participacion> _participaciones = [];
  final Set<int> _numerosOrdenOcupados = {};
  StreamSubscription? _participacionesSubscription;

  final _rankingSesionController =
      StreamController<List<EstudianteRanking>>.broadcast();
  final _rankingAcumuladoController =
      StreamController<List<EstudianteRanking>>.broadcast();

  Stream<List<EstudianteRanking>> get rankingSesionStream =>
      _rankingSesionController.stream;
  Stream<List<EstudianteRanking>> get rankingAcumuladoStream =>
      _rankingAcumuladoController.stream;

  Curso get cursoActual => _cursoActual;
  Sesion get sesionActual => _sesionActual;
  List<Estudiante> get estudiantes => List.unmodifiable(_estudiantes);
  Set<int> get numerosOrdenOcupados => Set.unmodifiable(_numerosOrdenOcupados);
  bool isNumeroOrdenOcupado(int numeroOrden) => _numerosOrdenOcupados.contains(numeroOrden);

  AulaRepository._internal({required Curso curso, required String temaSesion}) {
    _cursoActual = curso;
    final ahora = DateTime.now();
    _sesionActual = Sesion(
      id: 'sesion-${ahora.millisecondsSinceEpoch}',
      cursoId: curso.id,
      fecha:
          '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}',
      tema: temaSesion.trim().isNotEmpty ? temaSesion.trim() : 'Sesión del día',
      estado: 'ABIERTA',
    );
  }

  Future<void> _cargarDatos() async {
    // 1. Cargar estudiantes del servicio local
    final lista =
        await CursoService.instance.listarEstudiantesPorCurso(_cursoActual.id);
    if (lista.isNotEmpty) {
      _estudiantes.addAll(lista);
    } else {
      _estudiantes.addAll(estudiantesPredeterminados);
    }

    // 2. Intentar sincronizar con Supabase si está disponible
    await sincronizarConSupabase();

    _emitirActualizaciones();
  }

  /// Código de 4 dígitos para acceso alternativo sin cámara
  String get pinSesion {
    final codigoInt = _sesionActual.id.hashCode.abs() % 9000 + 1000;
    return codigoInt.toString();
  }

  /// Genera payload JSON para el código QR de ingreso al aula
  String generarCodigoQrSesion() {
    return jsonEncode({
      'app': 'aulaactiva',
      'curso_id': _cursoActual.id,
      'codigo': _cursoActual.codigo,
      'nombre': _cursoActual.nombre,
      'sesion_id': _sesionActual.id,
      'tema': _sesionActual.tema,
      'docente': _cursoActual.docente,
      'pin': pinSesion,
    });
  }

  /// Sincroniza en vivo con Supabase Cloud (solo si está conectado).
  Future<void> sincronizarConSupabase() async {
    final client = SupabaseService.instance.client;
    if (client == null) return;

    try {
      // Cargar participaciones del semestre para este curso
      final sesionesData = await client
          .from('sesiones')
          .select('id')
          .eq('curso_id', _cursoActual.id);

      if (sesionesData.isNotEmpty) {
        final sesionIds = sesionesData.map((s) => s['id'].toString()).toList();
        final participacionesData = await client
            .from('participaciones')
            .select()
            .inFilter('sesion_id', sesionIds);

        _participaciones.clear();
        for (final item in participacionesData) {
          _participaciones.add(Participacion.fromJson(item));
        }
      }

      _emitirActualizaciones();

      // Suscripción Realtime
      _participacionesSubscription?.cancel();
      _participacionesSubscription = client
          .from('participaciones')
          .stream(primaryKey: ['id']).listen(
              (List<Map<String, dynamic>> data) {
        _participaciones.clear();
        for (final item in data) {
          _participaciones.add(Participacion.fromJson(item));
        }
        _emitirActualizaciones();
      }, onError: (err) {
        debugPrint('Error en stream Realtime: $err');
      });
    } catch (e) {
      debugPrint('Error sincronizando con Supabase: $e');
    }
  }

  /// Asigna puntos a un estudiante individual.
  Future<void> asignarPuntos({
    required String estudianteId,
    required int puntos,
    String motivo = 'Participación en clase',
  }) async {
    final nueva = Participacion(
      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      sesionId: _sesionActual.id,
      estudianteId: estudianteId,
      puntos: puntos,
      motivo: motivo,
      timestamp: DateTime.now(),
    );

    _participaciones.add(nueva);
    _emitirActualizaciones();

    final client = SupabaseService.instance.client;
    if (client != null) {
      try {
        await client.from('participaciones').insert({
          'sesion_id': _sesionActual.id,
          'estudiante_id': estudianteId,
          'puntos': puntos,
          'motivo': motivo,
        });
      } catch (e) {
        debugPrint('Error sincronizando participación: $e');
      }
    }
  }

  /// Asignación masiva/simultánea de puntos a varios estudiantes.
  Future<void> asignarPuntosMultiples({
    required List<String> estudianteIds,
    required int puntos,
    String motivo = 'Dinámica grupal / Respuesta colectiva',
  }) async {
    for (final id in estudianteIds) {
      _participaciones.add(Participacion(
        id: 'p-${DateTime.now().millisecondsSinceEpoch}-$id',
        sesionId: _sesionActual.id,
        estudianteId: id,
        puntos: puntos,
        motivo: motivo,
        timestamp: DateTime.now(),
      ));
    }
    _emitirActualizaciones();

    final client = SupabaseService.instance.client;
    if (client != null) {
      try {
        final payload = estudianteIds.map((id) => {
              'sesion_id': _sesionActual.id,
              'estudiante_id': id,
              'puntos': puntos,
              'motivo': motivo,
            }).toList();
        await client.from('participaciones').insert(payload);
      } catch (e) {
        debugPrint('Error sincronización múltiple: $e');
      }
    }
  }

  /// Registra un estudiante que se une desde su propio dispositivo.
  Future<Estudiante?> buscarEstudiantePorOrden(int numeroOrden) async {
    try {
      return _estudiantes.firstWhere((e) => e.numeroOrden == numeroOrden);
    } catch (_) {
      return null;
    }
  }

  /// Reclama el lugar / número de orden para un dispositivo.
  /// Evita que dos celulares se conecten al mismo número en la sesión activa.
  String? reclamarNumeroOrden(int numeroOrden) {
    if (_numerosOrdenOcupados.contains(numeroOrden)) {
      return 'El número de orden #$numeroOrden ya está ocupado por otro celular en esta sesión.';
    }
    _numerosOrdenOcupados.add(numeroOrden);
    _emitirActualizaciones();
    return null;
  }

  /// Libera el número de orden si el estudiante sale o si el docente lo resetea.
  void liberarNumeroOrden(int numeroOrden) {
    _numerosOrdenOcupados.remove(numeroOrden);
    _emitirActualizaciones();
  }

  // ─── Cálculo de Ranking ─────────────────────────────────────────────────────

  List<EstudianteRanking> obtenerRankingSesion() {
    final mapPuntosSesion = <String, int>{};
    final mapPuntosTotales = <String, int>{};

    for (final p in _participaciones) {
      mapPuntosTotales[p.estudianteId] =
          (mapPuntosTotales[p.estudianteId] ?? 0) + p.puntos;
      if (p.sesionId == _sesionActual.id) {
        mapPuntosSesion[p.estudianteId] =
            (mapPuntosSesion[p.estudianteId] ?? 0) + p.puntos;
      }
    }

    int maxSesion = 0;
    int maxTotal = 0;
    for (final e in _estudiantes) {
      final pts = mapPuntosSesion[e.id] ?? 0;
      if (pts > maxSesion) maxSesion = pts;
      final tot = mapPuntosTotales[e.id] ?? 0;
      if (tot > maxTotal) maxTotal = tot;
    }

    final lista = _estudiantes.map((e) {
      final ptsSesion = mapPuntosSesion[e.id] ?? 0;
      final ptsTotales = mapPuntosTotales[e.id] ?? 0;
      final notaSesion = maxSesion > 0
          ? double.parse(((ptsSesion / maxSesion) * 20.0).toStringAsFixed(1))
          : 0.0;
      final notaTotal = maxTotal > 0
          ? double.parse(((ptsTotales / maxTotal) * 20.0).toStringAsFixed(1))
          : 0.0;

      return EstudianteRanking(
        estudiante: e,
        puntosSesion: ptsSesion,
        puntosTotales: ptsTotales,
        notaSesion: notaSesion,
        notaTotal: notaTotal,
        posicion: 0,
      );
    }).toList();

    lista.sort((a, b) {
      final cmp = b.puntosSesion.compareTo(a.puntosSesion);
      if (cmp != 0) return cmp;
      return a.estudiante.numeroOrden.compareTo(b.estudiante.numeroOrden);
    });

    for (int i = 0; i < lista.length; i++) {
      lista[i] = lista[i].copyWith(posicion: i + 1);
    }
    return lista;
  }

  List<EstudianteRanking> obtenerRankingAcumulado() {
    final lista = obtenerRankingSesion();
    lista.sort((a, b) {
      final cmp = b.puntosTotales.compareTo(a.puntosTotales);
      if (cmp != 0) return cmp;
      return a.estudiante.numeroOrden.compareTo(b.estudiante.numeroOrden);
    });
    for (int i = 0; i < lista.length; i++) {
      lista[i] = lista[i].copyWith(posicion: i + 1);
    }
    return lista;
  }

  void _emitirActualizaciones() {
    if (!_rankingSesionController.isClosed) {
      _rankingSesionController.add(obtenerRankingSesion());
    }
    if (!_rankingAcumuladoController.isClosed) {
      _rankingAcumuladoController.add(obtenerRankingAcumulado());
    }
  }

  void dispose() {
    _participacionesSubscription?.cancel();
    _rankingSesionController.close();
    _rankingAcumuladoController.close();
  }
}
