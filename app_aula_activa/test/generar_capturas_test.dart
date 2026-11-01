import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_aula_activa/core/constants/app_colors.dart';
import 'package:app_aula_activa/core/services/curso_service.dart';
import 'package:app_aula_activa/core/services/docente_service.dart';
import 'package:app_aula_activa/models/curso.dart';
import 'package:app_aula_activa/models/estudiante.dart';
import 'package:app_aula_activa/repositories/aula_repository.dart';

import 'package:app_aula_activa/screens/selector_rol_screen.dart';
import 'package:app_aula_activa/screens/estudiante/estudiante_login_screen.dart';
import 'package:app_aula_activa/screens/estudiante/estudiante_dashboard_screen.dart';
import 'package:app_aula_activa/screens/estudiante/carnet_estudiante_qr_dialog.dart';
import 'package:app_aula_activa/screens/docente/docente_login_screen.dart';
import 'package:app_aula_activa/screens/docente/registro_docente_screen.dart';
import 'package:app_aula_activa/screens/docente/mis_cursos_screen.dart';
import 'package:app_aula_activa/screens/docente/docente_dashboard_screen.dart';
import 'package:app_aula_activa/screens/docente/qr_aula_dialog.dart';
import 'package:app_aula_activa/widgets/calculadora_vigesimal_dialog.dart';
import 'package:app_aula_activa/screens/docente/asignar_puntos_dialog.dart';
import 'package:app_aula_activa/screens/docente/asignacion_multiple_dialog.dart';
import 'package:app_aula_activa/screens/docente/gestion_alumnos_screen.dart';

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.json') {
      final manifest = {
        'assets/images/logo_unsaac.png': ['assets/images/logo_unsaac.png'],
        'assets/fonts/Inter-Regular.ttf': ['assets/fonts/Inter-Regular.ttf'],
        'assets/fonts/Inter-Bold.ttf': ['assets/fonts/Inter-Bold.ttf'],
        'assets/fonts/Inter-Medium.ttf': ['assets/fonts/Inter-Medium.ttf'],
        'assets/fonts/Inter-SemiBold.ttf': ['assets/fonts/Inter-SemiBold.ttf'],
        'assets/fonts/Inter-ExtraBold.ttf': ['assets/fonts/Inter-ExtraBold.ttf'],
        'assets/fonts/Inter-Black.ttf': ['assets/fonts/Inter-Black.ttf'],
      };
      return ByteData.view(Uint8List.fromList(utf8.encode(jsonEncode(manifest))).buffer);
    }
    if (key == 'AssetManifest.bin') {
      return ByteData(0);
    }

    if (key.endsWith('Inter-Regular.ttf') || key.endsWith('Inter-Regular')) {
      final bytes = File('assets/fonts/Inter-Regular.ttf').readAsBytesSync();
      return ByteData.view(bytes.buffer);
    }
    if (key.endsWith('Inter-Bold.ttf') || key.endsWith('Inter-Bold')) {
      final bytes = File('assets/fonts/Inter-Bold.ttf').readAsBytesSync();
      return ByteData.view(bytes.buffer);
    }
    if (key.endsWith('Inter-Medium.ttf') || key.endsWith('Inter-Medium')) {
      final bytes = File('assets/fonts/Inter-Medium.ttf').readAsBytesSync();
      return ByteData.view(bytes.buffer);
    }
    if (key.endsWith('Inter-SemiBold.ttf') || key.endsWith('Inter-SemiBold')) {
      final bytes = File('assets/fonts/Inter-SemiBold.ttf').readAsBytesSync();
      return ByteData.view(bytes.buffer);
    }

    final file = File(key);
    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      return ByteData.view(bytes.buffer);
    }
    return ByteData(0);
  }
}

Future<void> inicializarFuentesTest() async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final iconBytes = File(r'C:\Users\PC\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf').readAsBytesSync();
  final iconLoader = FontLoader('MaterialIcons');
  iconLoader.addFont(Future.value(ByteData.view(iconBytes.buffer)));
  await iconLoader.load();

  final fontRegular = File('assets/fonts/Inter-Regular.ttf').readAsBytesSync();
  final fontBold = File('assets/fonts/Inter-Bold.ttf').readAsBytesSync();

  for (final name in [
    '',
    'Roboto',
    'Inter',
    'Inter_regular',
    'Inter_400',
    'Inter_500',
    'Inter_medium',
    'Inter_600',
    'Inter_semibold',
    'Inter_700',
    'Inter_bold',
    'Inter_800',
    'Inter_extrabold'
  ]) {
    final loader = FontLoader(name);
    final bytes = name.toLowerCase().contains('bold') ||
            name.toLowerCase().contains('semibold') ||
            name.contains('600') ||
            name.contains('700')
        ? fontBold
        : fontRegular;
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

Widget envolverEnApp(Widget contenido) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.fondo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.granateUnsaac,
        primary: AppColors.granateUnsaac,
        secondary: AppColors.doradoUnsaac,
        surface: AppColors.blanco,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.granateUnsaac,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.blanco,
        ),
      ),
      textTheme: const TextTheme().apply(fontFamily: 'Inter'),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.granateUnsaac, width: 1.8),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.borde),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    home: DefaultAssetBundle(
      bundle: TestAssetBundle(),
      child: contenido,
    ),
  );
}

Future<void> capturar(WidgetTester tester, GlobalKey key, String nombre) async {
  await tester.pumpAndSettle();

  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = Directory('test/screenshots');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final file = File('test/screenshots/$nombre.png');
    await file.writeAsBytes(bytes);
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await inicializarFuentesTest();
  });

  const tamanoMovil = Size(828, 1792);

  final cursoMock = Curso(
    id: 'curso-ds2',
    docenteId: 'doc-yover',
    codigo: 'IF616AIN',
    nombre: 'Desarrollo de Software II',
    semestre: '2026-II',
    docente: 'Mtro. Ing. Yover Collantes Valer',
  );

  final docenteMock = const Docente(
    id: 'doc-yover',
    nombres: 'Yover',
    apellidos: 'Collantes Valer',
    correo: 'yover.collantes@unsaac.edu.pe',
    pin: '1234',
  );

  final estudianteMock = Estudiante(
    id: 'e-1',
    cursoId: 'curso-ds2',
    numeroOrden: 1,
    codigoUnsaac: '174449',
    nombres: 'Edmil Jampier',
    apellidos: 'Saire Bustamante',
  );

  testWidgets('01_selector_rol', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(const SelectorRolScreen()),
      ),
    );
    await capturar(tester, key, '01_selector_rol');
  });

  testWidgets('02_estudiante_login_sin_sesion', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    AulaRepository.limpiar();

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(const EstudianteLoginScreen()),
      ),
    );
    await capturar(tester, key, '02_estudiante_login_sin_sesion');
  });

  testWidgets('03_estudiante_login_con_sesion', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await AulaRepository.inicializar(
      curso: cursoMock,
      temaSesion: 'Sesión 07: Clean Architecture y BLoC',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(const EstudianteLoginScreen()),
      ),
    );
    await capturar(tester, key, '03_estudiante_login_con_sesion');
  });

  testWidgets('04_estudiante_dashboard', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await AulaRepository.inicializar(
      curso: cursoMock,
      temaSesion: 'Sesión 07: Clean Architecture y BLoC',
    );
    await AulaRepository.instance.asignarPuntos(estudianteId: 'e-1', puntos: 4, motivo: 'Participación destacada');

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(EstudianteDashboardScreen(estudiante: estudianteMock)),
      ),
    );
    await capturar(tester, key, '04_estudiante_dashboard');
  });

  testWidgets('05_estudiante_carnet_qr', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(
          Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: CarnetEstudianteQrDialog(
                estudiante: estudianteMock,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await capturar(tester, key, '05_estudiante_carnet_qr');
  });

  testWidgets('06_docente_login', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(const DocenteLoginScreen()),
      ),
    );
    await capturar(tester, key, '06_docente_login');
  });

  testWidgets('07_docente_registro', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(const RegistroDocenteScreen()),
      ),
    );
    await capturar(tester, key, '07_docente_registro');
  });

  testWidgets('08_docente_mis_cursos', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await CursoService.instance.crearCurso(
      docenteId: docenteMock.id,
      docenteNombre: docenteMock.nombreCompleto,
      codigo: 'IF616AIN',
      nombre: 'Desarrollo de Software II',
      semestre: '2026-II',
    );
    await CursoService.instance.crearCurso(
      docenteId: docenteMock.id,
      docenteNombre: docenteMock.nombreCompleto,
      codigo: 'IF450AIN',
      nombre: 'Inteligencia Artificial',
      semestre: '2026-II',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(MisCursosScreen(docente: docenteMock)),
      ),
    );
    await capturar(tester, key, '08_docente_mis_cursos');
  });

  testWidgets('09_docente_dashboard_sesion', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await AulaRepository.inicializar(
      curso: cursoMock,
      temaSesion: 'Sesión 07: Clean Architecture y BLoC',
    );
    await AulaRepository.instance.asignarPuntos(estudianteId: 'e-1', puntos: 3, motivo: 'Respuesta conceptual');
    await AulaRepository.instance.asignarPuntos(estudianteId: 'e-2', puntos: 2, motivo: 'Aporte en clase');

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(const DocenteDashboardScreen()),
      ),
    );
    await capturar(tester, key, '09_docente_dashboard_sesion');
  });

  testWidgets('10_docente_dashboard_modo_rapido', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await AulaRepository.inicializar(
      curso: cursoMock,
      temaSesion: 'Sesión 07: Clean Architecture y BLoC',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(const DocenteDashboardScreen()),
      ),
    );
    // Cambiar a pestaña Modo Rápido (índice 1)
    await tester.tap(find.text('Rápido (#)'));
    await tester.pumpAndSettle();

    await capturar(tester, key, '10_docente_dashboard_modo_rapido');
  });

  testWidgets('11_docente_dashboard_acumulado', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await AulaRepository.inicializar(
      curso: cursoMock,
      temaSesion: 'Sesión 07: Clean Architecture y BLoC',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(const DocenteDashboardScreen()),
      ),
    );
    // Cambiar a pestaña Ranking del Semestre (índice 1)
    await tester.tap(find.text('Semestre'));
    await tester.pumpAndSettle();

    await capturar(tester, key, '11_docente_dashboard_acumulado');
  });

  testWidgets('12_docente_qr_aula_dialog', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await AulaRepository.inicializar(
      curso: cursoMock,
      temaSesion: 'Sesión 07: Clean Architecture y BLoC',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(
          const Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: QrAulaDialog(),
            ),
          ),
        ),
      ),
    );
    await capturar(tester, key, '12_docente_qr_aula_dialog');
  });

  testWidgets('13_docente_calculadora_vigesimal', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(
          const Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: CalculadoraVigesimalDialog(),
            ),
          ),
        ),
      ),
    );
    await capturar(tester, key, '13_docente_calculadora_vigesimal');
  });

  testWidgets('14_docente_asignar_puntos_dialog', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await AulaRepository.inicializar(
      curso: cursoMock,
      temaSesion: 'Sesión 07: Clean Architecture y BLoC',
    );
    final ranking = AulaRepository.instance.obtenerRankingSesion();

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(
          Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: AsignarPuntosDialog(rankingItem: ranking.first),
            ),
          ),
        ),
      ),
    );
    await capturar(tester, key, '14_docente_asignar_puntos_dialog');
  });

  testWidgets('15_docente_asignacion_multiple_dialog', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await AulaRepository.inicializar(
      curso: cursoMock,
      temaSesion: 'Sesión 07: Clean Architecture y BLoC',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(
          Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: AsignacionMultipleDialog(
                estudiantes: AulaRepository.instance.estudiantes,
              ),
            ),
          ),
        ),
      ),
    );
    await capturar(tester, key, '15_docente_asignacion_multiple_dialog');
  });

  testWidgets('16_docente_gestion_alumnos', (tester) async {
    tester.view.physicalSize = tamanoMovil;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await CursoService.instance.agregarEstudiante(
      cursoId: cursoMock.id,
      numeroOrden: 1,
      nombres: 'Edmil Jampier',
      apellidos: 'Saire Bustamante',
      codigoUnsaac: '174449',
    );
    await CursoService.instance.agregarEstudiante(
      cursoId: cursoMock.id,
      numeroOrden: 2,
      nombres: 'Diego Fernando',
      apellidos: 'Quispe Mamani',
      codigoUnsaac: '221456',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: envolverEnApp(GestionAlumnosScreen(curso: cursoMock)),
      ),
    );
    await capturar(tester, key, '16_docente_gestion_alumnos');
  });
}
