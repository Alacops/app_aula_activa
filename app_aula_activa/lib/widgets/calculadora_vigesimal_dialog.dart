import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Diálogo interactivo para explicar y calcular la nota vigesimal (0 a 20)
/// según el algoritmo formativo dinámico oficial de AulaActiva UNSAAC.
class CalculadoraVigesimalDialog extends StatefulWidget {
  final int puntosIniciales;
  final int puntosMaximosIniciales;

  const CalculadoraVigesimalDialog({
    super.key,
    this.puntosIniciales = 4,
    this.puntosMaximosIniciales = 8,
  });

  @override
  State<CalculadoraVigesimalDialog> createState() =>
      _CalculadoraVigesimalDialogState();
}

class _CalculadoraVigesimalDialogState
    extends State<CalculadoraVigesimalDialog> {
  late double _misPuntos;
  late double _puntosMaximos;

  @override
  void initState() {
    super.initState();
    _misPuntos = widget.puntosIniciales.toDouble().clamp(0.0, 30.0);
    _puntosMaximos =
        widget.puntosMaximosIniciales.toDouble().clamp(1.0, 30.0);
    if (_misPuntos > _puntosMaximos) {
      _puntosMaximos = _misPuntos;
    }
  }

  double get _notaCalculada {
    if (_puntosMaximos <= 0) return 0.0;
    final nota = (_misPuntos / _puntosMaximos) * 20.0;
    return double.parse(nota.toStringAsFixed(1));
  }

  bool get _estaAprobado => _notaCalculada >= 10.5;

  String get _categoriaDesempeno {
    if (_notaCalculada >= 18.0) return 'Sobresaliente (Excelente dominio)';
    if (_notaCalculada >= 14.0) return 'Notable (Participación activa)';
    if (_notaCalculada >= 10.5) return 'Aprobado (Cumple estándar mínimo)';
    if (_notaCalculada > 0.0) return 'En Proceso (Requiere mayor interacción)';
    return 'Sin participaciones registradas';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 420 ? 390.0 : screenWidth * 0.92;

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
                  // ─── Cabecera Institucional con Escudo UNSAAC ──────────────
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UNSAAC · AULAACTIVA',
                                style: TextStyle(
                                  color: AppColors.doradoClaro,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                'Cálculo de Nota Vigesimal',
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

                  // ─── Contenido y Simulador ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tarjeta de la Fórmula Oficial
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                AppColors.doradoUnsaac.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  AppColors.doradoUnsaac.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'FÓRMULA FORMATIVA VIGESIMAL (0 a 20):',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.granateOscuro,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.blanco,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borde),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Nota = ( Mis Puntos / Puntos Máximos ) × 20.0',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.azulPizarra,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Resultado Grande Dinámico
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: _estaAprobado
                                ? AppColors.verdeExito.withValues(alpha: 0.1)
                                : AppColors.naranjaAlerta.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _estaAprobado
                                  ? AppColors.verdeExito
                                  : AppColors.naranjaAlerta,
                              width: 1.6,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'NOTA VIGESIMAL CALCULADA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textoSecundario,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _notaCalculada.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: _estaAprobado
                                      ? AppColors.granateUnsaac
                                      : AppColors.naranjaAlerta,
                                ),
                              ),
                              Text(
                                _categoriaDesempeno,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _estaAprobado
                                      ? AppColors.verdeExito
                                      : AppColors.naranjaAlerta,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Slider 1: Mis Puntos
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Mis Puntos en Sesión:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.azulPizarra,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.granateUnsaac
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_misPuntos.round()} pts',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.granateUnsaac,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _misPuntos,
                          min: 0,
                          max: _puntosMaximos < 1 ? 1 : _puntosMaximos,
                          divisions:
                              _puntosMaximos.round() > 0 ? _puntosMaximos.round() : 1,
                          activeColor: AppColors.granateUnsaac,
                          inactiveColor: AppColors.borde,
                          onChanged: (val) {
                            setState(() => _misPuntos = val);
                          },
                        ),

                        // Slider 2: Puntos del 1er Lugar (Máximo de la clase)
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Puntaje Máximo en Clase:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.azulPizarra,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.doradoUnsaac
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_puntosMaximos.round()} pts',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.granateOscuro,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _puntosMaximos,
                          min: 1,
                          max: 30,
                          divisions: 29,
                          activeColor: AppColors.doradoUnsaac,
                          inactiveColor: AppColors.borde,
                          onChanged: (val) {
                            setState(() {
                              _puntosMaximos = val;
                              if (_misPuntos > _puntosMaximos) {
                                _misPuntos = _puntosMaximos;
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // Botón de Entendido
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.granateUnsaac,
                              foregroundColor: AppColors.blanco,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendido',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
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
