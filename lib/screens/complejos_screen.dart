import 'package:flutter/material.dart';
import '../models/complejo.dart';
import '../services/turno_service.dart';
import '../services/usuario_service.dart';
import '../utils/errores.dart';
import '../widgets/comunes.dart';
import 'turnos_screen.dart';

// Pestaña "Reservar": complejos con su estrella de favorito
class ComplejosScreen extends StatefulWidget {
  const ComplejosScreen({super.key});

  @override
  State<ComplejosScreen> createState() => _ComplejosScreenState();
}

class _ComplejosScreenState extends State<ComplejosScreen> {
  final TurnoService _turnoService = TurnoService();
  final UsuarioService _usuarioService = UsuarioService();
  List<Complejo> _complejos = [];
  Set<String> _favoritos = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComplejos();
  }

  Future<void> _loadComplejos() async {
    try {
      final resultados = await Future.wait([_turnoService.getComplejos(), _usuarioService.favoritos()]);
      if (!mounted) return;
      setState(() {
        _complejos = resultados[0];
        _favoritos = resultados[1].map((c) => c.id).toSet();
      });
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFavorito(Complejo complejo) async {
    final esFavorito = _favoritos.contains(complejo.id);
    // Se actualiza al instante y se revierte si el backend falla
    setState(() => esFavorito ? _favoritos.remove(complejo.id) : _favoritos.add(complejo.id));
    try {
      if (esFavorito) {
        await _usuarioService.quitarFavorito(complejo.id);
      } else {
        await _usuarioService.agregarFavorito(complejo.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => esFavorito ? _favoritos.add(complejo.id) : _favoritos.remove(complejo.id));
      mostrarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Favoritos primero
    final ordenados = [..._complejos]
      ..sort((a, b) => (_favoritos.contains(b.id) ? 1 : 0) - (_favoritos.contains(a.id) ? 1 : 0));

    return Scaffold(
      appBar: barraApp('Reservar cancha'),
      body: ListaRefrescable(
        cargando: _loading,
        cantidad: ordenados.length,
        onRefresh: _loadComplejos,
        vacio: const Vacio(icono: Icons.sports_tennis, texto: 'No hay complejos disponibles'),
        itemBuilder: (context, index) {
          final complejo = ordenados[index];
          final favorito = _favoritos.contains(complejo.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              leading: const IconoCaja(Icons.sports_tennis),
              title: Text(complejo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(complejo.direccion),
                  Text(complejo.telefono, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              trailing: IconButton(
                icon: Icon(favorito ? Icons.star : Icons.star_border, color: favorito ? Colors.amber : Colors.grey),
                tooltip: favorito ? 'Quitar de favoritos' : 'Agregar a favoritos',
                onPressed: () => _toggleFavorito(complejo),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TurnosScreen(complejo: complejo)),
              ),
            ),
          );
        },
      ),
    );
  }
}
