import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/curso_service.dart';
import '../../models/curso.dart';
import '../../models/estudiante.dart';

/// Pantalla para gestionar la lista de alumnos de un curso.
/// El docente puede agregar, ver y eliminar estudiantes.
class GestionAlumnosScreen extends StatefulWidget {
  final Curso curso;

  const GestionAlumnosScreen({super.key, required this.curso});

  @override
  State<GestionAlumnosScreen> createState() => _GestionAlumnosScreenState();
}

class _GestionAlumnosScreenState extends State<GestionAlumnosScreen> {
  List<Estudiante> _estudiantes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    setState(() => _cargando = true);
    final lista = await CursoService.instance
        .listarEstudiantesPorCurso(widget.curso.id);
    if (mounted) {
      setState(() {
        _estudiantes = lista;
        _cargando = false;
      });
    }
  }

  Future<void> _agregarEstudiante() async {
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AgregarEstudianteDialog(
        numeroOrdenSugerido: _estudiantes.length + 1,
      ),
    );
    if (res == null) return;

    await CursoService.instance.agregarEstudiante(
      cursoId: widget.curso.id,
      numeroOrden: res['numeroOrden'],
      nombres: res['nombres'],
      apellidos: res['apellidos'],
      codigoUnsaac: res['codigoUnsaac'],
    );
    await _cargarEstudiantes();
  }

  Future<void> _eliminarEstudiante(Estudiante est) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar alumno'),
        content: Text('¿Eliminar a ${est.nombreCompleto}?'),
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
    await CursoService.instance.eliminarEstudiante(est.id);
    await _cargarEstudiantes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.granateUnsaac,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lista de Alumnos', style: TextStyle(fontSize: 16)),
            Text(
              '${widget.curso.codigo} — ${widget.curso.nombre}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xCCFFFFFF)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Agregar alumno',
            icon: const Icon(Icons.person_add_rounded),
            onPressed: _agregarEstudiante,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granateUnsaac))
          : _estudiantes.isEmpty
              ? _buildEstadoVacio()
              : Column(
                  children: [
                    // Info de cabecera
                    Container(
                      color: AppColors.blanco,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        children: [
                          const Icon(Icons.people_rounded,
                              color: AppColors.granateUnsaac, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${_estudiantes.length} alumnos registrados',
                            style: AppStyles.cuerpo
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    // Lista
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _estudiantes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final est = _estudiantes[i];
                          return Card(
                            elevation: 0,
                            color: AppColors.blanco,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppColors.borde),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.granateUnsaac
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  '${est.numeroOrden}',
                                  style: const TextStyle(
                                    color: AppColors.granateUnsaac,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              title: Text(est.nombreCompleto,
                                  style: AppStyles.cuerpo
                                      .copyWith(fontWeight: FontWeight.w600)),
                              subtitle: est.codigoUnsaac.isNotEmpty
                                  ? Text('Cód: ${est.codigoUnsaac}',
                                      style: AppStyles.cuerpoSecundario
                                          .copyWith(fontSize: 12))
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.naranjaAlerta, size: 20),
                                onPressed: () => _eliminarEstudiante(est),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.granateUnsaac,
        foregroundColor: AppColors.blanco,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Agregar Alumno'),
        onPressed: _agregarEstudiante,
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
            const Icon(Icons.people_outline_rounded,
                size: 64, color: AppColors.borde),
            const SizedBox(height: 16),
            Text('Sin alumnos registrados',
                style: AppStyles.subtitulo
                    .copyWith(color: AppColors.textoSecundario)),
            const SizedBox(height: 8),
            Text(
              'Agrega alumnos con el botón "Agregar Alumno" para que aparezcan en el ranking.',
              style: AppStyles.cuerpoSecundario,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Diálogo Agregar Estudiante ───────────────────────────────────────────────

class _AgregarEstudianteDialog extends StatefulWidget {
  final int numeroOrdenSugerido;
  const _AgregarEstudianteDialog({required this.numeroOrdenSugerido});

  @override
  State<_AgregarEstudianteDialog> createState() =>
      _AgregarEstudianteDialogState();
}

class _AgregarEstudianteDialogState
    extends State<_AgregarEstudianteDialog> { // ignore: unnecessary_underscores
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ordenController;
  final _apellidosController = TextEditingController();
  final _nombresController = TextEditingController();
  final _codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ordenController =
        TextEditingController(text: widget.numeroOrdenSugerido.toString());
  }

  @override
  void dispose() {
    _ordenController.dispose();
    _apellidosController.dispose();
    _nombresController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radioTarjeta)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar Alumno',
                  style:
                      AppStyles.tituloPrincipal.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ordenController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'N° de Orden',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  if (int.tryParse(v.trim()) == null) return 'Solo números';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _apellidosController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nombresController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Código UNSAAC (Opcional)',
                  hintText: 'Ej. 174449',
                  border: OutlineInputBorder(),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.granateUnsaac,
                        foregroundColor: AppColors.blanco),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'numeroOrden':
                              int.parse(_ordenController.text.trim()),
                          'apellidos': _apellidosController.text,
                          'nombres': _nombresController.text,
                          'codigoUnsaac': _codigoController.text,
                        });
                      }
                    },
                    child: const Text('Guardar'),
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
