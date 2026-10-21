import 'package:flutter/material.dart';
import '../utils/formato.dart';

const Color colorPrimario = Color(0xFF1565C0);

// Ícono dentro de un recuadro celeste, como en las tarjetas de complejos y turnos
class IconoCaja extends StatelessWidget {
  final IconData icono;
  final Color color;
  const IconoCaja(this.icono, {super.key, this.color = colorPrimario});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icono, color: color),
    );
  }
}

class EstadoChip extends StatelessWidget {
  final String estado;
  const EstadoChip(this.estado, {super.key});

  static const _colores = {
    'PENDIENTE': Colors.orange,
    'CONFIRMADA': Colors.green,
    'ACEPTADA': Colors.green,
    'ABIERTO': colorPrimario,
    'COMPLETO': Colors.green,
    'RECHAZADA': Colors.red,
    'CANCELADA': Colors.grey,
    'CANCELADO': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colores[estado] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(etiquetaEstado(estado), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// Estado vacío de una lista, con una acción opcional
class Vacio extends StatelessWidget {
  final IconData icono;
  final String texto;
  final String? accion;
  final VoidCallback? onAccion;
  const Vacio({super.key, required this.icono, required this.texto, this.accion, this.onAccion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          if (accion != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAccion, child: Text(accion!)),
          ],
        ],
      ),
    );
  }
}

class TituloSeccion extends StatelessWidget {
  final String texto;
  final Widget? accion;
  const TituloSeccion(this.texto, {super.key, this.accion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
      child: Row(
        children: [
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ?accion,
        ],
      ),
    );
  }
}

// AppBar con los colores de la app
AppBar barraApp(String titulo, {List<Widget>? acciones, PreferredSizeWidget? bottom}) {
  return AppBar(
    title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: colorPrimario,
    foregroundColor: Colors.white,
    actions: acciones,
    bottom: bottom,
  );
}

// Lista refrescable que muestra un spinner mientras carga y un estado vacío si no hay ítems
class ListaRefrescable extends StatelessWidget {
  final bool cargando;
  final int cantidad;
  final Widget vacio;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext, int) itemBuilder;
  const ListaRefrescable({
    super.key,
    required this.cargando,
    required this.cantidad,
    required this.vacio,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: cantidad == 0
          ? ListView(children: [vacio])
          : ListView.builder(padding: const EdgeInsets.all(16), itemCount: cantidad, itemBuilder: itemBuilder),
    );
  }
}
