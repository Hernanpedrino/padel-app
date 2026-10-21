import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complejo.dart';
import '../models/turno.dart';
import '../services/turno_service.dart';
import '../services/reserva_service.dart';
import '../utils/errores.dart';
import 'crear_partido_screen.dart';

class TurnosScreen extends StatefulWidget {
  final Complejo complejo;
  const TurnosScreen({super.key, required this.complejo});

  @override
  State<TurnosScreen> createState() => _TurnosScreenState();
}

class _TurnosScreenState extends State<TurnosScreen> {
  final TurnoService _turnoService = TurnoService();
  final ReservaService _reservaService = ReservaService();
  List<Turno> _turnos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTurnos();
  }

  Future<void> _loadTurnos() async {
    try {
      final turnos = await _turnoService.getTurnosDisponibles(widget.complejo.id);
      if (mounted) setState(() => _turnos = turnos);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reservar(Turno turno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar reserva'),
        content: Text(
          '${turno.cancha.nombre}\n'
          '${DateFormat('EEEE dd/MM', 'es').format(turno.fechaHoraInicio)}\n'
          '${DateFormat('HH:mm').format(turno.fechaHoraInicio)} - ${DateFormat('HH:mm').format(turno.fechaHoraFin)}\n'
          '\$${turno.precio.toStringAsFixed(0)}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _reservaService.crearReserva(turno.id);
    } catch (e) {
      if (mounted) mostrarError(context, e);
      return;
    }
    if (!mounted) return;

    // Con la cancha reservada ya se puede armar un partido para buscar jugadores
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Reserva confirmada!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'BUSCAR JUGADORES',
          textColor: Colors.white,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearPartidoScreen())),
        ),
      ),
    );
    _loadTurnos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.complejo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _turnos.isEmpty
              ? const Center(child: Text('No hay turnos disponibles'))
              : RefreshIndicator(
                  onRefresh: _loadTurnos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _turnos.length,
                    itemBuilder: (context, index) {
                      final turno = _turnos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.access_time, color: Color(0xFF1565C0)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(turno.cancha.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      turno.cancha.tipo.replaceAll('_', ' '),
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('EEEE dd/MM', 'es').format(turno.fechaHoraInicio),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      '${DateFormat('HH:mm').format(turno.fechaHoraInicio)} - ${DateFormat('HH:mm').format(turno.fechaHoraFin)}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${turno.precio.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1565C0)),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _reservar(turno),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1565C0),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Reservar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}