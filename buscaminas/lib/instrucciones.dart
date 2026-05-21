import 'package:flutter/material.dart';

class InstruccionesScreen extends StatelessWidget {
  const InstruccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cómo jugar'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Objetivo', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 12),
            Text(
              'Descubre todas las casillas seguras sin pulsar una mina. Usa los números para deducir dónde están las minas y revela el tablero completo.',
              style: textStyle,
            ),
            SizedBox(height: 24),
            Text('Cómo jugar', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 12),
            _buildStep(
              icon: Icons.touch_app,
              title: 'Toca una casilla',
              description: 'Toca una casilla para revelarla. Si destapas una mina, pierdes la partida.',
            ),
            _buildStep(
              icon: Icons.confirmation_number,
              title: 'Lee el número',
              description: 'El número en una casilla indica cuántas minas hay en las casillas adyacentes.',
            ),
            _buildStep(
              icon: Icons.flag,
              title: 'Marca las minas',
              description: 'Mantén pulsada una casilla para colocar o quitar una bandera. Usa banderas para contar las minas restantes y evitar errores.',
            ),
            _buildStep(
              icon: Icons.check_circle,
              title: 'Revela espacio seguro',
              description: 'Si una casilla no tiene minas adyacentes, se revelará automáticamente una zona amplia de casillas seguras.',
            ),
            SizedBox(height: 24),
            Text('Dificultades', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 12),
            _buildDifficulty('Fácil', '6×6 con 10 minas.'),
            _buildDifficulty('Medio', '8×8 con 20 minas.'),
            _buildDifficulty('Difícil', '10×10 con 30 minas.'),
            SizedBox(height: 24),
            Text('Consejos', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 12),
            _buildTip('Empieza por las esquinas y los bordes, donde hay menos casillas adyacentes.'),
            _buildTip('Usa banderas sólo cuando estés seguro de la posición de una mina.'),
            _buildTip('Si quedas atascado, revisa los números cercanos y el balance de minas restantes.'),
            SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Volver al menú', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.blueAccent),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 15, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficulty(String title, String details) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star_border, size: 24, color: Colors.amber),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(details, style: TextStyle(fontSize: 15, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, size: 22, color: Colors.green),
          SizedBox(width: 12),
          Expanded(child: Text(tip, style: TextStyle(fontSize: 15, height: 1.4))),
        ],
      ),
    );
  }
}
