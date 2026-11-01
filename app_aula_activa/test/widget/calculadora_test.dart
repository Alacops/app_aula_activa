import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_aula_activa/widgets/calculadora_vigesimal_dialog.dart';

void main() {
  testWidgets('CalculadoraVigesimalDialog renderiza fórmula, escudo UNSAAC y calcula nota proporcional',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CalculadoraVigesimalDialog(
            puntosIniciales: 5,
            puntosMaximosIniciales: 10,
          ),
        ),
      ),
    );

    // Verificar títulos y elementos
    expect(find.text('Cálculo de Nota Vigesimal'), findsOneWidget);
    expect(find.text('UNSAAC · AULAACTIVA'), findsOneWidget);
    expect(find.text('Nota = ( Mis Puntos / Puntos Máximos ) × 20.0'), findsOneWidget);

    // 5 de 10 puntos es exactamente 10.0 de 20.0
    expect(find.text('10.0'), findsOneWidget);
    expect(find.text('5 pts'), findsOneWidget);
    expect(find.text('10 pts'), findsOneWidget);
  });
}
