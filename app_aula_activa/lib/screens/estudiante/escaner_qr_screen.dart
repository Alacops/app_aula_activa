import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';

/// Pantalla con visor de cámara para escanear el Código QR proyectado por el docente
class EscanerQrScreen extends StatefulWidget {
  const EscanerQrScreen({super.key});

  @override
  State<EscanerQrScreen> createState() => _EscanerQrScreenState();
}

class _EscanerQrScreenState extends State<EscanerQrScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _haDetectado = false;
  bool _linternaEncendida = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _procesarCodigo(String raw) {
    if (_haDetectado) return;
    setState(() => _haDetectado = true);

    try {
      // 1. Intentar decodificar como JSON estructurado de AulaActiva
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic> && data['app'] == 'aulaactiva') {
        Navigator.pop(context, data);
        return;
      }
    } catch (_) {
      // Si no es JSON, verificar si es texto plano o PIN
      if (raw.trim().isNotEmpty) {
        Navigator.pop(context, {'raw': raw.trim()});
        return;
      }
    }

    // Si el QR no es reconocido
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código QR no corresponde a una sesión de AulaActiva UNSAAC.'),
        backgroundColor: AppColors.naranjaAlerta,
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _haDetectado = false);
    });
  }

  void _mostrarDialogoPinManual() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.pin_rounded, color: AppColors.granateUnsaac),
            SizedBox(width: 8),
            Text('Ingreso por PIN', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Si tu cámara no enfoca o no tienes permisos, ingresa el PIN de 4 dígitos mostrado por el docente:',
              style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
              decoration: const InputDecoration(
                hintText: 'Ej. 4921',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.granateUnsaac,
              foregroundColor: AppColors.blanco,
            ),
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.pop(context, {'pin': pin});
              }
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: AppColors.blanco,
        title: const Text('Escanear QR de Sesión'),
        actions: [
          // Linterna / Flash
          IconButton(
            icon: Icon(
              _linternaEncendida
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              color: _linternaEncendida
                  ? AppColors.doradoClaro
                  : AppColors.blanco,
            ),
            tooltip: 'Linterna',
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _linternaEncendida = !_linternaEncendida);
            },
          ),
          // Cambiar cámara
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded),
            tooltip: 'Cambiar Cámara',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Visor de Cámara
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final raw = barcode.rawValue;
                if (raw != null) {
                  _procesarCodigo(raw);
                  break;
                }
              }
            },
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.no_photography_rounded,
                          size: 64, color: AppColors.doradoClaro),
                      const SizedBox(height: 16),
                      const Text(
                        'Cámara no disponible',
                        style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verifica los permisos de cámara de tu dispositivo o ingresa mediante el PIN numérico.',
                        style: TextStyle(
                          color: AppColors.blanco.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.pin_rounded),
                        label: const Text('Ingresar con PIN Manual'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.doradoUnsaac,
                          foregroundColor: AppColors.granateOscuro,
                        ),
                        onPressed: _mostrarDialogoPinManual,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Marco visor gráfico institucional
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.doradoUnsaac,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.doradoUnsaac.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Esquinas decorativas doradas
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.blanco, width: 3),
                          left: BorderSide(color: AppColors.blanco, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.blanco, width: 3),
                          right: BorderSide(color: AppColors.blanco, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.blanco, width: 3),
                          left: BorderSide(color: AppColors.blanco, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.blanco, width: 3),
                          right: BorderSide(color: AppColors.blanco, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // Texto dentro del visor
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Apunta al QR del docente',
                      style: TextStyle(
                        color: AppColors.blanco,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        backgroundColor: Color(0x66000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra inferior con botón de PIN alternativo
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Column(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.dialpad_rounded, size: 20),
                  label: const Text('Ingresar con PIN Numérico'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blanco,
                    backgroundColor: const Color(0x88000000),
                    side: const BorderSide(color: AppColors.doradoClaro),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _mostrarDialogoPinManual,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
