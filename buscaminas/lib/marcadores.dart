import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'preferencias_usuario.dart';

class MarcadoresScreen extends StatefulWidget {
  const MarcadoresScreen({super.key});

  @override
  _MarcadoresScreenState createState() => _MarcadoresScreenState();
}

class _MarcadoresScreenState extends State<MarcadoresScreen> {
  String _dificultadSeleccionada = 'facil';
  final Map<String, String> _dificultades = {
    'facil': 'Fácil',
    'medio': 'Medio',
    'dificil': 'Difícil',
  };

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferenciasUsuario>(context);
    final scores = prefs.getHighScores(_dificultadSeleccionada);

    return Scaffold(
      appBar: AppBar(
        title: Text('Marcadores'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            tooltip: 'Borrar todos los marcadores',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Borrar marcadores'),
                  content: Text('¿Seguro que quieres borrar todos los marcadores?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Borrar')),
                  ],
                ),
              );
              if (confirm == true) {
                await prefs.clearAllHighScores();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _dificultades.entries.map((entry) {
                final selected = entry.key == _dificultadSeleccionada;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected ? Theme.of(context).colorScheme.primary : Colors.grey,
                      ),
                      onPressed: () => setState(() {
                        _dificultadSeleccionada = entry.key;
                      }),
                      child: Text(entry.value),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          if (scores.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Aún no tienes registros para ${_dificultades[_dificultadSeleccionada]}. ¡Juega tu primera partida!',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: scores.length,
                separatorBuilder: (_, _) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final score = scores[index];
                  final rank = index + 1;
                  final medals = [Icons.emoji_events, Icons.emoji_events, Icons.emoji_events];
                  final medalColors = [Colors.amber, Colors.grey, Colors.brown];
                  return Container(
                    decoration: BoxDecoration(
                      color: index.isEven ? Theme.of(context).cardColor : Theme.of(context).cardColor.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: index == 0 ? Colors.amber : index == 1 ? Colors.grey : index == 2 ? Colors.brown : Colors.blueGrey,
                          child: Text('$rank', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (rank <= 3) ...[
                                    Icon(medals[rank - 1], size: 16, color: medalColors[rank - 1]),
                                    SizedBox(width: 6),
                                  ],
                                  Text(
                                    '${score.seconds}s • ${score.attempts} intentos',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text('Fecha: ${score.date.toLocal().toString().split(' ').first}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
