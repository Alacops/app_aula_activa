import 'package:flutter_test/flutter_test.dart';
import 'package:app_aula_activa/models/curso.dart';
import 'package:app_aula_activa/models/estudiante.dart';
import 'package:app_aula_activa/models/participacion.dart';
import 'package:app_aula_activa/models/sesion.dart';
import 'package:app_aula_activa/models/estudiante_ranking.dart';

/// Tests del algoritmo de escala vigesimal.
/// Usan datos directos (sin repositorio) para ser herméticos y rápidos.
void main() {
  group('Pruebas del Algoritmo de Calificación Vigesimal (Escala 0 a 20)', () {
    // Datos de prueba
    final curso = Curso(
      id: 'test-curso',
      docenteId: 'test-doc',
      codigo: 'TEST01',
      nombre: 'Curso de Prueba',
      semestre: '2026-II',
      docente: 'Docente Prueba',
    );

    final sesion = Sesion(
      id: 'test-sesion',
      cursoId: curso.id,
      fecha: '01/01/2026',
      tema: 'Test',
      estado: 'ABIERTA',
    );

    final estudiantes = [
      Estudiante(
          id: 'e1',
          cursoId: curso.id,
          numeroOrden: 1,
          codigoUnsaac: '100001',
          nombres: 'Juan',
          apellidos: 'Pérez'),
      Estudiante(
          id: 'e2',
          cursoId: curso.id,
          numeroOrden: 2,
          codigoUnsaac: '100002',
          nombres: 'María',
          apellidos: 'López'),
      Estudiante(
          id: 'e3',
          cursoId: curso.id,
          numeroOrden: 3,
          codigoUnsaac: '100003',
          nombres: 'Carlos',
          apellidos: 'Gómez'),
    ];

    final participaciones = [
      Participacion(
          id: 'p1',
          sesionId: sesion.id,
          estudianteId: 'e1',
          puntos: 10,
          motivo: 'Test',
          timestamp: DateTime.now()),
      Participacion(
          id: 'p2',
          sesionId: sesion.id,
          estudianteId: 'e2',
          puntos: 5,
          motivo: 'Test',
          timestamp: DateTime.now()),
      // e3 no participa (0 puntos)
    ];

    /// Cálculo local del ranking (réplica del algoritmo del repositorio)
    List<EstudianteRanking> calcularRanking(
        List<Estudiante> estudiantes,
        List<Participacion> participaciones,
        String sesionId) {
      final mapPuntosSesion = <String, int>{};
      final mapPuntosTotales = <String, int>{};

      for (final p in participaciones) {
        mapPuntosTotales[p.estudianteId] =
            (mapPuntosTotales[p.estudianteId] ?? 0) + p.puntos;
        if (p.sesionId == sesionId) {
          mapPuntosSesion[p.estudianteId] =
              (mapPuntosSesion[p.estudianteId] ?? 0) + p.puntos;
        }
      }

      int maxSesion = 0;
      int maxTotal = 0;
      for (final e in estudiantes) {
        final pts = mapPuntosSesion[e.id] ?? 0;
        if (pts > maxSesion) maxSesion = pts;
        final tot = mapPuntosTotales[e.id] ?? 0;
        if (tot > maxTotal) maxTotal = tot;
      }

      final lista = estudiantes.map((e) {
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

    test('El estudiante con mayor puntaje obtiene exactamente nota 20.0', () {
      final ranking =
          calcularRanking(estudiantes, participaciones, sesion.id);
      expect(ranking, isNotEmpty);
      final primerLugar = ranking.first;
      expect(primerLugar.estudiante.id, equals('e1'));
      expect(primerLugar.notaSesion, equals(20.0));
    });

    test('Estudiante con 5 pts recibe nota proporcional (10.0 de 20.0)', () {
      final ranking =
          calcularRanking(estudiantes, participaciones, sesion.id);
      final segundo = ranking.firstWhere((r) => r.estudiante.id == 'e2');
      expect(segundo.notaSesion, equals(10.0));
    });

    test('Estudiante con 0 puntos obtiene nota 0.0', () {
      final ranking =
          calcularRanking(estudiantes, participaciones, sesion.id);
      final tercero = ranking.firstWhere((r) => r.estudiante.id == 'e3');
      expect(tercero.puntosSesion, equals(0));
      expect(tercero.notaSesion, equals(0.0));
    });

    test('La lista está ordenada descendentemente por puntos', () {
      final ranking =
          calcularRanking(estudiantes, participaciones, sesion.id);
      for (int i = 0; i < ranking.length - 1; i++) {
        expect(ranking[i].puntosSesion,
            greaterThanOrEqualTo(ranking[i + 1].puntosSesion));
      }
    });

    test('Sin participaciones, todos tienen nota 0.0', () {
      final ranking = calcularRanking(estudiantes, [], sesion.id);
      for (final r in ranking) {
        expect(r.notaSesion, equals(0.0));
        expect(r.puntosSesion, equals(0));
      }
    });
  });
}
