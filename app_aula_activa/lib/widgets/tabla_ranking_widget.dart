import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../models/estudiante_ranking.dart';

class TablaRankingWidget extends StatelessWidget {
  final List<EstudianteRanking> ranking;
  final bool esSesionDelDia;
  final bool esModoDocente;
  final Function(EstudianteRanking)? onPuntuarRapido;
  final Function(EstudianteRanking)? onSeleccionar;

  const TablaRankingWidget({
    super.key,
    required this.ranking,
    required this.esSesionDelDia,
    this.esModoDocente = false,
    this.onPuntuarRapido,
    this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline_rounded,
                  size: 48, color: AppColors.textoSecundario),
              const SizedBox(height: 12),
              Text(
                'No hay estudiantes registrados aún.',
                style: AppStyles.cuerpoSecundario,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: ranking.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8.0),
      itemBuilder: (context, index) {
        final item = ranking[index];
        final puntos =
            esSesionDelDia ? item.puntosSesion : item.puntosTotales;
        final nota =
            esSesionDelDia ? item.notaSesion : item.notaTotal;
        final esTop = item.posicion <= 3;

        return InkWell(
          onTap: () => onSeleccionar?.call(item),
          borderRadius: BorderRadius.circular(AppStyles.radioBorde),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: AppColors.blanco,
              borderRadius: BorderRadius.circular(AppStyles.radioBorde),
              border: Border.all(
                color: esTop
                    ? AppColors.doradoUnsaac.withValues(alpha: 0.5)
                    : AppColors.borde,
                width: esTop ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Posición e insignia de Número de Orden
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: esTop
                        ? AppColors.doradoUnsaac.withValues(alpha: 0.15)
                        : AppColors.fondo,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: esTop
                          ? AppColors.doradoUnsaac
                          : AppColors.borde,
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${item.estudiante.numeroOrden}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: esTop
                          ? AppColors.granateUnsaac
                          : AppColors.azulPizarra,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Datos del Estudiante
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.estudiante.nombreCompleto,
                        style: AppStyles.cuerpo.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Row(
                        children: [
                          Text(
                            'Cód: ${item.estudiante.codigoUnsaac}',
                            style: AppStyles.cuerpoSecundario.copyWith(fontSize: 11),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.fondo,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              '$puntos pts',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.azulAcento,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Nota Vigesimal (0 a 20)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nota.toStringAsFixed(1),
                      style: AppStyles.notaVigesimal.copyWith(
                        fontSize: 17,
                        color: nota >= 14.0
                            ? AppColors.granateUnsaac
                            : AppColors.naranjaAlerta,
                      ),
                    ),
                    Text(
                      'Escala 0-20',
                      style: AppStyles.cuerpoSecundario.copyWith(fontSize: 10),
                    ),
                  ],
                ),

                // Botón de Puntaje Rápido (+1) si es modo docente
                if (esModoDocente) ...[
                  const SizedBox(width: 8.0),
                  IconButton(
                    onPressed: () => onPuntuarRapido?.call(item),
                    icon: const Icon(Icons.add_circle_rounded),
                    color: AppColors.granateUnsaac,
                    iconSize: 28,
                    tooltip: 'Sumar +1 punto',
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
