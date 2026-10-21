import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partido.dart';
import '../models/reserva.dart';
import '../providers/auth_provider.dart';
import '../services/partido_service.dart';
import '../services/reserva_service.dart';
import '../utils/errores.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';

// Un partido se arma sobre una cancha que el usuario ya reservó
class CrearPartidoScreen extends StatefulWidget {
  const CrearPartidoScreen({super.key});

  @override
  State<CrearPartidoScreen> createState() => _CrearPartidoScreenState();
}

class _CrearPartidoScreenState extends State<CrearPartidoScreen> {
  final ReservaService _reservaService = ReservaService();
  final PartidoService _partidoService = PartidoService();
  final _descripcionController = TextEditingController();

  List<Reserva> _reservas = [];
  bool _loading = true;
  bool _guardando = false;
  String? _turnoId;
  String? _categoria;
  String? _rama;
  int _jugadoresBuscados = 3;

  @override
  void initState() {
    super.initState();
    final perfil = context.read<AuthProvider>().perfil;
    // Por defecto, la categoría y la rama del propio jugador
    _categoria = perfil?.categoria;
    _rama = perfil?.genero;
    _cargar();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final resultados = await Future.wait([_reservaService.getMisReservas(), _partidoService.misPartidos()]);
      final reservas = resultados[0] as List<Reserva>;
      final miId = mounted ? context.read<AuthProvider>().perfil?.id : null;
      // Turnos que ya tienen un partido activo organizado por el usuario
      final conPartido = (resultados[1] as List<Partido>)
          .where((p) => p.creador.id == miId && p.estado != 'CANCELADO')
          .map((p) => p.turno.id)
          .toSet();
      final ahora = DateTime.now();
      if (!mounted) return;
      setState(() {
        _reservas = reservas
            .where((r) => r.estado == 'CONFIRMADA' && r.turno.fechaHoraInicio.isAfter(ahora) && !conPartido.contains(r.turno.id))
            .toList()
          ..sort((a, b) => a.turno.fechaHoraInicio.compareTo(b.turno.fechaHoraInicio));
        if (_reservas.length == 1) _turnoId = _reservas.first.turno.id;
      });
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _publicar() async {
    if (_turnoId == null || _categoria == null || _rama == null) {
      mostrarError(context, 'Elegí la cancha, la categoría y la rama');
      return;
    }
    setState(() => _guardando = true);
    try {
      await _partidoService.crear(
        turnoId: _turnoId!,
        categoria: _categoria!,
        rama: _rama!,
        jugadoresBuscados: _jugadoresBuscados,
        descripcion: _descripcionController.text.trim(),
      );
      if (!mounted) return;
      mostrarOk(context, '¡Partido publicado! Te avisamos cuando alguien quiera sumarse.');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraApp('Armar partido'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reservas.isEmpty
              ? const Vacio(
                  icono: Icons.event_busy,
                  texto: 'Para armar un partido primero tenés que reservar una cancha.\n'
                      'Reservá un turno en "Reservar" y volvé acá.',
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('¿En qué cancha se juega?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    RadioGroup<String>(
                      groupValue: _turnoId,
                      onChanged: (v) => setState(() => _turnoId = v),
                      child: Column(
                        children: _reservas
                            .map((r) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: RadioListTile<String>(
                                    value: r.turno.id,
                                    title: Text('${formatoDia(r.turno.fechaHoraInicio)} · ${formatoHora(r.turno.fechaHoraInicio)}'),
                                    subtitle: Text('${r.complejoNombre ?? ''} · ${r.turno.cancha.nombre}'),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('¿A quién buscás?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _categoria,
                            decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                            items: categorias.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                            onChanged: (v) => setState(() => _categoria = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _rama,
                            decoration: const InputDecoration(labelText: 'Rama', border: OutlineInputBorder()),
                            items: ramas.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                            onChanged: (v) => setState(() => _rama = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('¿Cuántos jugadores te faltan?'),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('1')),
                        ButtonSegment(value: 2, label: Text('2')),
                        ButtonSegment(value: 3, label: Text('3')),
                      ],
                      selected: {_jugadoresBuscados},
                      onSelectionChanged: (s) => setState(() => _jugadoresBuscados = s.first),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descripcionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Comentario (opcional)',
                        hintText: 'Ej: partido tranqui, se divide la cancha',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _publicar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimario,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _guardando
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Publicar partido'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
