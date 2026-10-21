import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';

bool esErrorDeConexion(Object error) =>
    error is SinConexionException ||
    error is TimeoutException ||
    error is SocketException ||
    error is http.ClientException;

// Muestra un error de red o inesperado sin dejar la pantalla trabada
void mostrarError(BuildContext context, Object error) {
  final mensaje = esErrorDeConexion(error)
      ? SinConexionException().toString()
      : 'Ocurrió un error. Intentá de nuevo.';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
  );
}
