import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/complejo.dart';
import '../services/turno_service.dart';
import '../utils/errores.dart';
import 'turnos_screen.dart';
import 'mis_reservas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TurnoService _turnoService = TurnoService();
  List<Complejo> _complejos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComplejos();
  }

  Future<void> _loadComplejos() async {
    try {
      final complejos = await _turnoService.getComplejos();
      if (mounted) setState(() => _complejos = complejos);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complejos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisReservasScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _complejos.isEmpty
              ? const Center(child: Text('No hay complejos disponibles'))
              : RefreshIndicator(
                  onRefresh: _loadComplejos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _complejos.length,
                    itemBuilder: (context, index) {
                      final complejo = _complejos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.sports_tennis, color: Color(0xFF1565C0)),
                          ),
                          title: Text(complejo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(complejo.direccion),
                              Text(complejo.telefono, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TurnosScreen(complejo: complejo),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}