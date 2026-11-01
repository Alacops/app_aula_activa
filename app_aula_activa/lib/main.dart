import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/services/docente_service.dart';
import 'core/services/supabase_service.dart';
import 'screens/selector_rol_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barra de estado transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar servicios en paralelo
  await Future.wait([
    DocenteService.instance.initialize(),
    SupabaseService.instance.initialize(),
  ]);

  runApp(const AulaActivaApp());
}

class AulaActivaApp extends StatelessWidget {
  const AulaActivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AulaActiva UNSAAC',
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
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.granateUnsaac,
          foregroundColor: AppColors.blanco,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: AppColors.granateUnsaac, width: 1.8),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.borde),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle:
              const TextStyle(color: AppColors.textoSecundario, fontSize: 14),
        ),
      ),
      home: const SelectorRolScreen(),
    );
  }
}
