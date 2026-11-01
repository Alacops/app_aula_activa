import 'package:flutter_test/flutter_test.dart';
import 'package:app_aula_activa/repositories/aula_repository.dart';

void main() {
  group('Pruebas del Repositorio Reactivo AulaRepository', () {
    late AulaRepository repository;

    setUp(() async {
      repository = await AulaRepository.inicializarDemo();
    });

    test('Asignación individual de puntos incrementa la puntuación del estudiante', () async {
      final rankingInicial = repository.obtenerRankingSesion();
      final objetivo = rankingInicial.first;
      final puntosPrevios = objetivo.puntosSesion;

      await repository.asignarPuntos(
        estudianteId: objetivo.estudiante.id,
        puntos: 2,
        motivo: 'Pregunta de alta complejidad',
      );

      final rankingActualizado = repository.obtenerRankingSesion();
      final actualizado = rankingActualizado.firstWhere(
        (r) => r.estudiante.id == objetivo.estudiante.id,
      );

      expect(actualizado.puntosSesion, equals(puntosPrevios + 2));
    });

    test('Asignación simultánea masiva otorga puntos a todos los estudiantes seleccionados a la vez', () async {
      final ranking = repository.obtenerRankingSesion();
      expect(ranking.length, greaterThanOrEqualTo(3));

      final id1 = ranking[0].estudiante.id;
      final id2 = ranking[1].estudiante.id;
      final pts1Antes = ranking[0].puntosSesion;
      final pts2Antes = ranking[1].puntosSesion;

      await repository.asignarPuntosMultiples(
        estudianteIds: [id1, id2],
        puntos: 3,
        motivo: 'Dinámica grupal de resolución',
      );

      final rankingDespues = repository.obtenerRankingSesion();
      final est1 = rankingDespues.firstWhere((r) => r.estudiante.id == id1);
      final est2 = rankingDespues.firstWhere((r) => r.estudiante.id == id2);

      expect(est1.puntosSesion, equals(pts1Antes + 3));
      expect(est2.puntosSesion, equals(pts2Antes + 3));
    });

    test('Los streams emiten listas de ranking ordenadas con posiciones válidas (1, 2, 3...)', () async {
      final streamFuture = repository.rankingSesionStream.first;
      repository.asignarPuntos(
        estudianteId: repository.estudiantes.first.id,
        puntos: 1,
      );

      final emision = await streamFuture;
      expect(emision, isNotEmpty);
      expect(emision.first.posicion, equals(1));
    });
  });
}
