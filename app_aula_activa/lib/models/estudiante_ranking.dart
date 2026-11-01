import 'estudiante.dart';

/// DTO que consolida los puntos y notas calculadas de un estudiante
class EstudianteRanking {
  final Estudiante estudiante;
  final int puntosSesion;
  final int puntosTotales;
  final double notaSesion;
  final double notaTotal;
  final int posicion;

  EstudianteRanking({
    required this.estudiante,
    required this.puntosSesion,
    required this.puntosTotales,
    required this.notaSesion,
    required this.notaTotal,
    required this.posicion,
  });

  /// Copia con nuevos valores
  EstudianteRanking copyWith({
    Estudiante? estudiante,
    int? puntosSesion,
    int? puntosTotales,
    double? notaSesion,
    double? notaTotal,
    int? posicion,
  }) {
    return EstudianteRanking(
      estudiante: estudiante ?? this.estudiante,
      puntosSesion: puntosSesion ?? this.puntosSesion,
      puntosTotales: puntosTotales ?? this.puntosTotales,
      notaSesion: notaSesion ?? this.notaSesion,
      notaTotal: notaTotal ?? this.notaTotal,
      posicion: posicion ?? this.posicion,
    );
  }
}
