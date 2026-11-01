import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppStyles {
  static const double espaciadoBase = 8.0;
  static const double radioBorde = 12.0;
  static const double radioTarjeta = 16.0;

  // Tipografía Sobria y Jerárquica
  static TextStyle get tituloPrincipal => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.azulPizarra,
        letterSpacing: -0.5,
      );

  static TextStyle get tituloBlanco => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.blanco,
        letterSpacing: -0.3,
      );

  static TextStyle get subtitulo => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.azulPizarra,
      );

  static TextStyle get cuerpo => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.azulPizarra,
      );

  static TextStyle get cuerpoSecundario => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textoSecundario,
      );

  static TextStyle get notaVigesimal => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.granateUnsaac,
      );

  // Decoraciones de Contenedores y Tarjetas
  static BoxDecoration get decoracionTarjeta => BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(radioTarjeta),
        border: Border.all(color: AppColors.borde, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get decoracionTarjetaGranate => BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.granateUnsaac, AppColors.granateOscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radioTarjeta),
        boxShadow: const [
          BoxShadow(
            color: Color(0x227A1F2B),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      );
}
