import 'package:intl/intl.dart';

const Map<String, String> categorias = {
  'PRIMERA': '1ra',
  'SEGUNDA': '2da',
  'TERCERA': '3ra',
  'CUARTA': '4ta',
  'QUINTA': '5ta',
  'SEXTA': '6ta',
  'SEPTIMA': '7ma',
  'OCTAVA': '8va',
};

const Map<String, String> ramas = {
  'MASCULINO': 'Masculino',
  'FEMENINO': 'Femenino',
  'MIXTO': 'Mixto',
};

const Map<String, String> generos = {
  'MASCULINO': 'Masculino',
  'FEMENINO': 'Femenino',
};

String etiquetaCategoria(String? valor) => categorias[valor] ?? '-';
String etiquetaRama(String? valor) => ramas[valor] ?? '-';

String etiquetaEstado(String estado) {
  final texto = estado.replaceAll('_', ' ').toLowerCase();
  return texto[0].toUpperCase() + texto.substring(1);
}

// Las fechas del backend llegan en UTC: se muestran en la hora del celular
DateTime fechaLocal(dynamic valor) => DateTime.parse(valor as String).toLocal();

String formatoDia(DateTime fecha) => DateFormat("EEEE d/M", 'es').format(fecha);
String formatoDiaCorto(DateTime fecha) => DateFormat("EEE d/M", 'es').format(fecha);
String formatoHora(DateTime fecha) => DateFormat('HH:mm').format(fecha);
String formatoDiaHora(DateTime fecha) => '${formatoDiaCorto(fecha)} · ${formatoHora(fecha)}';
String formatoPrecio(double precio) => '\$${NumberFormat.decimalPattern('es').format(precio)}';

double precioDe(dynamic valor) => double.parse(valor.toString());
