import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_aula_activa/models/curso.dart';
import 'package:app_aula_activa/models/estudiante.dart';
import 'package:app_aula_activa/models/estudiante_ranking.dart';
import 'package:app_aula_activa/repositories/aula_repository.dart';
import 'package:app_aula_activa/widgets/modo_rapido_matriz_widget.dart';

void main() {
  group('Pruebas de Widget Modo Rápido (Matriz de Números)', () {
    late List<EstudianteRanking> rankingMock;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AulaRepository.inicializar(
        curso: Curso(
          id: 'c-test',
          docenteId: 'd-test',
          codigo: 'IF616AIN',
          nombre: 'Desarrollo de Software II',
          semestre: '2026-II',
          docente: 'Mtro. Ing. Yover Collantes Valer',
        ),
        temaSesion: 'Sesión Test',
      );

      rankingMock = [
        EstudianteRanking(
          estudiante: Estudiante(
            id: 'e-1',
            cursoId: 'c-test',
            numeroOrden: 1,
            codigoUnsaac: '174449',
            nombres: 'Edmil Jampier',
            apellidos: 'Saire Bustamante',
          ),
          puntosSesion: 2,
          puntosTotales: 10,
          notaSesion: 20.0,
          notaTotal: 20.0,
          posicion: 1,
        ),
        EstudianteRanking(
          estudiante: Estudiante(
            id: 'e-2',
            cursoId: 'c-test',
            numeroOrden: 14,
            codigoUnsaac: '221456',
            nombres: 'Diego Fernando',
            apellidos: 'Quispe Mamani',
          ),
          puntosSesion: 0,
          puntosTotales: 5,
          notaSesion: 0.0,
          notaTotal: 10.0,
          posicion: 2,
        ),
      ];
    });

    testWidgets('Renderiza selector de puntos y números de orden #01 y #14',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ModoRapidoMatrizWidget(
                ranking: rankingMock,
                esSesionDelDia: true,
              ),
            ),
          ),
        ),
      );

      // Verificar chips de puntos rápidos
      expect(find.text('+1 punto'), findsOneWidget);
      expect(find.text('+2 puntos'), findsOneWidget);
      expect(find.text('+3 puntos'), findsOneWidget);
      expect(find.text('+5 puntos'), findsOneWidget);

      // Verificar que los números de orden aparezcan en formato padded 01 y 14
      expect(find.text('01'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);

      // Verificar que aparezcan los apellidos
      expect(find.text('Saire'), findsOneWidget);
      expect(find.text('Quispe'), findsOneWidget);
    });

    testWidgets('Al pulsar sobre un número en la matriz, asigna puntos inmediatamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ModoRapidoMatrizWidget(
                ranking: rankingMock,
                esSesionDelDia: true,
              ),
            ),
          ),
        ),
      );

      // Tocar en el estudiante #01 (Saire)
      await tester.tap(find.text('01'));
      await tester.pumpAndSettle();

      // Verificar que el estudiante #01 recibió la asignación
      final actualizados = AulaRepository.instance.obtenerRankingSesion();
      final est1 = actualizados.firstWhere((r) => r.estudiante.numeroOrden == 1);
      expect(est1.puntosSesion, greaterThanOrEqualTo(1));
    });
  });
}
