import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_aula_activa/models/curso.dart';
import 'package:app_aula_activa/models/estudiante.dart';
import 'package:app_aula_activa/repositories/aula_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas del Sistema de Códigos QR y Acceso al Aula', () {
    late AulaRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final curso = Curso(
        id: 'c-qr-test',
        docenteId: 'd-test',
        codigo: 'IF616AIN',
        nombre: 'Desarrollo de Software II',
        semestre: '2026-II',
        docente: 'Mtro. Ing. Yover Collantes Valer',
      );
      repository = await AulaRepository.inicializar(
        curso: curso,
        temaSesion: 'Sesión de Arquitectura QR',
      );
    });

    test('generarCodigoQrSesion produce un payload JSON estructurado válido', () {
      final payloadRaw = repository.generarCodigoQrSesion();
      expect(payloadRaw, isNotEmpty);

      final Map<String, dynamic> data = jsonDecode(payloadRaw);
      expect(data['app'], equals('aulaactiva'));
      expect(data['curso_id'], equals('c-qr-test'));
      expect(data['codigo'], equals('IF616AIN'));
      expect(data['nombre'], equals('Desarrollo de Software II'));
      expect(data['tema'], equals('Sesión de Arquitectura QR'));
      expect(data['pin'], isNotNull);
      expect(data['pin'].toString().length, greaterThanOrEqualTo(4));
    });

    test('pinSesion devuelve un código numérico consistente de 4 dígitos', () {
      final pin1 = repository.pinSesion;
      final pin2 = repository.pinSesion;
      expect(pin1, equals(pin2));
      expect(pin1.length, equals(4));
      expect(int.tryParse(pin1), isNotNull);
    });

    test('Credencial digital de estudiante genera payload con orden y código UNSAAC', () {
      final estudiante = Estudiante(
        id: 'e-10',
        cursoId: 'c-qr-test',
        numeroOrden: 14,
        codigoUnsaac: '221456',
        nombres: 'Diego Fernando',
        apellidos: 'Quispe Mamani',
      );

      final payload = jsonEncode({
        'tipo': 'estudiante_unsaac',
        'id': estudiante.id,
        'codigo_unsaac': estudiante.codigoUnsaac,
        'numero_orden': estudiante.numeroOrden,
        'nombres': estudiante.nombres,
        'apellidos': estudiante.apellidos,
      });

      final Map<String, dynamic> decoded = jsonDecode(payload);
      expect(decoded['tipo'], equals('estudiante_unsaac'));
      expect(decoded['numero_orden'], equals(14));
      expect(decoded['codigo_unsaac'], equals('221456'));
    });
  });
}
