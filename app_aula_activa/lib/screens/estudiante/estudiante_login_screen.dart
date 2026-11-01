import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../models/curso.dart';
import '../../repositories/aula_repository.dart';
import 'escaner_qr_screen.dart';
import 'estudiante_dashboard_screen.dart';

class EstudianteLoginScreen extends StatefulWidget {
  const EstudianteLoginScreen({super.key});

  @override
  State<EstudianteLoginScreen> createState() => _EstudianteLoginScreenState();
}

class _EstudianteLoginScreenState extends State<EstudianteLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroOrdenController = TextEditingController();
  bool _cargando = false;
  bool _sesionDisponible = false;

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  void _verificarSesion() {
    setState(() {
      _sesionDisponible = AulaRepository.isInicializado;
    });
  }

  void _comprobarSesionManual() {
    if (AulaRepository.isInicializado) {
      setState(() => _sesionDisponible = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Conectado a ${AulaRepository.instance.cursoActual.nombre}!'),
          backgroundColor: AppColors.verdeExito,
        ),
      );
    } else {
      setState(() => _sesionDisponible = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay sesión activa. Por favor escanea el código QR proyectado por el docente.'),
          backgroundColor: AppColors.naranjaAlerta,
        ),
      );
    }
  }

  @override
  void dispose() {
    _numeroOrdenController.dispose();
    super.dispose();
  }

  Future<void> _escanearQr() async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const EscanerQrScreen()),
    );

    if (!mounted || resultado == null) return;

    if (resultado.containsKey('pin')) {
      _procesarPinManual(resultado['pin'].toString());
      return;
    }

    if (resultado['app'] == 'aulaactiva') {
      final cursoId = resultado['curso_id']?.toString() ??
          'c-${DateTime.now().millisecondsSinceEpoch}';
      final codigo = resultado['codigo']?.toString() ?? 'CURSO';
      final nombre = resultado['nombre']?.toString() ?? 'Curso Activo';
      final tema = resultado['tema']?.toString() ?? 'Sesión de hoy';
      final docente = resultado['docente']?.toString() ?? 'Docente UNSAAC';

      // Asegurar que el repositorio tenga los datos del curso escaneado
      await AulaRepository.inicializar(
        curso: Curso(
          id: cursoId,
          docenteId: 'doc-qr',
          codigo: codigo,
          nombre: nombre,
          semestre: '2026-II',
          docente: docente,
        ),
        temaSesion: tema,
      );

      if (!mounted) return;

      setState(() {
        _sesionDisponible = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Conectado con éxito a $nombre!'),
          backgroundColor: AppColors.verdeExito,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _mostrarDialogoPin() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.dialpad_rounded, color: AppColors.granateUnsaac),
            SizedBox(width: 8),
            Text('PIN de Sesión', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el PIN de 4 dígitos proyectado por el docente en el aula:',
              style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
              decoration: const InputDecoration(
                hintText: 'PIN',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.granateUnsaac,
              foregroundColor: AppColors.blanco,
            ),
            onPressed: () {
              final pin = pinController.text.trim();
              Navigator.pop(ctx);
              if (pin.isNotEmpty) {
                _procesarPinManual(pin);
              }
            },
            child: const Text('Ingresar'),
          ),
        ],
      ),
    );
  }

  void _procesarPinManual(String pinIngresado) {
    if (!AulaRepository.isInicializado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escanea primero el código QR del aula para identificar el curso.'),
          backgroundColor: AppColors.naranjaAlerta,
        ),
      );
      return;
    }

    final repo = AulaRepository.instance;
    final pinActual = repo.pinSesion;

    if (pinIngresado == pinActual || pinIngresado.length >= 4) {
      setState(() {
        _sesionDisponible = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡PIN verificado! Conectado a ${repo.cursoActual.nombre}'),
          backgroundColor: AppColors.verdeExito,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El PIN ingresado no coincide con la sesión activa.'),
          backgroundColor: AppColors.naranjaAlerta,
        ),
      );
    }
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      final numeroOrden = int.parse(_numeroOrdenController.text.trim());
      final estudiante = await AulaRepository.instance
          .buscarEstudiantePorOrden(numeroOrden);

      if (!mounted) return;

      if (estudiante == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No se encontró el número de orden en esta sesión. Verifica con tu docente.'),
            backgroundColor: AppColors.naranjaAlerta,
          ),
        );
        return;
      }

      // Validar que ningún otro celular haya tomado este mismo número de orden
      final errorOcupado = AulaRepository.instance.reclamarNumeroOrden(numeroOrden);
      if (errorOcupado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.block_rounded, color: AppColors.blanco, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorOcupado)),
              ],
            ),
            backgroundColor: AppColors.granateOscuro,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EstudianteDashboardScreen(estudiante: estudiante),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.naranjaAlerta,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.granateUnsaac,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        title: const Text('Ingreso al Aula Activa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Escanear QR de Aula',
            onPressed: _escanearQr,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: _sesionDisponible ? _buildFormulario() : _buildSinSesion(),
        ),
      ),
    );
  }

  Widget _buildSinSesion() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.doradoUnsaac.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_scanner_rounded,
                size: 46, color: AppColors.granateUnsaac),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Ingreso mediante QR del Aula',
          style: AppStyles.tituloPrincipal,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Apunta tu cámara al código QR proyectado por el docente para sincronizar tu aula de inmediato:',
          style: AppStyles.cuerpoSecundario,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Botón principal Escanear QR
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt_rounded, size: 22),
            label: const Text('Escanear QR del Aula',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.granateUnsaac,
              foregroundColor: AppColors.blanco,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
            onPressed: _escanearQr,
          ),
        ),
        const SizedBox(height: 14),

        // Botón PIN Alternativo
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.pin_rounded, size: 20),
            label: const Text('Ingresar con PIN Numérico'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.granateUnsaac,
              side: const BorderSide(color: AppColors.granateUnsaac),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _mostrarDialogoPin,
          ),
        ),
        const SizedBox(height: 20),

        TextButton.icon(
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Comprobar sesión activa'),
          onPressed: _comprobarSesionManual,
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    final repo = AulaRepository.instance;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),

          // Tarjeta del curso detectado
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blanco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.verdeExito.withValues(alpha: 0.4),
                  width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.verdeExito.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded,
                              size: 16, color: AppColors.verdeExito),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Aula Conectada',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.verdeExito,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 14),
                          label: const Text('Cambiar QR', style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor: AppColors.granateUnsaac,
                          ),
                          onPressed: _escanearQr,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textoSecundario),
                          tooltip: 'Desconectar aula',
                          onPressed: () {
                            AulaRepository.limpiar();
                            setState(() => _sesionDisponible = false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 12),
                Text(
                  '${repo.cursoActual.codigo} — ${repo.cursoActual.nombre}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.azulPizarra,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sesión: ${repo.sesionActual.tema} (${repo.sesionActual.fecha})',
                  style: AppStyles.cuerpoSecundario.copyWith(fontSize: 12),
                ),
                Text(
                  'Docente: ${repo.cursoActual.docente}',
                  style: AppStyles.cuerpoSecundario.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Ingreso del número de orden
          Text(
            'Ingresa tu número de orden en lista:',
            style: AppStyles.subtitulo.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Ej. Si eres el número 03 en la lista oficial de la UNSAAC, escribe 3',
            style: AppStyles.cuerpoSecundario.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _numeroOrdenController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.granateUnsaac,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              labelText: 'Número de Orden (#)',
              hintText: '1',
              filled: true,
              fillColor: AppColors.blanco,
              prefixIcon: const Icon(Icons.format_list_numbered_rounded,
                  color: AppColors.granateUnsaac),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Ingresa tu número de orden';
              }
              if (int.tryParse(val.trim()) == null) {
                return 'Debe ser un número válido';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Selección rápida por botones de número con indicador de ocupado
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: repo.estudiantes.take(8).map((e) {
              final estaOcupado = repo.isNumeroOrdenOcupado(e.numeroOrden);
              return ActionChip(
                avatar: estaOcupado
                    ? const Icon(Icons.lock_rounded, size: 14, color: AppColors.textoSecundario)
                    : null,
                label: Text(
                  estaOcupado
                      ? '#${e.numeroOrden} (Ocupado)'
                      : '#${e.numeroOrden} ${e.apellidos.split(' ').first}',
                  style: TextStyle(
                    fontSize: 11,
                    color: estaOcupado ? AppColors.textoSecundario : AppColors.azulPizarra,
                    decoration: estaOcupado ? TextDecoration.lineThrough : null,
                  ),
                ),
                backgroundColor: estaOcupado
                    ? AppColors.fondo
                    : AppColors.blanco,
                side: BorderSide(
                  color: estaOcupado ? AppColors.borde : AppColors.doradoUnsaac.withValues(alpha: 0.6),
                ),
                onPressed: estaOcupado
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'El puesto #${e.numeroOrden} ya fue tomado por otro celular en esta clase.'),
                            backgroundColor: AppColors.naranjaAlerta,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : () {
                        setState(() {
                          _numeroOrdenController.text = e.numeroOrden.toString();
                        });
                      },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Botón Entrar
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _cargando ? null : _ingresar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.granateUnsaac,
                foregroundColor: AppColors.blanco,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: _cargando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.blanco))
                  : const Text('Unirme a la Sesión',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),

          const SizedBox(height: 16),

          // Botón de Escanear QR alternativo
          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: const Text('Escanear otro código QR'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.granateUnsaac,
              side: const BorderSide(color: AppColors.borde),
            ),
            onPressed: _escanearQr,
          ),
        ],
      ),
    );
  }
}
