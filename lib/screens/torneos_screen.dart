import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/torneo.dart';
import '../providers/auth_provider.dart';
import '../services/torneo_service.dart';
import '../utils/errores.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';

class TorneosScreen extends StatefulWidget {
  // 0 = disponibles, 1 = mis inscripciones
  final int pestanaInicial;
  const TorneosScreen({super.key, this.pestanaInicial = 0});

  @override
  State<TorneosScreen> createState() => _TorneosScreenState();
}

class _TorneosScreenState extends State<TorneosScreen> {
  final TorneoService _service = TorneoService();
  List<Torneo> _disponibles = [];
  List<InscripcionTorneo> _inscripciones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final resultados = await Future.wait([_service.disponibles(), _service.misInscripciones()]);
      if (!mounted) return;
      setState(() {
        _disponibles = resultados[0] as List<Torneo>;
        _inscripciones = resultados[1] as List<InscripcionTorneo>;
      });
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _inscribirse(Torneo t) async {
    final perfil = context.read<AuthProvider>().perfil;
    if (perfil != null && !perfil.completo) {
      mostrarError(context, 'Completá tu categoría y género en el perfil para inscribirte.');
      return;
    }
    final email = await showDialog<String>(context: context, builder: (_) => _DialogoCompanero(torneo: t));
    if (email == null || !mounted) return;
    try {
      await _service.inscribirse(t.id, email);
      if (!mounted) return;
      mostrarOk(context, 'Inscripción enviada. Queda pendiente hasta que el complejo la confirme.');
      _cargar();
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  Future<void> _cancelar(InscripcionTorneo i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar inscripción'),
        content: Text('¿Seguro que querés darte de baja de "${i.torneo.nombre}"? Se cancela para los dos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.cancelarInscripcion(i.id);
      if (!mounted) return;
      mostrarOk(context, 'Inscripción cancelada');
      _cargar();
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final miId = context.watch<AuthProvider>().perfil?.id ?? '';
    final inscriptos = _inscripciones.where((i) => i.activa).map((i) => i.torneo.id).toSet();

    return DefaultTabController(
      length: 2,
      initialIndex: widget.pestanaInicial,
      child: Scaffold(
        appBar: barraApp(
          'Torneos',
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Disponibles'), Tab(text: 'Mis inscripciones')],
          ),
        ),
        body: TabBarView(
          children: [
            ListaRefrescable(
              cargando: _loading,
              cantidad: _disponibles.length,
              onRefresh: _cargar,
              vacio: const Vacio(icono: Icons.emoji_events_outlined, texto: 'No hay torneos con inscripción abierta.'),
              itemBuilder: (_, index) {
                final t = _disponibles[index];
                return _TarjetaTorneo(
                  torneo: t,
                  pie: inscriptos.contains(t.id)
                      ? const Text('Ya estás inscripto', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))
                      : t.confirmadas >= t.cupoParejas
                          ? const Text('Cupo completo', style: TextStyle(color: Colors.grey))
                          : ElevatedButton(
                              onPressed: () => _inscribirse(t),
                              style: ElevatedButton.styleFrom(backgroundColor: colorPrimario, foregroundColor: Colors.white),
                              child: const Text('Inscribirme'),
                            ),
                );
              },
            ),
            ListaRefrescable(
              cargando: _loading,
              cantidad: _inscripciones.length,
              onRefresh: _cargar,
              vacio: const Vacio(icono: Icons.assignment_outlined, texto: 'Todavía no te inscribiste a ningún torneo.'),
              itemBuilder: (_, index) {
                final i = _inscripciones[index];
                return _TarjetaTorneo(
                  torneo: i.torneo,
                  estado: i.estado,
                  extra: 'Con ${i.companeroDe(miId).nombreCompleto}',
                  pie: i.activa
                      ? TextButton(
                          onPressed: () => _cancelar(i),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Cancelar inscripción'),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaTorneo extends StatelessWidget {
  final Torneo torneo;
  final String? estado;
  final String? extra;
  final Widget? pie;
  const _TarjetaTorneo({required this.torneo, this.estado, this.extra, this.pie});

  @override
  Widget build(BuildContext context) {
    final t = torneo;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconoCaja(Icons.emoji_events, color: Colors.purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${etiquetaCategoria(t.categoria)} · ${etiquetaRama(t.rama)} · ${t.complejoNombre}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                if (estado != null) EstadoChip(estado!),
              ],
            ),
            const SizedBox(height: 12),
            Text('Del ${formatoDiaCorto(t.fechaInicio)} al ${formatoDiaCorto(t.fechaFin)}'),
            Text('Inscripción hasta el ${formatoDiaCorto(t.cierreInscripcion)} · ${formatoPrecio(t.precioInscripcion)} por pareja',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            if (estado == null)
              Text('${t.confirmadas} de ${t.cupoParejas} parejas confirmadas',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            if (extra != null) Text(extra!, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            if (t.descripcion != null && t.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.descripcion!),
            ],
            if (pie != null) ...[
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: pie!),
            ],
          ],
        ),
      ),
    );
  }
}

// Pide el email del compañero de pareja
class _DialogoCompanero extends StatefulWidget {
  final Torneo torneo;
  const _DialogoCompanero({required this.torneo});

  @override
  State<_DialogoCompanero> createState() => _DialogoCompaneroState();
}

class _DialogoCompaneroState extends State<_DialogoCompanero> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Inscribirme a ${widget.torneo.nombre}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Se juega en pareja. Ingresá el email con el que tu compañero/a está registrado en la app.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Email del compañero/a', border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            final email = _controller.text.trim();
            if (email.isNotEmpty) Navigator.pop(context, email);
          },
          child: const Text('Inscribirme'),
        ),
      ],
    );
  }
}
