import 'package:flutter/material.dart';
import '../models/clase.dart';
import '../services/clase_service.dart';
import '../utils/errores.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';

class ClasesScreen extends StatefulWidget {
  // 0 = disponibles, 1 = mis clases
  final int pestanaInicial;
  const ClasesScreen({super.key, this.pestanaInicial = 0});

  @override
  State<ClasesScreen> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesScreen> {
  final ClaseService _service = ClaseService();
  List<Clase> _disponibles = [];
  List<InscripcionClase> _inscripciones = [];
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
        _disponibles = resultados[0] as List<Clase>;
        _inscripciones = resultados[1] as List<InscripcionClase>;
      });
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _inscribirse(Clase c) async {
    try {
      await _service.inscribirse(c.id);
      if (!mounted) return;
      mostrarOk(context, 'Inscripción enviada. Queda pendiente hasta que el complejo la confirme.');
      _cargar();
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  Future<void> _cancelar(InscripcionClase i) async {
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
    final inscriptas = _inscripciones.where((i) => i.activa).map((i) => i.clase.id).toSet();

    return DefaultTabController(
      length: 2,
      initialIndex: widget.pestanaInicial,
      child: Scaffold(
        appBar: barraApp(
          'Clases',
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Disponibles'), Tab(text: 'Mis clases')],
          ),
        ),
        body: TabBarView(
          children: [
            ListaRefrescable(
              cargando: _loading,
              cantidad: _disponibles.length,
              onRefresh: _cargar,
              vacio: const Vacio(icono: Icons.school_outlined, texto: 'No hay clases publicadas por ahora.'),
              itemBuilder: (_, index) {
                final c = _disponibles[index];
                return _TarjetaClase(
                  clase: c,
                  pie: inscriptas.contains(c.id)
                      ? const Text('Ya estás inscripto', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))
                      : c.confirmadas >= c.cupo
                          ? const Text('Cupo completo', style: TextStyle(color: Colors.grey))
                          : ElevatedButton(
                              onPressed: () => _inscribirse(c),
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
              vacio: const Vacio(icono: Icons.assignment_outlined, texto: 'Todavía no te inscribiste a ninguna clase.'),
              itemBuilder: (_, index) {
                final i = _inscripciones[index];
                final futura = i.clase.fechaHoraInicio.isAfter(DateTime.now());
                return _TarjetaClase(
                  clase: i.clase,
                  estado: i.estado,
                  pie: i.activa && futura
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

class _TarjetaClase extends StatelessWidget {
  final Clase clase;
  final String? estado;
  final Widget? pie;
  const _TarjetaClase({required this.clase, this.estado, this.pie});

  @override
  Widget build(BuildContext context) {
    final c = clase;
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
                const IconoCaja(Icons.school, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clase con ${c.profesor}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${c.nivel != null ? etiquetaCategoria(c.nivel) : 'Todos los niveles'} · ${c.complejoNombre}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                if (estado != null) EstadoChip(estado!),
              ],
            ),
            const SizedBox(height: 12),
            Text('${formatoDia(c.fechaHoraInicio)} · ${formatoHora(c.fechaHoraInicio)} a ${formatoHora(c.fechaHoraFin)}'),
            Text('${c.canchaNombre} · ${formatoPrecio(c.precio)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            if (estado == null)
              Text('${c.confirmadas} de ${c.cupo} lugares ocupados', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            if (c.descripcion != null && c.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(c.descripcion!),
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
