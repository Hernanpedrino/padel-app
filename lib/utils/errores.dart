import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../services/api_client.dart';

bool esErrorDeConexion(Object error) =>
    error is SinConexionException ||
    error is TimeoutException ||
    error is SocketException ||
    error is http.ClientException;

String mensajeDeError(Object error) {
  if (error is String) return error;
  if (error is ApiException) return error.mensaje;
  if (esErrorDeConexion(error)) return SinConexionException().toString();
  return 'Ocurrió un error. Intentá de nuevo.';
}

// Muestra un error de red, del backend o inesperado sin dejar la pantalla trabada
void mostrarError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensajeDeError(error)), backgroundColor: Colors.red),
  );
}

void mostrarOk(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
  );
}
