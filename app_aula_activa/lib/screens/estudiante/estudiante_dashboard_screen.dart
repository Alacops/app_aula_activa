import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../models/estudiante.dart';
import '../../models/estudiante_ranking.dart';
import '../../repositories/aula_repository.dart';
import '../../widgets/cabecera_institucional_widget.dart';
import '../../widgets/podio_widget.dart';
import '../../widgets/tabla_ranking_widget.dart';

import 'carnet_estudiante_qr_dialog.dart';
import '../../widgets/calculadora_vigesimal_dialog.dart';

class EstudianteDashboardScreen extends StatefulWidget {
  final Estudiante estudiante;

  const EstudianteDashboardScreen({super.key, required this.estudiante});

  @override
  State<EstudianteDashboardScreen> createState() =>
      _EstudianteDashboardScreenState();
}

class _EstudianteDashboardScreenState extends State<EstudianteDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    AulaRepository.instance.liberarNumeroOrden(widget.estudiante.numeroOrden);
    super.dispose();
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
          // Cabecera Institucional con botón de QR Personal
          CabeceraInstitucionalWidget(
            titulo: '${curso.nombre} (${curso.codigo})',
            subtitulo: 'Sesión: ${sesion.fecha} | ${curso.semestre}',
            accion: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_rounded,
                      color: AppColors.doradoClaro),
                  tooltip: 'Mi Carnet QR',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          CarnetEstudianteQrDialog(estudiante: widget.estudiante),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calculate_rounded,
                      color: AppColors.doradoClaro),
                  tooltip: 'Cálculo de Nota (0-20)',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CalculadoraVigesimalDialog(),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.blanco),
                  tooltip: 'Salir',
                  onPressed: () {
                    AulaRepository.instance.liberarNumeroOrden(widget.estudiante.numeroOrden);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Stream para obtener datos en vivo de este estudiante
          StreamBuilder<List<EstudianteRanking>>(
            stream: repo.rankingSesionStream,
            initialData: repo.obtenerRankingSesion(),
            builder: (context, snapshot) {
              final rankingSesion = snapshot.data ?? [];
              final miRankingSesion = rankingSesion.firstWhere(
                (r) => r.estudiante.id == widget.estudiante.id,
                orElse: () => EstudianteRanking(
                  estudiante: widget.estudiante,
                  puntosSesion: 0,
                  puntosTotales: 0,
                  notaSesion: 0.0,
                  notaTotal: 0.0,
                  posicion: rankingSesion.length + 1,
                ),
              );

              return _construirTarjetaPersonal(miRankingSesion);
            },
          ),

          // Pestañas de Rankings
          TabBar(
            controller: _tabController,
            labelColor: AppColors.granateUnsaac,
            unselectedLabelColor: AppColors.textoSecundario,
            indicatorColor: AppColors.granateUnsaac,
            indicatorWeight: 3.0,
            tabs: const [
              Tab(text: 'Ranking de Hoy (Sesión)'),
              Tab(text: 'Ranking Acumulado'),
            ],
          ),

          // Lista de Rankings en Vivo
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
    );
  }

  Widget _construirTarjetaPersonal(EstudianteRanking miRanking) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: AppStyles.decoracionTarjetaGranate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.doradoUnsaac,
                radius: 20,
                child: Text(
                  '#${widget.estudiante.numeroOrden}',
                  style: const TextStyle(
                    color: AppColors.azulPizarra,
                    fontWeight: FontWeight.w900,
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
                      widget.estudiante.nombreCompleto,
                      style: AppStyles.tituloBlanco.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Código: ${widget.estudiante.codigoUnsaac}',
                      style: TextStyle(
                        color: AppColors.blanco.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blanco.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.military_tech_rounded,
                        color: AppColors.doradoClaro, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Puesto #${miRanking.posicion}',
                      style: const TextStyle(
                        color: AppColors.blanco,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0x33FFFFFF)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _construirMetrica(
                  titulo: 'Puntos Hoy',
                  valor: '${miRanking.puntosSesion}',
                  icono: Icons.star_rounded,
                ),
              ),
              Expanded(
                child: _construirMetrica(
                  titulo: 'Vigesimal',
                  valor: '${miRanking.notaSesion.toStringAsFixed(1)} / 20',
                  icono: Icons.grade_rounded,
                  colorValor: AppColors.doradoClaro,
                ),
              ),
              Expanded(
                child: _construirMetrica(
                  titulo: 'Puntos Total',
                  valor: '${miRanking.puntosTotales}',
                  icono: Icons.insights_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirMetrica({
    required String titulo,
    required String valor,
    required IconData icono,
    Color colorValor = AppColors.blanco,
  }) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 14, color: AppColors.doradoClaro),
              const SizedBox(width: 4),
              Text(
                titulo,
                style: TextStyle(
                  color: AppColors.blanco.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            valor,
            style: TextStyle(
              color: colorValor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PodioWidget(
                ranking: ranking,
                esSesionDelDia: esSesionDelDia,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Text(
                  'Posiciones en Vivo de la Clase',
                  style: AppStyles.subtitulo,
                ),
              ),
              TablaRankingWidget(
                ranking: ranking,
                esSesionDelDia: esSesionDelDia,
                esModoDocente: false,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
