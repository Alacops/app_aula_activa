class Curso {
  final String id;
  final String docenteId; // Propietario del curso
  final String codigo;
  final String nombre;
  final String semestre;
  final String docente; // Nombre legible del docente

  Curso({
    required this.id,
    required this.docenteId,
    required this.codigo,
    required this.nombre,
    required this.semestre,
    required this.docente,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'].toString(),
      docenteId: json['docente_id']?.toString() ?? '',
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      semestre: json['semestre'] ?? '',
      docente: json['docente'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'docente_id': docenteId,
      'codigo': codigo,
      'nombre': nombre,
      'semestre': semestre,
      'docente': docente,
    };
  }
}
