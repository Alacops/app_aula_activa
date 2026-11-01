class Participacion {
  final String id;
  final String sesionId;
  final String estudianteId;
  final int puntos;
  final String motivo;
  final DateTime timestamp;

  Participacion({
    required this.id,
    required this.sesionId,
    required this.estudianteId,
    required this.puntos,
    this.motivo = 'Participación en clase',
    required this.timestamp,
  });

  factory Participacion.fromJson(Map<String, dynamic> json) {
    return Participacion(
      id: json['id'].toString(),
      sesionId: json['sesion_id']?.toString() ?? '',
      estudianteId: json['estudiante_id']?.toString() ?? '',
      puntos: json['puntos'] is int
          ? json['puntos']
          : int.tryParse(json['puntos'].toString()) ?? 1,
      motivo: json['motivo'] ?? 'Participación en clase',
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sesion_id': sesionId,
      'estudiante_id': estudianteId,
      'puntos': puntos,
      'motivo': motivo,
    };
  }
}
