part of 'helpers.dart';

void CalculandoAlerta(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Espere por favor'),
      content: Text('Calculando ruta'),
    ),
  );
}