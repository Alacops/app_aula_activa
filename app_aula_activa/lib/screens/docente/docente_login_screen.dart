import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/docente_service.dart';
import 'mis_cursos_screen.dart';
import 'registro_docente_screen.dart';

/// Pantalla de login del docente con correo y PIN de 4 dígitos.
/// Las credenciales de Supabase NO son accesibles desde aquí;
/// están en Configuración dentro de la pantalla de cursos.
class DocenteLoginScreen extends StatefulWidget {
  const DocenteLoginScreen({super.key});

  @override
  State<DocenteLoginScreen> createState() => _DocenteLoginScreenState();
}

class _DocenteLoginScreenState extends State<DocenteLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _pinController = TextEditingController();
  bool _cargando = false;
  String? _error;
  bool _hayDocentes = false;

  @override
  void initState() {
    super.initState();
    _verificarDocentes();
  }

  Future<void> _verificarDocentes() async {
    final hay = await DocenteService.instance.hayDocentes();
    if (mounted) setState(() => _hayDocentes = hay);
  }

  @override
  void dispose() {
    _correoController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    final doc = await DocenteService.instance.autenticar(
      correo: _correoController.text.trim(),
      pin: _pinController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    if (doc != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MisCursosScreen(docente: doc)),
      );
    } else {
      setState(() => _error = 'Correo o PIN incorrecto. Verifica tus datos.');
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
        title: const Text('Acceso Docente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // Icono
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.doradoUnsaac.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.doradoUnsaac.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(
                      Icons.co_present_rounded,
                      size: 40,
                      color: AppColors.doradoUnsaac,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  _hayDocentes ? 'Bienvenido, Docente' : 'Primera vez',
                  style: AppStyles.tituloPrincipal,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _hayDocentes
                      ? 'Ingresa tu correo y PIN para acceder a tus cursos.'
                      : 'No hay docentes registrados. Crea tu cuenta.',
                  style: AppStyles.cuerpoSecundario,
                  textAlign: TextAlign.center,
                ),

                if (!_hayDocentes) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Crear mi cuenta de Docente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.granateUnsaac,
                      foregroundColor: AppColors.blanco,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegistroDocenteScreen()),
                      );
                      _verificarDocentes();
                    },
                  ),
                ],

                if (_hayDocentes) ...[
                  const SizedBox(height: 28),

                  // Campo Correo
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'docente@unsaac.edu.pe',
                      prefixIcon: Icon(Icons.email_outlined,
                          color: AppColors.granateUnsaac),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo PIN
                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'PIN (4 dígitos)',
                      hintText: '••••',
                      prefixIcon: Icon(Icons.pin_rounded,
                          color: AppColors.granateUnsaac),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 4) {
                        return 'El PIN debe tener 4 dígitos';
                      }
                      return null;
                    },
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.naranjaAlerta.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.naranjaAlerta, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.naranjaAlerta,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _ingresar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.granateUnsaac,
                        foregroundColor: AppColors.blanco,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.blanco),
                            )
                          : const Text('Ingresar',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Enlace para registrarse
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegistroDocenteScreen()),
                      );
                      _verificarDocentes();
                    },
                    child: const Text(
                      'Soy nuevo — Crear cuenta de docente',
                      style: TextStyle(color: AppColors.azulPizarra),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
