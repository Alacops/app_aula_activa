import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import 'docente/docente_login_screen.dart';
import 'estudiante/estudiante_login_screen.dart';

class SelectorRolScreen extends StatelessWidget {
  const SelectorRolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Logo UNSAAC
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blanco,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo_unsaac.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        color: AppColors.doradoClaro,
                        size: 56,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nombre de la app
              Text(
                'AulaActiva UNSAAC',
                style: AppStyles.tituloPrincipal.copyWith(
                  fontSize: 26,
                  color: AppColors.granateUnsaac,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Interacción y Gamificación en Aula',
                style: AppStyles.subtitulo.copyWith(
                  color: AppColors.azulPizarra,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.doradoUnsaac.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.doradoUnsaac.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    'Semestre Académico 2026-II',
                    style: AppStyles.cuerpoSecundario.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.azulPizarra,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ─── Tarjeta Estudiante ──────────────────────────────────────
              _TarjetaRol(
                titulo: 'Soy Estudiante',
                descripcion:
                    'Ingresa con tu número de orden para participar y ver tu ranking en vivo.',
                icono: Icons.person_rounded,
                colorPrincipal: AppColors.granateUnsaac,
                alPresionar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EstudianteLoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // ─── Tarjeta Docente ─────────────────────────────────────────
              _TarjetaRol(
                titulo: 'Soy Docente',
                descripcion:
                    'Accede con tu PIN para gestionar cursos, alumnos y sesiones.',
                icono: Icons.co_present_rounded,
                colorPrincipal: AppColors.doradoUnsaac,
                alPresionar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DocenteLoginScreen()),
                  );
                },
              ),

              const SizedBox(height: 36),

              // ODS Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.public_rounded,
                      color: AppColors.verdeExito, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'ODS 4 — Educación de Calidad',
                    style: AppStyles.cuerpoSecundario.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaRol extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color colorPrincipal;
  final VoidCallback alPresionar;

  const _TarjetaRol({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colorPrincipal,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blanco,
      borderRadius: BorderRadius.circular(AppStyles.radioTarjeta),
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(AppStyles.radioTarjeta),
        child: Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.radioTarjeta),
            border:
                Border.all(color: colorPrincipal.withValues(alpha: 0.25), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorPrincipal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: colorPrincipal, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: AppStyles.subtitulo.copyWith(fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(descripcion, style: AppStyles.cuerpoSecundario),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textoSecundario),
            ],
          ),
        ),
      ),
    );
  }
}
