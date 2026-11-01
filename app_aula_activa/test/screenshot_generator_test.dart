import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_aula_activa/main.dart';

class LocalTestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // Si GoogleFonts o Flutter busca el manifest de assets
    if (key == 'AssetManifest.json') {
      final manifest = {
        'assets/images/logo_unsaac.png': ['assets/images/logo_unsaac.png'],
        'assets/fonts/Inter-Regular.ttf': ['assets/fonts/Inter-Regular.ttf'],
        'assets/fonts/Inter-Bold.ttf': ['assets/fonts/Inter-Bold.ttf'],
        'assets/fonts/Inter-Medium.ttf': ['assets/fonts/Inter-Medium.ttf'],
        'assets/fonts/Inter-SemiBold.ttf': ['assets/fonts/Inter-SemiBold.ttf'],
      };
      final utf8Bytes = utf8.encode(jsonEncode(manifest));
      return ByteData.view(Uint8List.fromList(utf8Bytes).buffer);
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

Future<void> cargarFuentes() async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final iconBytes = File(r'C:\Users\PC\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf').readAsBytesSync();
  final iconLoader = FontLoader('MaterialIcons');
  iconLoader.addFont(Future.value(ByteData.view(iconBytes.buffer)));
  await iconLoader.load();

  final fontRegular = File('assets/fonts/Inter-Regular.ttf').readAsBytesSync();
  final fontBold = File('assets/fonts/Inter-Bold.ttf').readAsBytesSync();

  for (final name in [
    'Inter',
    'Inter_regular',
    'Inter_400',
    'Inter_500',
    'Inter_medium',
    'Inter_600',
    'Inter_semibold',
    'Inter_700',
    'Inter_bold'
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

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await cargarFuentes();
  });

  testWidgets('Generar captura HD de SelectorRolScreen con fuentes e iconos reales', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(828, 1792);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: LocalTestAssetBundle(),
        child: RepaintBoundary(
          key: key,
          child: const AulaActivaApp(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final file = File('test/screenshots/01_selector_rol.png');
      await file.writeAsBytes(bytes);
    });

    expect(File('test/screenshots/01_selector_rol.png').existsSync(), isTrue);
  });
}
