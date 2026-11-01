import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../models/estudiante_ranking.dart';
import '../repositories/aula_repository.dart';
import '../screens/docente/asignar_puntos_dialog.dart';

/// Modo Rápido (Matriz de Números de Orden):
/// Permite al docente visualizar a todos los estudiantes mediante sus números de orden
/// en una cuadrícula compacta, táctil y de alta velocidad para calificar con un solo toque.
class ModoRapidoMatrizWidget extends StatefulWidget {
  final List<EstudianteRanking> ranking;
  final bool esSesionDelDia;
  final VoidCallback? onExportarExcel;

  const ModoRapidoMatrizWidget({
    super.key,
    required this.ranking,
    required this.esSesionDelDia,
    this.onExportarExcel,
  });

  @override
  State<ModoRapidoMatrizWidget> createState() => _ModoRapidoMatrizWidgetState();
}

class _ModoRapidoMatrizWidgetState extends State<ModoRapidoMatrizWidget> {
  int _puntosSeleccionados = 1;
  String _filtroTexto = '';
  String? _ultimoAsignadoTexto;

  @override
  Widget build(BuildContext context) {
    final repo = AulaRepository.instance;
    final estudiantesOrdenados = List<EstudianteRanking>.from(widget.ranking)
      ..sort((a, b) => a.estudiante.numeroOrden.compareTo(b.estudiante.numeroOrden));

    final filtrados = _filtroTexto.trim().isEmpty
        ? estudiantesOrdenados
        : estudiantesOrdenados.where((item) {
            final q = _filtroTexto.toLowerCase().trim();
            final ordenStr = item.estudiante.numeroOrden.toString();
            final nombreCompleto = item.estudiante.nombreCompleto.toLowerCase();
            return ordenStr.contains(q) || nombreCompleto.contains(q);
          }).toList();

    final conPuntosHoy = widget.ranking.where((r) => r.puntosSesion > 0).length;
    final total = widget.ranking.length;
    final porcentaje = total > 0 ? (conPuntosHoy / total) : 0.0;

    return Column(
      children: [
        // ─── Tarjeta Principal de Configuración de Puntuación Rápida ─────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.doradoUnsaac.withValues(alpha: 0.4), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila de encabezado: título + porcentaje de participación
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.granateUnsaac.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flash_on_rounded,
                        color: AppColors.granateUnsaac, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Puntos Rápidos a Asignar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.azulPizarra,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: conPuntosHoy > 0
                          ? AppColors.verdeExito.withValues(alpha: 0.12)
                          : AppColors.fondo,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: conPuntosHoy > 0
                            ? AppColors.verdeExito.withValues(alpha: 0.4)
                            : AppColors.borde,
                      ),
                    ),
                    child: Text(
                      'Participaron: $conPuntosHoy/$total (${(porcentaje * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: conPuntosHoy > 0
                            ? AppColors.verdeExito
                            : AppColors.textoSecundario,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Barra de progreso de participación de la clase
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: porcentaje,
                  minHeight: 5,
                  backgroundColor: AppColors.fondo,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.verdeExito),
                ),
              ),

              const SizedBox(height: 12),

              // Botones de puntos (+1, +2, +3, +5)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [1, 2, 3, 5].map((pts) {
                    final seleccionado = _puntosSeleccionados == pts;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _puntosSeleccionados = pts),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: seleccionado
                                ? const LinearGradient(
                                    colors: [AppColors.granateUnsaac, AppColors.granateOscuro],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: seleccionado ? null : AppColors.fondo,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: seleccionado
                                  ? AppColors.doradoUnsaac
                                  : AppColors.borde,
                              width: seleccionado ? 1.8 : 1.0,
                            ),
                            boxShadow: seleccionado
                                ? [
                                    BoxShadow(
                                      color: AppColors.granateUnsaac.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                pts == 1
                                    ? Icons.add_circle_outline_rounded
                                    : pts == 2
                                        ? Icons.bolt_rounded
                                        : pts == 3
                                            ? Icons.stars_rounded
                                            : Icons.workspace_premium_rounded,
                                size: 16,
                                color: seleccionado ? AppColors.doradoClaro : AppColors.azulPizarra,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+$pts ${pts == 1 ? 'punto' : 'puntos'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: seleccionado ? AppColors.blanco : AppColors.azulPizarra,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // ─── Banner de Última Acción / Puntuación Reciente (Si existe) ────────
        if (_ultimoAsignadoTexto != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.verdeExito.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.verdeExito.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.verdeExito, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _ultimoAsignadoTexto!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.verdeExito,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _ultimoAsignadoTexto = null),
                  child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textoSecundario),
                ),
              ],
            ),
          ),

        // ─── Buscador + Botón Exportar a Excel en Modo Rápido ───────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Filtrar por número (#) o apellido...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: _filtroTexto.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () => setState(() => _filtroTexto = ''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.borde),
                    ),
                    filled: true,
                    fillColor: AppColors.blanco,
                  ),
                  onChanged: (val) => setState(() => _filtroTexto = val),
                ),
              ),
              if (widget.onExportarExcel != null) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: widget.onExportarExcel,
                  icon: const Icon(Icons.table_view_rounded, size: 16, color: Colors.white),
                  label: const Text('Excel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF107C41),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ─── Indicador explicativo ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.textoSecundario),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Toca un estudiante para sumar +$_puntosSeleccionados pts instantáneamente · Mantén presionado para más opciones',
                  style: AppStyles.cuerpoSecundario.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        // ─── Matriz de Números de Orden ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtrados.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final item = filtrados[index];
              final tienePuntos = item.puntosSesion > 0;
              final apellidoCorto = item.estudiante.apellidos.split(' ').first;
              final enAula = repo.isNumeroOrdenOcupado(item.estudiante.numeroOrden);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    // Asignación instantánea con 1 toque
                    await repo.asignarPuntos(
                      estudianteId: item.estudiante.id,
                      puntos: _puntosSeleccionados,
                      motivo: 'Respuesta rápida en aula (+$_puntosSeleccionados)',
                    );

                    final nuevoTotal = item.puntosSesion + _puntosSeleccionados;
                    setState(() {
                      _ultimoAsignadoTexto =
                          '⚡ #0${item.estudiante.numeroOrden} $apellidoCorto recibió +$_puntosSeleccionados pts (Total hoy: $nuevoTotal pts)';
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 1000),
                          backgroundColor: AppColors.granateUnsaac,
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.doradoClaro, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '#${item.estudiante.numeroOrden} $apellidoCorto: ',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              Text('+$_puntosSeleccionados pts asignados'),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    // Diálogo detallado con long-press
                    showDialog(
                      context: context,
                      builder: (_) => AsignarPuntosDialog(rankingItem: item),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: tienePuntos
                          ? LinearGradient(
                              colors: [
                                AppColors.doradoUnsaac.withValues(alpha: 0.12),
                                AppColors.blanco,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: tienePuntos ? null : AppColors.blanco,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tienePuntos
                            ? AppColors.doradoUnsaac
                            : AppColors.borde,
                        width: tienePuntos ? 1.8 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tienePuntos
                              ? AppColors.doradoUnsaac.withValues(alpha: 0.15)
                              : const Color(0x08000000),
                          blurRadius: tienePuntos ? 6 : 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Fila superior: Indicador de conectado y botón '+'
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Indicador de celular conectado en aula
                            if (enAula)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.verdeExito,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(width: 8),
                            // Indicador visual de adición rápida
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: tienePuntos
                                    ? AppColors.granateUnsaac.withValues(alpha: 0.1)
                                    : AppColors.fondo,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 12,
                                color: tienePuntos
                                    ? AppColors.granateUnsaac
                                    : AppColors.textoSecundario,
                              ),
                            ),
                          ],
                        ),

                        // Número de orden grande institucional
                        Text(
                          item.estudiante.numeroOrden.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: tienePuntos
                                ? AppColors.granateUnsaac
                                : AppColors.azulPizarra,
                          ),
                        ),

                        // Apellido del estudiante
                        Text(
                          apellidoCorto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tienePuntos
                                ? AppColors.azulPizarra
                                : AppColors.textoSecundario,
                          ),
                        ),

                        // Pastilla de puntos acumulados
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tienePuntos
                                ? AppColors.granateUnsaac
                                : AppColors.fondo,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: tienePuntos
                                  ? AppColors.doradoUnsaac
                                  : AppColors.borde,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '${item.puntosSesion} pts',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: tienePuntos
                                  ? AppColors.doradoClaro
                                  : AppColors.textoSecundario,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
