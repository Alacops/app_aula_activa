import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../models/estudiante.dart';
import '../../repositories/aula_repository.dart';

class AsignacionMultipleDialog extends StatefulWidget {
  final List<Estudiante> estudiantes;

  const AsignacionMultipleDialog({super.key, required this.estudiantes});

  @override
  State<AsignacionMultipleDialog> createState() => _AsignacionMultipleDialogState();
}

class _AsignacionMultipleDialogState extends State<AsignacionMultipleDialog> {
  final Set<String> _seleccionados = {};
  int _puntosAOtorgar = 1;
  final String _motivo = 'Dinámica grupal / Trabajo en equipo';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radioTarjeta),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                const Icon(
                  Icons.groups_rounded,
                  color: AppColors.granateUnsaac,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Puntaje Simultáneo / Grupal',
                    style: AppStyles.tituloPrincipal.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona los estudiantes que participaron en la dinámica:',
              style: AppStyles.cuerpoSecundario,
            ),
            const SizedBox(height: 12),
            // Controles de Selección Rápida
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _seleccionados.addAll(widget.estudiantes.map((e) => e.id));
                        });
                      },
                      icon: const Icon(Icons.select_all_rounded, size: 16),
                      label: const Text('Todos', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _seleccionados.clear();
                        });
                      },
                      icon: const Icon(Icons.deselect_rounded, size: 16),
                      label: const Text('Ninguno', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.granateUnsaac.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_seleccionados.length} elegidos',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.granateUnsaac,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Lista con Checkboxes
            Expanded(
              child: ListView.separated(
                itemCount: widget.estudiantes.length,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final est = widget.estudiantes[index];
                  final estaMarcado = _seleccionados.contains(est.id);

                  return CheckboxListTile(
                    value: estaMarcado,
                    activeColor: AppColors.granateUnsaac,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    secondary: CircleAvatar(
                      backgroundColor: estaMarcado
                          ? AppColors.granateUnsaac
                          : AppColors.fondo,
                      radius: 18,
                      child: Text(
                        '#${est.numeroOrden}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: estaMarcado
                              ? AppColors.blanco
                              : AppColors.azulPizarra,
                        ),
                      ),
                    ),
                    title: Text(
                      est.nombreCompleto,
                      style: AppStyles.cuerpo.copyWith(
                        fontWeight:
                            estaMarcado ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text('Cód: ${est.codigoUnsaac}',
                        style: AppStyles.cuerpoSecundario),
                    onChanged: (bool? val) {
                      setState(() {
                        if (val == true) {
                          _seleccionados.add(est.id);
                        } else {
                          _seleccionados.remove(est.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(),

            // Puntos a Otorgar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Puntos:', style: AppStyles.subtitulo),
                  const SizedBox(width: 8),
                  ...[1, 2, 3, 5].map((pts) {
                    final sel = _puntosAOtorgar == pts;
                    return InkWell(
                      onTap: () => setState(() => _puntosAOtorgar = pts),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.granateUnsaac : AppColors.fondo,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: sel
                                ? AppColors.granateUnsaac
                                : AppColors.borde,
                          ),
                        ),
                        child: Text(
                          '+$pts',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: sel ? AppColors.blanco : AppColors.azulPizarra,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botones Finales
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
                    onPressed: _seleccionados.isEmpty
                        ? null
                        : () async {
                            await AulaRepository.instance.asignarPuntosMultiples(
                              estudianteIds: _seleccionados.toList(),
                              puntos: _puntosAOtorgar,
                              motivo: _motivo,
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.granateUnsaac,
                      foregroundColor: AppColors.blanco,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _seleccionados.isEmpty
                            ? 'Otorgar puntos'
                            : 'Otorgar +$_puntosAOtorgar pts (${_seleccionados.length})',
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
    );
  }
}
