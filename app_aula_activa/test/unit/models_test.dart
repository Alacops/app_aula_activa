import 'package:flutter_test/flutter_test.dart';
import 'package:app_aula_activa/models/curso.dart';
import 'package:app_aula_activa/models/estudiante.dart';
import 'package:app_aula_activa/models/estudiante_ranking.dart';
import 'package:app_aula_activa/models/participacion.dart';
import 'package:app_aula_activa/models/sesion.dart';

void main() {
  group('Pruebas Unitarias de Modelos de Datos', () {
    test('Curso: serialización y deserialización correcta', () {
      final json = {
        'id': 'c-100',
        'docente_id': 'd-1',
        'codigo': 'IF616AIN',
        'nombre': 'Desarrollo de Software II',
        'semestre': '2026-II',
        'docente': 'Mtro. Ing. Yover Collantes Valer',
      };

      final curso = Curso.fromJson(json);
      expect(curso.id, 'c-100');
      expect(curso.docenteId, 'd-1');
      expect(curso.codigo, 'IF616AIN');
      expect(curso.nombre, 'Desarrollo de Software II');
      expect(curso.toJson(), equals(json));
    });

    test('Estudiante: cálculo de nombre completo y casteo de número de orden', () {
      final json = {
        'id': 'e-1',
        'curso_id': 'c-100',
        'numero_orden': 1,
        'codigo_unsaac': '174449',
        'nombres': 'Edmil Jampier',
        'apellidos': 'Saire Bustamante',
      };

      final est = Estudiante.fromJson(json);
      expect(est.numeroOrden, equals(1));
      expect(est.nombreCompleto, equals('Saire Bustamante, Edmil Jampier'));
      expect(est.codigoUnsaac, equals('174449'));
    });

    test('Sesión: estado abierta / cerrada', () {
      final sesionAbierta = Sesion(
        id: 's-1',
        cursoId: 'c-1',
        fecha: '10/10/2026',
        tema: 'Arquitectura Flutter',
        estado: 'ABIERTA',
      );
      expect(sesionAbierta.estaAbierta, isTrue);

      final sesionCerrada = Sesion(
        id: 's-2',
        cursoId: 'c-1',
        fecha: '09/10/2026',
        tema: 'Conceptos Dart',
        estado: 'CERRADA',
      );
      expect(sesionCerrada.estaAbierta, isFalse);
    });

    test('Participación: creación y fecha válida', () {
      final ahora = DateTime.now();
      final part = Participacion(
        id: 'p-1',
        sesionId: 's-1',
        estudianteId: 'e-1',
        puntos: 3,
        motivo: 'Aporte en pizarra',
        timestamp: ahora,
      );

      expect(part.puntos, equals(3));
      expect(part.motivo, equals('Aporte en pizarra'));
      expect(part.timestamp, equals(ahora));
    });

    test('EstudianteRanking: inmutabilidad y copyWith', () {
      final est = Estudiante(
        id: 'e-1',
        cursoId: 'c-1',
        numeroOrden: 1,
        codigoUnsaac: '174449',
        nombres: 'Edmil',
        apellidos: 'Saire',
      );

      final r1 = EstudianteRanking(
        estudiante: est,
        puntosSesion: 5,
        puntosTotales: 15,
        notaSesion: 20.0,
        notaTotal: 18.5,
        posicion: 1,
      );

      final r2 = r1.copyWith(posicion: 2, notaSesion: 19.0);
      expect(r2.posicion, equals(2));
      expect(r2.notaSesion, equals(19.0));
      expect(r2.puntosSesion, equals(5));
      expect(r1.posicion, equals(1)); // Original intacto
    });
  });
}
