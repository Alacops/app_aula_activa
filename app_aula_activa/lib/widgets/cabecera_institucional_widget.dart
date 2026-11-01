import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class CabeceraInstitucionalWidget extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget? accion;

  const CabeceraInstitucionalWidget({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: AppColors.granateUnsaac,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo UNSAAC pequeño
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blanco,
                border: Border.all(
                    color: AppColors.doradoUnsaac.withValues(alpha: 0.6),
                    width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo_unsaac.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school_rounded,
                    color: AppColors.granateUnsaac,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: AppStyles.tituloBlanco.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1.0),
                  Text(
                    subtitulo,
                    style: AppStyles.cuerpoSecundario.copyWith(
                      color: AppColors.blanco.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ?accion,
          ],
        ),
      ),
    );
  }
}
