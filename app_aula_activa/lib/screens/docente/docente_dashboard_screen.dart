import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/excel_export_service.dart';
import '../../models/estudiante_ranking.dart';
import '../../repositories/aula_repository.dart';
import '../../widgets/cabecera_institucional_widget.dart';
import '../../widgets/calculadora_vigesimal_dialog.dart';
import '../../widgets/modo_rapido_matriz_widget.dart';
import '../../widgets/podio_widget.dart';
import '../../widgets/tabla_ranking_widget.dart';
import 'asignacion_multiple_dialog.dart';
import 'asignar_puntos_dialog.dart';
import 'qr_aula_dialog.dart';

class DocenteDashboardScreen extends StatefulWidget {
  const DocenteDashboardScreen({super.key});

  @override
  State<DocenteDashboardScreen> createState() => _DocenteDashboardScreenState();
}

class _DocenteDashboardScreenState extends State<DocenteDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _exportando = false;
  bool _modoMatrizRapida = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportarExcel(bool esSesionDelDia) async {
    setState(() => _exportando = true);
    try {
      final repo = AulaRepository.instance;
      final ranking = esSesionDelDia
          ? repo.obtenerRankingSesion()
          : repo.obtenerRankingAcumulado();

      await ExcelExportService.exportarRankingExcel(
        curso: repo.cursoActual,
        sesion: repo.sesionActual,
        ranking: ranking,
        esSesionDelDia: esSesionDelDia,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Planilla Excel generada y lista para compartir.'),
            backgroundColor: AppColors.verdeExito,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: AppColors.naranjaAlerta,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = AulaRepository.instance;
    final curso = repo.cursoActual;
    final sesion = repo.sesionActual;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Column(
        children: [
          // Cabecera Institucional con botón de QR y Excel
          CabeceraInstitucionalWidget(
            titulo: '${curso.codigo} — ${curso.nombre}',
            subtitulo: '${sesion.fecha} · ${sesion.tema}',
            accion: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón QR de Ingreso al Aula
                IconButton(
                  tooltip: 'Código QR del Aula',
                  icon: const Icon(Icons.qr_code_2_rounded,
                      color: AppColors.doradoClaro, size: 24),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const QrAulaDialog(),
                    );
                  },
                ),
                // Botón Calculadora Vigesimal (0 a 20)
                IconButton(
                  tooltip: 'Cálculo de Notas (0-20)',
                  icon: const Icon(Icons.calculate_rounded,
                      color: AppColors.doradoClaro, size: 22),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CalculadoraVigesimalDialog(),
                    );
                  },
                ),
                // Botón Exportar a Excel con distintivo verde de marca
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF107C41),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: IconButton(
                    tooltip: 'Exportar a Excel (.xlsx)',
                    visualDensity: VisualDensity.compact,
                    icon: _exportando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.blanco),
                          )
                        : const Icon(Icons.table_view_rounded,
                            color: AppColors.blanco, size: 20),
                    onPressed: _exportando
                        ? null
                        : () => _exportarExcel(_tabController.index == 0),
                  ),
                ),
              ],
            ),
          ),

          // Pestañas (Sesión de Hoy / Semestre)
          Container(
            color: AppColors.blanco,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.granateUnsaac,
                  unselectedLabelColor: AppColors.textoSecundario,
                  indicatorColor: AppColors.granateUnsaac,
                  indicatorWeight: 3.0,
                  tabs: const [
                    Tab(text: 'Sesión de Hoy'),
                    Tab(text: 'Semestre'),
                  ],
                ),
                // Barra de alternancia de vista: Lista Detallada vs Modo Rápido (Números)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tune_rounded,
                              size: 16, color: AppColors.textoSecundario),
                          const SizedBox(width: 6),
                          Text(
                            'Vista:',
                            style: AppStyles.cuerpoSecundario.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Lista',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700)),
                            icon: Icon(Icons.format_list_bulleted_rounded,
                                size: 15),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Rápido (#)',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700)),
                            icon: Icon(Icons.flash_on_rounded, size: 15),
                          ),
                        ],
                        selected: {_modoMatrizRapida},
                        onSelectionChanged: (val) {
                          setState(() => _modoMatrizRapida = val.first);
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.granateUnsaac
                                  .withValues(alpha: 0.15);
                            }
                            return Colors.transparent;
                          }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.granateUnsaac;
                            }
                            return AppColors.textoSecundario;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _construirVistaRanking(
                  stream: repo.rankingSesionStream,
                  datosIniciales: repo.obtenerRankingSesion(),
                  esSesionDelDia: true,
                ),
                _construirVistaRanking(
                  stream: repo.rankingAcumuladoStream,
                  datosIniciales: repo.obtenerRankingAcumulado(),
                  esSesionDelDia: false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.granateUnsaac,
        foregroundColor: AppColors.blanco,
        icon: const Icon(Icons.groups_rounded),
        label: const Text('Puntaje Grupal'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
                AsignacionMultipleDialog(estudiantes: repo.estudiantes),
          );
        },
      ),
    );
  }

  Widget _construirVistaRanking({
    required Stream<List<EstudianteRanking>> stream,
    required List<EstudianteRanking> datosIniciales,
    required bool esSesionDelDia,
  }) {
    return StreamBuilder<List<EstudianteRanking>>(
      stream: stream,
      initialData: datosIniciales,
      builder: (context, snapshot) {
        final ranking = snapshot.data ?? [];

        if (ranking.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline_rounded,
                      size: 56, color: AppColors.borde),
                  const SizedBox(height: 12),
                  Text(
                    'Sin alumnos en este curso',
                    style: AppStyles.subtitulo
                        .copyWith(color: AppColors.textoSecundario),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ve a "Mis Cursos" → Gestionar alumnos para agregar estudiantes.',
                    style: AppStyles.cuerpoSecundario,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (_modoMatrizRapida) {
          return SingleChildScrollView(
            child: ModoRapidoMatrizWidget(
              ranking: ranking,
              esSesionDelDia: esSesionDelDia,
              onExportarExcel: () => _exportarExcel(esSesionDelDia),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PodioWidget(ranking: ranking, esSesionDelDia: esSesionDelDia),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 6.0),
                child: Row(
                  children: [
                    Text(
                      '${ranking.length} estudiantes',
                      style: AppStyles.subtitulo.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    // Botón visual y explícito de exportar a Excel
                    ElevatedButton.icon(
                      icon: _exportando
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.table_view_rounded,
                              size: 16, color: Colors.white),
                      label: Text(
                        esSesionDelDia ? 'Exportar Excel' : 'Excel Semestre',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF107C41),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _exportando
                          ? null
                          : () => _exportarExcel(esSesionDelDia),
                    ),
                  ],
                ),
              ),
              TablaRankingWidget(
                ranking: ranking,
                esSesionDelDia: esSesionDelDia,
                esModoDocente: true,
                onPuntuarRapido: (item) async {
                  await AulaRepository.instance.asignarPuntos(
                    estudianteId: item.estudiante.id,
                    puntos: 1,
                    motivo: 'Respuesta oral directa',
                  );
                },
                onSeleccionar: (item) {
                  showDialog(
                    context: context,
                    builder: (_) => AsignarPuntosDialog(rankingItem: item),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
