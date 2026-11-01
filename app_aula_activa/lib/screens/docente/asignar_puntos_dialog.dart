import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../models/estudiante_ranking.dart';
import '../../repositories/aula_repository.dart';

class AsignarPuntosDialog extends StatefulWidget {
  final EstudianteRanking rankingItem;

  const AsignarPuntosDialog({super.key, required this.rankingItem});

  @override
  State<AsignarPuntosDialog> createState() => _AsignarPuntosDialogState();
}

class _AsignarPuntosDialogState extends State<AsignarPuntosDialog> {
  int _puntosSeleccionados = 1;
  String _motivoSeleccionado = 'Respuesta a pregunta en clase';

  final List<String> _motivosPredefinidos = [
    'Respuesta a pregunta en clase',
    'Aporte y debate conceptual',
    'Resolución de ejercicio en pizarra',
    'Intervención en dinámica grupal',
    'Aclaración o duda relevante',
  ];

  @override
  Widget build(BuildContext context) {
    final est = widget.rankingItem.estudiante;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radioTarjeta),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del Estudiante
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.granateUnsaac,
                    radius: 22,
                    child: Text(
                      '#${est.numeroOrden}',
                      style: const TextStyle(
                        color: AppColors.blanco,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          est.nombreCompleto,
                          style: AppStyles.subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Cód: ${est.codigoUnsaac}',
                          style: AppStyles.cuerpoSecundario,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Selector de Puntos
              Text('Puntaje a otorgar:', style: AppStyles.subtitulo),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [1, 2, 3, 5].map((pts) {
                  final seleccionado = _puntosSeleccionados == pts;
                  return InkWell(
                    onTap: () => setState(() => _puntosSeleccionados = pts),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 54,
                      height: 48,
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? AppColors.granateUnsaac
                            : AppColors.fondo,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: seleccionado
                              ? AppColors.granateUnsaac
                              : AppColors.borde,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+$pts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: seleccionado
                              ? AppColors.blanco
                              : AppColors.azulPizarra,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Selector de Motivo
              Text('Motivo de la intervención:', style: AppStyles.subtitulo),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: AppColors.fondo,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borde),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _motivoSeleccionado,
                    items: _motivosPredefinidos.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m, style: AppStyles.cuerpo),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _motivoSeleccionado = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar',
                          style: TextStyle(color: AppColors.textoSecundario)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        await AulaRepository.instance.asignarPuntos(
                          estudianteId: est.id,
                          puntos: _puntosSeleccionados,
                          motivo: _motivoSeleccionado,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.granateUnsaac,
                        foregroundColor: AppColors.blanco,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Asignar +$_puntosSeleccionados',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
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
