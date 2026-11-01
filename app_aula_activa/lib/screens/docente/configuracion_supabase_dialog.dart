import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/supabase_service.dart';

class ConfiguracionSupabaseDialog extends StatefulWidget {
  const ConfiguracionSupabaseDialog({super.key});

  @override
  State<ConfiguracionSupabaseDialog> createState() =>
      _ConfiguracionSupabaseDialogState();
}

class _ConfiguracionSupabaseDialogState
    extends State<ConfiguracionSupabaseDialog> {
  final _urlController = TextEditingController();
  final _anonKeyController = TextEditingController();
  bool _guardando = false;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    _cargarCredenciales();
  }

  Future<void> _cargarCredenciales() async {
    final creds = await SupabaseService.instance.getSavedCredentials();
    _urlController.text = creds['url'] ?? '';
    _anonKeyController.text = creds['anonKey'] ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final estaConectado = SupabaseService.instance.isInitialized;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radioTarjeta),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_sync_rounded,
                      color: AppColors.granateUnsaac, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Conexión Supabase Cloud',
                        style: AppStyles.tituloPrincipal.copyWith(fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: estaConectado
                      ? AppColors.verdeExito.withValues(alpha: 0.1)
                      : AppColors.doradoUnsaac.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      estaConectado ? Icons.check_circle : Icons.info_outline,
                      color: estaConectado
                          ? AppColors.verdeExito
                          : AppColors.doradoUnsaac,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        estaConectado
                            ? 'Conectado a la base de datos Supabase'
                            : 'Modo Local Activo (Offline / Sin internet)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: estaConectado
                              ? AppColors.verdeExito
                              : AppColors.doradoUnsaac,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Project URL de Supabase',
                  hintText: 'https://xyzcompany.supabase.co',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _anonKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Anon Public Key',
                  hintText: 'eyJhbGciOiJIUzI1NiIsInR5c...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key_rounded),
                ),
              ),
              if (_mensaje != null) ...[
                const SizedBox(height: 10),
                Text(_mensaje!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _mensaje!.contains('éxito')
                          ? AppColors.verdeExito
                          : AppColors.naranjaAlerta,
                    )),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _guardando
                        ? null
                        : () async {
                            setState(() => _guardando = true);
                            final ok = await SupabaseService.instance
                                .saveCredentials(
                              _urlController.text,
                              _anonKeyController.text,
                            );
                            setState(() {
                              _guardando = false;
                              _mensaje = ok
                                  ? '¡Conexión establecida con éxito!'
                                  : 'Guardado. Revisa tus credenciales o conexión.';
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.granateUnsaac,
                      foregroundColor: AppColors.blanco,
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.blanco),
                          )
                        : const Text('Guardar y Probar'),
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
