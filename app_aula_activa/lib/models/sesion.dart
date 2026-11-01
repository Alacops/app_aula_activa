class Sesion {
  final String id;
  final String cursoId;
  final String fecha;
  final String tema;
  final String estado; // 'ABIERTA', 'CERRADA'

  Sesion({
    required this.id,
    required this.cursoId,
    required this.fecha,
    required this.tema,
    this.estado = 'ABIERTA',
  });

  bool get estaAbierta => estado == 'ABIERTA';

  factory Sesion.fromJson(Map<String, dynamic> json) {
    return Sesion(
      id: json['id'].toString(),
      cursoId: json['curso_id']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      tema: json['tema'] ?? '',
      estado: json['estado'] ?? 'ABIERTA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'curso_id': cursoId,
      'fecha': fecha,
      'tema': tema,
      'estado': estado,
    };
  }
}
