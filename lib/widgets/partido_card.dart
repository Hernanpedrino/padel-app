import 'package:flutter/material.dart';
import '../models/partido.dart';
import '../utils/formato.dart';
import 'comunes.dart';

class PartidoCard extends StatelessWidget {
  final Partido partido;
  final VoidCallback onTap;
  // Estado del usuario en este partido (Organizás, Pendiente, Confirmado); null en la búsqueda
  final String? rol;
  const PartidoCard({super.key, required this.partido, required this.onTap, this.rol});

  @override
  Widget build(BuildContext context) {
    final p = partido;
    final buscados = p.cuposLibres == 1 ? 'Se busca 1 jugador' : 'Se buscan ${p.cuposLibres} jugadores';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const IconoCaja(Icons.groups),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.estado == 'ABIERTO' ? '$buscados de ${etiquetaCategoria(p.categoria)}' : 'Partido de ${etiquetaCategoria(p.categoria)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${etiquetaRama(p.rama)} · organiza ${p.creador.nombre}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${formatoDia(p.turno.fechaHoraInicio)} · ${formatoHora(p.turno.fechaHoraInicio)}',
                        style: const TextStyle(fontSize: 13)),
                    Text('${p.complejoNombre} · ${p.turno.cancha.nombre}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  EstadoChip(p.estado),
                  if (rol != null) ...[
                    const SizedBox(height: 6),
                    Text(rol!, style: const TextStyle(fontSize: 12, color: colorPrimario)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
