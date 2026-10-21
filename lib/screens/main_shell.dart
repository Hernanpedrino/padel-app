import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notificacion.dart';
import '../providers/notificaciones_provider.dart';
import '../utils/navegacion.dart';
import 'complejos_screen.dart';
import 'inicio_screen.dart';
import 'partidos_screen.dart';
import 'perfil_screen.dart';

// Pantalla principal después del login: barra inferior con las cuatro secciones
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int inicio = 0;
  static const int perfil = 3;

  int _indice = inicio;
  final _inicioKey = GlobalKey<InicioScreenState>();
  late final NotificacionesProvider _notificaciones;

  @override
  void initState() {
    super.initState();
    // Mientras la app está abierta se consultan las notificaciones y se avisa de las nuevas
    _notificaciones = context.read<NotificacionesProvider>()
      ..onNueva = _avisar
      ..iniciar();
  }

  @override
  void dispose() {
    // Al cerrar sesión se deja de consultar
    _notificaciones
      ..onNueva = null
      ..detener();
    super.dispose();
  }

  void _avisar(Notificacion n) {
    if (!mounted) return;
    final destino = pantallaDeAviso(n.tipo, n.refId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(n.cuerpo, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        action: destino == null
            ? null
            : SnackBarAction(label: 'VER', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino))),
      ),
    );
    // Novedades de Inicio también cambian (ej. partido confirmado)
    _inicioKey.currentState?.cargar();
  }

  void _irA(int indice) {
    setState(() => _indice = indice);
    // Al volver a Inicio se refrescan novedades y favoritos (pueden haber cambiado en otra sección)
    if (indice == inicio) _inicioKey.currentState?.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: [
          InicioScreen(key: _inicioKey, onIrA: _irA, indicePerfil: perfil),
          const PartidosScreen(),
          const ComplejosScreen(),
          const PerfilScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _irA,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Partidos'),
          NavigationDestination(icon: Icon(Icons.sports_tennis_outlined), selectedIcon: Icon(Icons.sports_tennis), label: 'Reservar'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
