import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../models/estudiante.dart';

/// Modal responsivo de Credencial Digital con Código QR institucional del estudiante
class CarnetEstudianteQrDialog extends StatelessWidget {
  final Estudiante estudiante;

  const CarnetEstudianteQrDialog({
    super.key,
    required this.estudiante,
  });

  @override
  Widget build(BuildContext context) {
    final payloadEstudiante = jsonEncode({
      'tipo': 'estudiante_unsaac',
      'id': estudiante.id,
      'codigo_unsaac': estudiante.codigoUnsaac,
      'numero_orden': estudiante.numeroOrden,
      'nombres': estudiante.nombres,
      'apellidos': estudiante.apellidos,
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 400 ? 370.0 : screenWidth * 0.90;
    final qrSize = dialogWidth > 340 ? 190.0 : 160.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blanco,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Encabezado Institucional ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.granateUnsaac,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        // Escudo UNSAAC con borde dorado calculado
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.blanco,
                            border: Border.all(
                              color: AppColors.doradoUnsaac,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo_unsaac.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.school_rounded,
                                color: AppColors.granateUnsaac,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UNSAAC · AULAACTIVA',
                                style: TextStyle(
                                  color: AppColors.doradoClaro,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                'Credencial Universitaria',
                                style: TextStyle(
                                  color: AppColors.blanco,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.blanco, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // ─── Contenido del Carnet ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      children: [
                        // Número de orden institucional destacado
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.doradoUnsaac.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.doradoUnsaac.withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            'ORDEN EN LISTA #${estudiante.numeroOrden.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.granateOscuro,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nombres y Apellidos del Estudiante
                        Text(
                          estudiante.nombreCompleto,
                          style: AppStyles.subtitulo.copyWith(
                            fontSize: 16,
                            color: AppColors.azulPizarra,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),

                        // Código institucional
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.fondo,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borde),
                          ),
                          child: Text(
                            'Código: ${estudiante.codigoUnsaac}',
                            style: AppStyles.cuerpoSecundario.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.azulPizarra,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Contenedor del Código QR con Logo embebido y bordes dorados
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.blanco,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.borde,
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: payloadEstudiante,
                            version: QrVersions.auto,
                            errorCorrectionLevel: QrErrorCorrectLevel.Q,
                            size: qrSize,
                            embeddedImage: const AssetImage(
                                'assets/images/logo_unsaac.png'),
                            embeddedImageStyle: const QrEmbeddedImageStyle(
                              size: Size(36, 36),
                            ),
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.granateUnsaac,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.azulPizarra,
                            ),
                            errorStateBuilder: (cxt, err) {
                              return SizedBox(
                                width: qrSize,
                                height: qrSize,
                                child: Center(
                                  child: Text(
                                    'QR Error: $err',
                                    style: const TextStyle(fontSize: 10, color: Colors.red),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Indicador informativo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_scanner_rounded,
                                size: 14, color: AppColors.textoSecundario),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Muestra este carnet para que el docente registre tu asistencia o te asigne puntos',
                                style: AppStyles.cuerpoSecundario
                                    .copyWith(fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
