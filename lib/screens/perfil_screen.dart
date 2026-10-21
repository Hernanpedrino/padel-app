import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/perfil.dart';
import '../providers/auth_provider.dart';
import '../services/usuario_service.dart';
import '../utils/errores.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final UsuarioService _service = UsuarioService();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _telefono = TextEditingController();
  String? _categoria;
  String? _genero;
  // Id del perfil cargado en el formulario, para no pisar lo que el usuario está editando
  String? _cargadoId;
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _llenar(Perfil p) {
    _cargadoId = p.id;
    _nombre.text = p.nombre;
    _apellido.text = p.apellido;
    _telefono.text = p.telefono ?? '';
    _categoria = p.categoria;
    _genero = p.genero;
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final perfil = await _service.actualizarPerfil({
        'nombre': _nombre.text.trim(),
        'apellido': _apellido.text.trim(),
        'telefono': _telefono.text.trim(),
        'categoria': ?_categoria,
        'genero': ?_genero,
      });
      if (!mounted) return;
      context.read<AuthProvider>().actualizarPerfil(perfil);
      mostrarOk(context, 'Perfil actualizado');
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final perfil = auth.perfil;
    if (perfil != null && _cargadoId != perfil.id) _llenar(perfil);

    return Scaffold(
      appBar: barraApp('Mi perfil'),
      body: perfil == null
          ? Center(
              child: Vacio(
                icono: Icons.cloud_off,
                texto: 'No se pudo cargar tu perfil.',
                accion: 'Reintentar',
                onAccion: auth.recargarPerfil,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: colorPrimario.withValues(alpha: 0.1),
                    child: Text(perfil.nombre[0], style: const TextStyle(fontSize: 28, color: colorPrimario)),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text(perfil.email, style: const TextStyle(color: Colors.grey))),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: _campo(_nombre, 'Nombre')),
                  const SizedBox(width: 12),
                  Expanded(child: _campo(_apellido, 'Apellido')),
                ]),
                const SizedBox(height: 12),
                _campo(_telefono, 'Teléfono', teclado: TextInputType.phone),
                const SizedBox(height: 24),
                const Text('Para partidos y torneos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                  items: categorias.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (v) => setState(() => _categoria = v),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  emptySelectionAllowed: true,
                  segments: generos.entries.map((e) => ButtonSegment(value: e.key, label: Text(e.value))).toList(),
                  selected: {?_genero},
                  onSelectionChanged: (s) => setState(() => _genero = s.isEmpty ? _genero : s.first),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(backgroundColor: colorPrimario, foregroundColor: Colors.white),
                    child: _guardando
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Guardar cambios'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: auth.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
    );
  }

  Widget _campo(TextEditingController controller, String label, {TextInputType? teclado}) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
