import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/docente_service.dart';

/// Pantalla para crear una cuenta de docente (nombre, correo, PIN).
class RegistroDocenteScreen extends StatefulWidget {
  const RegistroDocenteScreen({super.key});

  @override
  State<RegistroDocenteScreen> createState() => _RegistroDocenteScreenState();
}

class _RegistroDocenteScreenState extends State<RegistroDocenteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmarPinController = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _pinController.dispose();
    _confirmarPinController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    await DocenteService.instance.registrarDocente(
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      correo: _correoController.text.trim(),
      pin: _pinController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada! Ahora puedes ingresar con tu correo y PIN.'),
          backgroundColor: AppColors.verdeExito,
        ),
      );
      Navigator.pop(context);
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
        title: const Text('Crear Cuenta de Docente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Datos del Docente',
                  style: AppStyles.tituloPrincipal.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Esta información se guarda solo en este dispositivo.',
                  style: AppStyles.cuerpoSecundario,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nombresController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombres',
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppColors.granateUnsaac),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _apellidosController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Apellidos',
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppColors.granateUnsaac),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'docente@unsaac.edu.pe',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: AppColors.granateUnsaac),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo requerido';
                    if (!v.contains('@')) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'PIN de Seguridad',
                  style: AppStyles.subtitulo.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '4 dígitos numéricos. Lo usarás cada vez que entres al modo Docente.',
                  style: AppStyles.cuerpoSecundario.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'PIN (4 dígitos)',
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.granateUnsaac),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length != 4) {
                      return 'El PIN debe tener exactamente 4 dígitos';
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'El PIN solo puede contener números';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _confirmarPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar PIN',
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.granateUnsaac),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v != _pinController.text) return 'Los PINs no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.granateUnsaac,
                      foregroundColor: AppColors.blanco,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.blanco),
                          )
                        : const Text('Crear Cuenta',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
