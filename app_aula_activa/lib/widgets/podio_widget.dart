import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../models/estudiante_ranking.dart';

class PodioWidget extends StatelessWidget {
  final List<EstudianteRanking> ranking;
  final bool esSesionDelDia;

  const PodioWidget({
    super.key,
    required this.ranking,
    required this.esSesionDelDia,
  });

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) return const SizedBox.shrink();

    final primero = ranking.isNotEmpty ? ranking[0] : null;
    final segundo = ranking.length > 1 ? ranking[1] : null;
    final tercero = ranking.length > 2 ? ranking[2] : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: AppStyles.decoracionTarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.doradoUnsaac,
                size: 22,
              ),
              const SizedBox(width: 8.0),
              Text(
                esSesionDelDia ? 'Podio de la Sesión' : 'Cuadro de Honor Semestral',
                style: AppStyles.subtitulo,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 2° Lugar
              if (segundo != null)
                _construirColumnaPodio(
                  rankingItem: segundo,
                  colorMedalla: AppColors.plataPodio,
                  alturaBloque: 80,
                  lugar: 2,
                )
              else
                const SizedBox(width: 80),

              // 1° Lugar
              if (primero != null)
                _construirColumnaPodio(
                  rankingItem: primero,
                  colorMedalla: AppColors.oroPodio,
                  alturaBloque: 110,
                  lugar: 1,
                  esPrimero: true,
                )
              else
                const SizedBox(width: 80),

              // 3° Lugar
              if (tercero != null)
                _construirColumnaPodio(
                  rankingItem: tercero,
                  colorMedalla: AppColors.broncePodio,
                  alturaBloque: 65,
                  lugar: 3,
                )
              else
                const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirColumnaPodio({
    required EstudianteRanking rankingItem,
    required Color colorMedalla,
    required double alturaBloque,
    required int lugar,
    bool esPrimero = false,
  }) {
    final puntos =
        esSesionDelDia ? rankingItem.puntosSesion : rankingItem.puntosTotales;
    final nota =
        esSesionDelDia ? rankingItem.notaSesion : rankingItem.notaTotal;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Medalla con Número de Orden
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: colorMedalla.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: colorMedalla, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.military_tech_rounded,
                  color: colorMedalla,
                  size: esPrimero ? 18 : 16,
                ),
                Text(
                  'N° ${rankingItem.estudiante.numeroOrden}',
                  style: AppStyles.cuerpoSecundario.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.azulPizarra,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6.0),
          // Nombre del Alumno
          Text(
            rankingItem.estudiante.nombres.split(' ').first,
            style: AppStyles.cuerpo.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2.0),
          // Nota calculada (Vigesimal 0-20)
          Text(
            '${nota.toStringAsFixed(1)} pts',
            style: AppStyles.cuerpoSecundario.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.granateUnsaac,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6.0),
          // Bloque del Podio
          Container(
            height: alturaBloque,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: esPrimero
                    ? [AppColors.doradoUnsaac, AppColors.doradoClaro]
                    : [AppColors.borde, AppColors.fondo],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              border: Border.all(
                color: esPrimero ? AppColors.doradoUnsaac : AppColors.borde,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$lugar°',
                  style: TextStyle(
                    fontSize: esPrimero ? 22 : 18,
                    fontWeight: FontWeight.w900,
                    color: esPrimero ? AppColors.blanco : AppColors.azulPizarra,
                  ),
                ),
                Text(
                  '$puntos int.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: esPrimero
                        ? AppColors.blanco.withValues(alpha: 0.9)
                        : AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
