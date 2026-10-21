import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partido.dart';
import '../providers/auth_provider.dart';
import '../services/partido_service.dart';
import '../utils/errores.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/partido_card.dart';
import 'crear_partido_screen.dart';
import 'partido_detalle_screen.dart';

// Pestaña "Partidos": buscar partidos abiertos y ver los propios
class PartidosScreen extends StatefulWidget {
  const PartidosScreen({super.key});

  @override
  State<PartidosScreen> createState() => _PartidosScreenState();
}

class _PartidosScreenState extends State<PartidosScreen> {
  final PartidoService _service = PartidoService();
  List<Partido> _abiertos = [];
  List<Partido> _mios = [];
  bool _loading = true;
  String? _categoria;
  String? _rama;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final resultados = await Future.wait([
        _service.buscar(categoria: _categoria, rama: _rama),
        _service.misPartidos(),
      ]);
      if (!mounted) return;
      setState(() {
        _abiertos = resultados[0];
        _mios = resultados[1];
      });
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _abrirDetalle(Partido p) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => PartidoDetalleScreen(partidoId: p.id)));
    _cargar();
  }

  Future<void> _armarPartido() async {
    final creado = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CrearPartidoScreen()));
    if (creado == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final miId = context.watch<AuthProvider>().perfil?.id;
    // En "Buscar" no se muestran los partidos que organiza el propio usuario
    final abiertos = _abiertos.where((p) => p.creador.id != miId).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: barraApp(
          'Partidos',
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Buscar'), Tab(text: 'Mis partidos')],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _armarPartido,
          backgroundColor: colorPrimario,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Armar partido'),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                _filtros(),
                Expanded(
                  child: ListaRefrescable(
                    cargando: _loading,
                    cantidad: abiertos.length,
                    onRefresh: _cargar,
                    vacio: const Vacio(
                      icono: Icons.search_off,
                      texto: 'No hay partidos buscando jugadores con estos filtros.',
                    ),
                    itemBuilder: (_, i) => PartidoCard(partido: abiertos[i], onTap: () => _abrirDetalle(abiertos[i])),
                  ),
                ),
              ],
            ),
            ListaRefrescable(
              cargando: _loading,
              cantidad: _mios.length,
              onRefresh: _cargar,
              vacio: Vacio(
                icono: Icons.groups_outlined,
                texto: 'Todavía no organizaste ni te sumaste a ningún partido.',
                accion: 'Armar partido',
                onAccion: _armarPartido,
              ),
              itemBuilder: (_, i) {
                final p = _mios[i];
                return PartidoCard(partido: p, rol: _rol(p, miId), onTap: () => _abrirDetalle(p));
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _rol(Partido p, String? miId) {
    if (miId == null) return null;
    if (p.creador.id == miId) return 'Organizás';
    final solicitud = p.solicitudDe(miId);
    if (solicitud == null) return null;
    return solicitud.estado == 'ACEPTADA' ? 'Confirmado' : 'Solicitud enviada';
  }

  Widget _filtros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder(), isDense: true),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...categorias.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (v) {
                setState(() => _categoria = v);
                _cargar();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String?>(
              initialValue: _rama,
              decoration: const InputDecoration(labelText: 'Rama', border: OutlineInputBorder(), isDense: true),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...ramas.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (v) {
                setState(() => _rama = v);
                _cargar();
              },
            ),
          ),
        ],
      ),
    );
  }
}
