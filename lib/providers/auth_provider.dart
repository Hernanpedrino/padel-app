import 'package:flutter/material.dart';
import '../models/perfil.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/push_service.dart';
import '../services/usuario_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UsuarioService _usuarioService = UsuarioService();
  bool _isLoggedIn = false;
  bool _loading = true;
  Perfil? _perfil;

  bool get isLoggedIn => _isLoggedIn;
  bool get loading => _loading;
  // Se carga después del login; las pantallas lo usan para saber quién es el usuario
  Perfil? get perfil => _perfil;

  AuthProvider() {
    // Si el backend responde 401 (token vencido) se vuelve al login
    ApiClient.onNoAutorizado = () {
      if (_isLoggedIn) logout();
    };
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isLoggedIn = await _authService.isLoggedIn();
    _loading = false;
    notifyListeners();
    if (_isLoggedIn) recargarPerfil();
  }

  Future<void> recargarPerfil() async {
    try {
      _perfil = await _usuarioService.getPerfil();
      notifyListeners();
    } catch (_) {
      // Sin conexión: el perfil se vuelve a pedir al refrescar la pantalla de inicio
    }
  }

  void actualizarPerfil(Perfil perfil) {
    _perfil = perfil;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final success = await _authService.login(email, password);
    if (success) {
      _isLoggedIn = true;
      notifyListeners();
      recargarPerfil();
    }
    return success;
  }

  Future<void> logout() async {
    if (_isLoggedIn) {
      // Primero se marca la salida: si la baja del celular responde 401 no se vuelve a entrar acá
      _isLoggedIn = false;
      await PushService().darDeBaja();
    }
    await _authService.logout();
    _perfil = null;
    notifyListeners();
  }

  void setLoggedIn() {
    _isLoggedIn = true;
    notifyListeners();
    recargarPerfil();
  }
}
