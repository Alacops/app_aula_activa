import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_aula_activa/main.dart';
import 'package:app_aula_activa/models/curso.dart';
import 'package:app_aula_activa/repositories/aula_repository.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Verificación de carga inicial de AulaActiva UNSAAC', (WidgetTester tester) async {
    await tester.pumpWidget(const AulaActivaApp());

    // Verificar que los títulos y opciones clave se rendericen correctamente
    expect(find.text('AulaActiva UNSAAC'), findsOneWidget);
    expect(find.text('Semestre Académico 2026-II'), findsOneWidget);
    expect(find.text('Desarrollo de Software II — 2026-II'), findsNothing);
    expect(find.text('Soy Estudiante'), findsOneWidget);
    expect(find.text('Soy Docente'), findsOneWidget);
  });

  test('Validación de control de concurrencia: bloqueo de celulares duplicados en un mismo número', () async {
    final curso = Curso(
      id: 'c-test',
      docenteId: 'd-test',
      codigo: 'IF616AIN',
      nombre: 'Desarrollo de Software II',
      semestre: '2026-II',
      docente: 'Mtro. Yover Collantes',
    );

    final repo = await AulaRepository.inicializar(curso: curso, temaSesion: 'Sesión Concurrencia');

    // 1. El primer celular reclama el número de orden 1
    final res1 = repo.reclamarNumeroOrden(1);
    expect(res1, isNull, reason: 'El primer celular debe reclamar con éxito');
    expect(repo.isNumeroOrdenOcupado(1), isTrue);

    // 2. Un segundo celular intenta reclamar el MISMO número de orden 1
    final res2 = repo.reclamarNumeroOrden(1);
    expect(res2, isNotNull, reason: 'Debe rechazar al segundo celular');
    expect(res2, contains('ya está ocupado por otro celular'));

    // 3. El primer estudiante sale y libera el número de orden 1
    repo.liberarNumeroOrden(1);
    expect(repo.isNumeroOrdenOcupado(1), isFalse);

    // 4. Ahora el número vuelve a estar disponible para ser tomado
    final res3 = repo.reclamarNumeroOrden(1);
    expect(res3, isNull);
    expect(repo.isNumeroOrdenOcupado(1), isTrue);
  });
}
