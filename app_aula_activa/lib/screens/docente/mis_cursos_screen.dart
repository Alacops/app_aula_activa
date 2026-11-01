import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/curso_service.dart';
import '../../core/services/docente_service.dart';
import '../../core/services/supabase_service.dart';
import '../../models/curso.dart';
import '../../repositories/aula_repository.dart';
import '../../widgets/cabecera_institucional_widget.dart';
import 'configuracion_supabase_dialog.dart';
import 'docente_dashboard_screen.dart';
import 'gestion_alumnos_screen.dart';

/// Pantalla principal del docente: lista sus cursos y puede crear nuevos.
class MisCursosScreen extends StatefulWidget {
  final Docente docente;

  const MisCursosScreen({super.key, required this.docente});

  @override
  State<MisCursosScreen> createState() => _MisCursosScreenState();
}

class _MisCursosScreenState extends State<MisCursosScreen> {
  List<Curso> _cursos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    setState(() => _cargando = true);
    final lista = await CursoService.instance
        .listarCursosPorDocente(widget.docente.id);
    if (mounted) setState(() {
      _cursos = lista;
      _cargando = false;
    });
  }

  Future<void> _crearCurso() async {
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _CrearCursoDialog(docenteNombre: widget.docente.nombreCompleto),
    );
    if (resultado == null) return;

    await CursoService.instance.crearCurso(
      docenteId: widget.docente.id,
      docenteNombre: widget.docente.nombreCompleto,
      codigo: resultado['codigo']!,
      nombre: resultado['nombre']!,
      semestre: resultado['semestre']!,
    );
    await _cargarCursos();
  }

  Future<void> _abrirSesion(Curso curso) async {
    final tema = await showDialog<String>(
      context: context,
      builder: (_) => _AbrirSesionDialog(curso: curso),
    );
    if (tema == null || !mounted) return;

    // Inicializar el repositorio de sesión
    await AulaRepository.inicializar(
      curso: curso,
      temaSesion: tema,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DocenteDashboardScreen(),
      ),
    );
  }

  Future<void> _eliminarCurso(Curso curso) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar curso'),
        content: Text(
            '¿Eliminar "${curso.nombre}"? Esto también borrará la lista de alumnos asociada.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranjaAlerta,
                foregroundColor: AppColors.blanco),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    await CursoService.instance.eliminarCurso(curso.id);
    await _cargarCursos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Column(
        children: [
          CabeceraInstitucionalWidget(
            titulo: widget.docente.nombreCompleto,
            subtitulo: widget.docente.correo,
            accion: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Config Supabase (oculto dentro del menú)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.blanco),
                  onSelected: (val) async {
                    if (val == 'supabase') {
                      showDialog(
                        context: context,
                        builder: (_) => const ConfiguracionSupabaseDialog(),
                      );
                    } else if (val == 'salir') {
                      await DocenteService.instance.cerrarSesion();
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'supabase',
                      child: Row(children: [
                        Icon(
                          SupabaseService.instance.isInitialized
                              ? Icons.cloud_done_rounded
                              : Icons.cloud_off_rounded,
                          color: SupabaseService.instance.isInitialized
                              ? AppColors.verdeExito
                              : AppColors.textoSecundario,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(SupabaseService.instance.isInitialized
                            ? 'Supabase conectado'
                            : 'Conectar Supabase'),
                      ]),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'salir',
                      child: Row(children: [
                        Icon(Icons.logout_rounded,
                            color: AppColors.naranjaAlerta, size: 20),
                        SizedBox(width: 8),
                        Text('Cerrar sesión'),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Barra de título de cursos
          Container(
            color: AppColors.blanco,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                const Icon(Icons.library_books_rounded,
                    color: AppColors.granateUnsaac, size: 20),
                const SizedBox(width: 8),
                Text('Mis Cursos', style: AppStyles.subtitulo),
                const Spacer(),
                TextButton.icon(
                  onPressed: _crearCurso,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nuevo'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.granateUnsaac),
                ),
              ],
            ),
          ),

          // Lista de cursos
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.granateUnsaac))
                : _cursos.isEmpty
                    ? _buildEstadoVacio()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cursos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) => _buildTarjetaCurso(_cursos[i]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.granateUnsaac,
        foregroundColor: AppColors.blanco,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo Curso'),
        onPressed: _crearCurso,
      ),
    );
  }

  Widget _buildTarjetaCurso(Curso curso) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.radioTarjeta)),
      color: AppColors.blanco,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.granateUnsaac.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    curso.codigo,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.granateUnsaac,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.azulPizarra.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    curso.semestre,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.azulPizarra,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  iconSize: 20,
                  onSelected: (val) async {
                    if (val == 'alumnos') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GestionAlumnosScreen(curso: curso)),
                      );
                    } else if (val == 'eliminar') {
                      await _eliminarCurso(curso);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'alumnos',
                      child: Row(children: [
                        Icon(Icons.people_rounded,
                            size: 18, color: AppColors.azulPizarra),
                        SizedBox(width: 8),
                        Text('Gestionar alumnos'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.naranjaAlerta),
                        SizedBox(width: 8),
                        Text('Eliminar curso',
                            style:
                                TextStyle(color: AppColors.naranjaAlerta)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              curso.nombre,
              style: AppStyles.subtitulo.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Abrir Sesión de Hoy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.granateUnsaac,
                  foregroundColor: AppColors.blanco,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _abrirSesion(curso),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.class_outlined,
                size: 64, color: AppColors.borde),
            const SizedBox(height: 16),
            Text('Sin cursos aún',
                style: AppStyles.subtitulo
                    .copyWith(color: AppColors.textoSecundario)),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer curso con el botón "Nuevo Curso".',
              style: AppStyles.cuerpoSecundario,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Diálogo Crear Curso ──────────────────────────────────────────────────────

class _CrearCursoDialog extends StatefulWidget {
  final String docenteNombre;
  const _CrearCursoDialog({required this.docenteNombre});

  @override
  State<_CrearCursoDialog> createState() => _CrearCursoDialogState();
}

class _CrearCursoDialogState extends State<_CrearCursoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _semestreController =
      TextEditingController(text: '2026-II');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.radioTarjeta)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nuevo Curso',
                  style: AppStyles.tituloPrincipal.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código (Ej. IF450AIN)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Curso',
                  hintText: 'Ej. Arquitectura de Software',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _semestreController,
                decoration: const InputDecoration(
                  labelText: 'Semestre',
                  hintText: 'Ej. 2026-II',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.granateUnsaac,
                        foregroundColor: AppColors.blanco),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'codigo': _codigoController.text,
                          'nombre': _nombreController.text,
                          'semestre': _semestreController.text,
                        });
                      }
                    },
                    child: const Text('Crear'),
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

// ─── Diálogo Abrir Sesión ─────────────────────────────────────────────────────

class _AbrirSesionDialog extends StatefulWidget {
  final Curso curso;
  const _AbrirSesionDialog({required this.curso});

  @override
  State<_AbrirSesionDialog> createState() => _AbrirSesionDialogState();
}

class _AbrirSesionDialogState extends State<_AbrirSesionDialog> {
  final _temaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.radioTarjeta)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Abrir Sesión',
                style: AppStyles.tituloPrincipal.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(widget.curso.nombre, style: AppStyles.cuerpoSecundario),
            const SizedBox(height: 16),
            TextField(
              controller: _temaController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Tema de la sesión',
                hintText: 'Ej. Patrones de Diseño MVC',
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.topic_rounded, color: AppColors.granateUnsaac),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Iniciar'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.granateUnsaac,
                      foregroundColor: AppColors.blanco),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _temaController.text.trim().isNotEmpty
                          ? _temaController.text.trim()
                          : 'Sesión del día',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
