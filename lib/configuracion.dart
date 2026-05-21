import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'preferencias_usuario.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferenciasUsuario>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajustes de juego', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dificultad', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...['facil', 'medio', 'dificil'].map((value) {
                      return RadioListTile<String>(
                        title: Text(_traducirDificultad(value)),
                        value: value,
                        groupValue: prefs.dificultad,
                        onChanged: (value) {
                          if (value != null) prefs.setDificultad(value);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Ajustes visuales', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile<TemaType>(
                      title: Text('Claro'),
                      value: TemaType.claro,
                      groupValue: prefs.temaActual,
                      onChanged: (value) {
                        if (value != null) prefs.setTema(value);
                      },
                    ),
                    RadioListTile<TemaType>(
                      title: Text('Oscuro'),
                      value: TemaType.oscuro,
                      groupValue: prefs.temaActual,
                      onChanged: (value) {
                        if (value != null) prefs.setTema(value);
                      },
                    ),
                    RadioListTile<TemaType>(
                      title: Text('Automático'),
                      value: TemaType.automatico,
                      groupValue: prefs.temaActual,
                      onChanged: (value) {
                        if (value != null) prefs.setTema(value);
                      },
                    ),
                    Divider(height: 32),
                    Text('Estilo de números', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...['clasico', 'colorido', 'retro', 'minimalista'].map((style) {
                      return RadioListTile<String>(
                        title: Text(_traducirEstiloNumeros(style)),
                        value: style,
                        groupValue: prefs.estiloNumeros,
                        onChanged: (value) {
                          if (value != null) prefs.setEstiloNumeros(value);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Preferencias adicionales', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Efectos de sonido'),
                    subtitle: Text('Activa o desactiva los efectos de botón y juego.'),
                    value: prefs.sonidosActivados,
                    onChanged: (value) => prefs.setSonidos(value),
                  ),
                  Divider(height: 0),
                  SwitchListTile(
                    title: Text('Animaciones'),
                    subtitle: Text('Activa animaciones suaves en menús y tablero.'),
                    value: prefs.animacionesActivadas,
                    onChanged: (value) => prefs.setAnimaciones(value),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                'Los cambios se guardan automáticamente.',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _traducirDificultad(String dif) {
    switch (dif) {
      case 'medio':
        return 'Medio (8x8, 20 minas)';
      case 'dificil':
        return 'Difícil (10x10, 30 minas)';
      default:
        return 'Fácil (6x6, 10 minas)';
    }
  }

  String _traducirEstiloNumeros(String estilo) {
    switch (estilo) {
      case 'colorido':
        return 'Colorido';
      case 'retro':
        return 'Retro';
      case 'minimalista':
        return 'Minimalista';
      default:
        return 'Clásico';
    }
  }
}
