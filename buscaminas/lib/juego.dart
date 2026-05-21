import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tablero.dart';
import 'preferencias_usuario.dart';

class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  _JuegoScreenState createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  Board? _board;
  late int _rows, _cols, _mines;
  bool _started = false;
  bool _gameOver = false;
  bool _victory = false;
  bool _nuevoRecord = false;
  Timer? _timer;
  int _seconds = 0;
  int _attempts = 0;

  int get _flagsUsed {
    if (_board == null) return 0;
    return _board!.grid.expand((row) => row).where((cell) => cell.flagged).length;
  }

  int get _minasRestantes => max(0, _mines - _flagsUsed);

  @override
  void initState() {
    super.initState();
  }

  void _startBoardFromPreferences(PreferenciasUsuario prefs) {
    switch (prefs.dificultad) {
      case 'medio':
        _rows = 8; _cols = 8; _mines = 20; break;
      case 'dificil':
        _rows = 10; _cols = 10; _mines = 30; break;
      default:
        _rows = 6; _cols = 6; _mines = 10; break;
    }
    _board = Board(rows: _rows, cols: _cols, minesCount: _mines);
    _started = false;
    _gameOver = false;
    _victory = false;
    _nuevoRecord = false;
    _seconds = 0;
    _attempts = 0;
    _timer?.cancel();
  }

  void _onCellTap(int r, int c) {
    if (_gameOver || _victory) return;
    final prefs = Provider.of<PreferenciasUsuario>(context, listen: false);
    if (_board == null) _startBoardFromPreferences(prefs);
    final cell = _board!.grid[r][c];
    if (!cell.revealed && !cell.flagged) {
      _attempts++;
    }
    final mineHit = _board!.reveal(r, c);
    if (!_started) _startTimer();
    setState(() {
      _started = true;
    });
    if (mineHit) {
      _timer?.cancel();
      _board!.revealAllMines();
      setState(() {
        _gameOver = true;
      });
    } else if (_board!.checkVictory()) {
      _timer?.cancel();
      final newRecord = prefs.saveHighScore(
        prefs.dificultad,
        ScoreEntry(seconds: _seconds, attempts: _attempts, date: DateTime.now()),
      );
      setState(() {
        _victory = true;
      });
      newRecord.then((isRecord) {
        if (!mounted) return;
        setState(() {
          _nuevoRecord = isRecord;
        });
        if (isRecord) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Nuevo récord para ${prefs.dificultad}!')),
          );
        }
      });
    } else {
      setState(() {});
    }
  }

  void _onCellLongPress(int r, int c) {
    if (_gameOver || _victory) return;
    if (_board == null) return;
    setState(() {
      _board!.toggleFlag(r, c);
    });
  }

  String _traducirDificultad(String dif) {
    switch (dif) {
      case 'facil':
        return 'Fácil (6x6)';
      case 'medio':
        return 'Medio (8x8)';
      case 'dificil':
        return 'Difícil (10x10)';
      default:
        return 'Fácil';
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferenciasUsuario>(context);
    if (_board == null || _board!.rows != _rows) {
      _startBoardFromPreferences(prefs);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Buscaminas - Juego'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('Tiempo: $_seconds s')),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Minas: $_mines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('Minas restantes: $_minasRestantes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('Intentos: $_attempts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = min(constraints.maxWidth, constraints.maxHeight);
                    final cellSize = size / (_rows > _cols ? _rows : _cols);
                    final brightness = Theme.of(context).brightness;
                    return Center(
                      child: Container(
                        width: cellSize * _cols,
                        height: cellSize * _rows,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _cols,
                          ),
                          itemCount: _rows * _cols,
                          itemBuilder: (context, index) {
                            final r = index ~/ _cols;
                            final c = index % _cols;
                            final cell = _board!.grid[r][c];
                            return GestureDetector(
                              onTap: () => _onCellTap(r, c),
                              onLongPress: () => _onCellLongPress(r, c),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: prefs.animacionesActivadas ? 250 : 0),
                                margin: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: _getCellColor(cell, brightness),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: cell.revealed ? Colors.black54 : Colors.black87,
                                    width: cell.revealed ? 1.2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: prefs.animacionesActivadas ? 200 : 0),
                                    child: _buildCellContent(cell, prefs),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
          if (_gameOver || _victory) _buildEndOverlay(prefs),
        ],
      ),
    );
  }

  Widget _buildCellContent(cell, PreferenciasUsuario prefs) {
    if (cell.revealed) {
      if (cell.hasMine) return Icon(Icons.warning, color: Colors.red, key: ValueKey('mine_${cell.row}_${cell.col}'));
      if (cell.adjacentMines > 0) {
        return Text(
          '${cell.adjacentMines}',
          key: ValueKey('num_${cell.row}_${cell.col}'),
          style: _numberTextStyle(cell.adjacentMines, prefs),
        );
      }
      return SizedBox.shrink(key: ValueKey('empty_${cell.row}_${cell.col}'));
    } else {
      if (cell.flagged) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, color: Colors.redAccent, size: 20, key: ValueKey('flag_${cell.row}_${cell.col}')),
          ],
        );
      }
      return SizedBox.shrink(key: ValueKey('closed_${cell.row}_${cell.col}'));
    }
  }

  Color _getCellColor(Cell cell, Brightness brightness) {
    if (cell.revealed) {
      return brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!;
    }
    return brightness == Brightness.dark ? Colors.blueGrey[700]! : Colors.blue[200]!;
  }

  TextStyle _numberTextStyle(int number, PreferenciasUsuario prefs) {
    final color = _colorForNumber(number, prefs);
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: color,
      fontFamily: prefs.estiloNumeros == 'retro' ? 'monospace' : null,
      shadows: prefs.estiloNumeros == 'retro'
          ? [Shadow(color: Colors.black26, offset: Offset(1, 1))]
          : null,
    );
  }

  Color _colorForNumber(int number, PreferenciasUsuario prefs) {
    switch (prefs.estiloNumeros) {
      case 'colorido':
        return [Colors.cyan, Colors.lime, Colors.pink, Colors.orange, Colors.purple, Colors.teal, Colors.indigo, Colors.amber][number - 1];
      case 'retro':
        return [Colors.yellow.shade700, Colors.green.shade700, Colors.red.shade700, Colors.blue.shade700, Colors.brown.shade700, Colors.teal.shade700, Colors.grey.shade800, Colors.black][number - 1];
      case 'minimalista':
        return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
      default:
        return [Colors.blue, Colors.green, Colors.red, Colors.indigo, Colors.brown, Colors.teal, Colors.black, Colors.grey][number - 1];
    }
  }

  Widget _buildEndOverlay(PreferenciasUsuario prefs) {
    final title = _victory ? '¡Ganaste!' : 'Perdiste';
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  if (_victory) ...[
                    Text('¡Has completado el tablero!', style: TextStyle(fontSize: 16)),
                    if (_nuevoRecord) ...[
                      SizedBox(height: 8),
                      Text('¡Nuevo récord!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ] else ...[
                    Text('Chocaste con una mina. Intenta de nuevo.', style: TextStyle(fontSize: 16)),
                  ],
                  SizedBox(height: 16),
                  Text('Dificultad: ${_traducirDificultad(prefs.dificultad)}'),
                  Text('Tiempo: $_seconds s'),
                  Text('Intentos: $_attempts'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_victory)
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _victory = false;
                          }),
                          child: Text('Continuar'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          final prefs = Provider.of<PreferenciasUsuario>(context, listen: false);
                          setState(() {
                            _startBoardFromPreferences(prefs);
                          });
                        },
                        child: Text(_victory ? 'Reintentar' : 'Reintentar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/menu'),
                        child: Text('Salir'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
