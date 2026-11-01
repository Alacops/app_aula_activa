import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_aula_activa/models/estudiante.dart';
import 'package:app_aula_activa/models/estudiante_ranking.dart';
import 'package:app_aula_activa/widgets/cabecera_institucional_widget.dart';
import 'package:app_aula_activa/widgets/podio_widget.dart';
import 'package:app_aula_activa/widgets/tabla_ranking_widget.dart';

void main() {
  group('Pruebas de Widgets y Componentes Visuales (UI/UX UNSAAC)', () {
    testWidgets('CabeceraInstitucionalWidget renderiza títulos institucionales y acciones',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CabeceraInstitucionalWidget(
              titulo: 'Desarrollo de Software II (IF616AIN)',
              subtitulo: 'Docente: Mtro. Ing. Yover Collantes Valer',
              accion: Icon(Icons.table_chart_rounded),
            ),
          ),
        ),
      );

      expect(find.text('Desarrollo de Software II (IF616AIN)'), findsOneWidget);
      expect(find.text('Docente: Mtro. Ing. Yover Collantes Valer'), findsOneWidget);
      expect(find.byIcon(Icons.table_chart_rounded), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('PodioWidget renderiza los 3 primeros lugares con medallas e insignias',
        (WidgetTester tester) async {
      final itemsPrueba = [
        EstudianteRanking(
          estudiante: Estudiante(
            id: '1',
            cursoId: 'c1',
            numeroOrden: 1,
            codigoUnsaac: '174449',
            nombres: 'Edmil Jampier',
            apellidos: 'Saire Bustamante',
          ),
          puntosSesion: 5,
          puntosTotales: 15,
          notaSesion: 20.0,
          notaTotal: 20.0,
          posicion: 1,
        ),
        EstudianteRanking(
          estudiante: Estudiante(
            id: '2',
            cursoId: 'c1',
            numeroOrden: 2,
            codigoUnsaac: '182341',
            nombres: 'Alain Armando',
            apellidos: 'Condori Contreras',
          ),
          puntosSesion: 4,
          puntosTotales: 12,
          notaSesion: 16.0,
          notaTotal: 16.0,
          posicion: 2,
        ),
        EstudianteRanking(
          estudiante: Estudiante(
            id: '3',
            cursoId: 'c1',
            numeroOrden: 3,
            codigoUnsaac: '193452',
            nombres: 'Axel',
            apellidos: 'Aranibar Rojas',
          ),
          puntosSesion: 3,
          puntosTotales: 10,
          notaSesion: 12.0,
          notaTotal: 13.3,
          posicion: 3,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PodioWidget(
                ranking: itemsPrueba,
                esSesionDelDia: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Podio de la Sesión'), findsOneWidget);
      expect(find.text('1°'), findsOneWidget);
      expect(find.text('2°'), findsOneWidget);
      expect(find.text('3°'), findsOneWidget);
      expect(find.text('N° 1'), findsOneWidget);
      expect(find.text('N° 2'), findsOneWidget);
      expect(find.text('N° 3'), findsOneWidget);
    });

    testWidgets('TablaRankingWidget muestra estudiantes y notas vigesimales sin overflow',
        (WidgetTester tester) async {
      final items = [
        EstudianteRanking(
          estudiante: Estudiante(
            id: '1',
            cursoId: 'c1',
            numeroOrden: 1,
            codigoUnsaac: '174449',
            nombres: 'Edmil Jampier',
            apellidos: 'Saire Bustamante',
          ),
          puntosSesion: 5,
          puntosTotales: 15,
          notaSesion: 20.0,
          notaTotal: 20.0,
          posicion: 1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TablaRankingWidget(
                ranking: items,
                esSesionDelDia: true,
                esModoDocente: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Saire Bustamante, Edmil Jampier'), findsOneWidget);
      expect(find.text('20.0'), findsOneWidget);
      expect(find.text('Escala 0-20'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_rounded), findsOneWidget);
    });
  });
}
