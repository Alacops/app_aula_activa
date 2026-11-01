class Estudiante {
  final String id;
  final String cursoId;
  final int numeroOrden;
  final String codigoUnsaac;
  final String nombres;
  final String apellidos;

  Estudiante({
    required this.id,
    required this.cursoId,
    required this.numeroOrden,
    required this.codigoUnsaac,
    required this.nombres,
    required this.apellidos,
  });

  String get nombreCompleto => '$apellidos, $nombres';

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      id: json['id'].toString(),
      cursoId: json['curso_id']?.toString() ?? '',
      numeroOrden: json['numero_orden'] is int
          ? json['numero_orden']
          : int.tryParse(json['numero_orden'].toString()) ?? 0,
      codigoUnsaac: json['codigo_unsaac'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'curso_id': cursoId,
      'numero_orden': numeroOrden,
      'codigo_unsaac': codigoUnsaac,
      'nombres': nombres,
      'apellidos': apellidos,
    };
  }
}
