import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../repositories/aula_repository.dart';

/// Diálogo y Modal de proyección del Código QR de ingreso al aula
class QrAulaDialog extends StatelessWidget {
  const QrAulaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AulaRepository.instance;
    final curso = repo.cursoActual;
    final sesion = repo.sesionActual;
    final payloadQr = repo.generarCodigoQrSesion();
    final pin = repo.pinSesion;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.blanco,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabecera institucional
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.blanco,
                      border: Border.all(
                        color: AppColors.doradoUnsaac,
                        width: 1.8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_unsaac.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.school_rounded,
                          color: AppColors.granateUnsaac,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acceso al Aula UNSAAC',
                          style: AppStyles.subtitulo.copyWith(
                            color: AppColors.granateUnsaac,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${curso.codigo} · ${curso.nombre}',
                          style: AppStyles.cuerpoSecundario.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textoSecundario),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Contenedor del QR con marco institucional y Logo embebido
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blanco,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.doradoUnsaac.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: payloadQr,
                      version: QrVersions.auto,
                      size: 220,
                      embeddedImage: const AssetImage('assets/images/logo_unsaac.png'),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(38, 38),
                      ),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.granateUnsaac,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.granateOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Escanea con la app AulaActiva',
                      style: AppStyles.cuerpoSecundario.copyWith(
                        fontSize: 11,
                        color: AppColors.azulPizarra,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // PIN alternativo para estudiantes sin cámara
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.fondo,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borde),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pin_rounded,
                          size: 20, color: AppColors.granateUnsaac),
                      const SizedBox(width: 8),
                      const Text(
                        'PIN de Sesión: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.azulPizarra,
                        ),
                      ),
                      Text(
                        pin,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: AppColors.granateUnsaac,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: 'Copiar PIN',
                        color: AppColors.textoSecundario,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: pin));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PIN copiado al portapapeles'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Datos de la sesión
              Row(
                children: [
                  const Icon(Icons.event_note_rounded,
                      size: 16, color: AppColors.doradoUnsaac),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sesión: ${sesion.tema} (${sesion.fecha})',
                      style: AppStyles.cuerpoSecundario.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Botones de acción: Proyector y Compartir
              Row(
                children: [
                  // Botón Pantalla Completa (Proyector)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.fullscreen_rounded, size: 20),
                      label: const Text('Proyector'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.granateUnsaac,
                        side: const BorderSide(color: AppColors.granateUnsaac),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProyectorQrScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Botón Compartir
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Compartir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.granateUnsaac,
                        foregroundColor: AppColors.blanco,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // ignore: deprecated_member_use
                        Share.share(
                          'Únete a la sesión de ${curso.nombre} (${curso.codigo}) en AulaActiva UNSAAC. Tema: ${sesion.tema}. PIN de acceso: $pin',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla completa de Proyección de Código QR para el Cañón Multimedia del aula
class ProyectorQrScreen extends StatelessWidget {
  const ProyectorQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AulaRepository.instance;
    final curso = repo.cursoActual;
    final sesion = repo.sesionActual;
    final payloadQr = repo.generarCodigoQrSesion();
    final pin = repo.pinSesion;

    return Scaffold(
      backgroundColor: AppColors.granateOscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.blanco,
        title: const Text('Modo Proyector de Aula'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_fullscreen_rounded),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Salir de modo proyector',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo e Institución
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.blanco,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_unsaac.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school_rounded,
                          color: AppColors.granateUnsaac,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UNIVERSIDAD NACIONAL DE SAN ANTONIO ABAD DEL CUSCO',
                        style: TextStyle(
                          color: AppColors.doradoClaro,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'AulaActiva — Plataforma de Participación y Gamificación',
                        style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Información del curso
              Text(
                '${curso.codigo} — ${curso.nombre}',
                style: const TextStyle(
                  color: AppColors.blanco,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Sesión: ${sesion.tema} · ${sesion.fecha}',
                style: const TextStyle(
                  color: AppColors.doradoClaro,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Tarjeta gigante con el QR
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.blanco,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: AppColors.doradoUnsaac, width: 4),
                ),
                child: QrImageView(
                  data: payloadQr,
                  version: QrVersions.auto,
                  size: 280,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.granateUnsaac,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.azulPizarra,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // PIN de acceso alternativo gigante
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.blanco.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.doradoUnsaac.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'O INGRESA CON EL PIN: ',
                      style: TextStyle(
                        color: AppColors.blanco,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      pin,
                      style: const TextStyle(
                        color: AppColors.doradoClaro,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Abre AulaActiva en tu teléfono celular y selecciona "📷 Escanear QR del Aula"',
                style: TextStyle(
                  color: AppColors.blanco,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
