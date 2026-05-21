import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TemaType { claro, oscuro, automatico }

class ScoreEntry {
  final int seconds;
  final int attempts;
  final DateTime date;

  ScoreEntry({required this.seconds, required this.attempts, required this.date});

  Map<String, dynamic> toJson() => {
        'seconds': seconds,
        'attempts': attempts,
        'date': date.toIso8601String(),
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        seconds: json['seconds'] as int,
        attempts: json['attempts'] as int,
        date: DateTime.parse(json['date'] as String),
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ScoreEntry &&
            other.seconds == seconds &&
            other.attempts == attempts &&
            other.date == date;
  }

  @override
  int get hashCode => seconds.hashCode ^ attempts.hashCode ^ date.hashCode;
}

class PreferenciasUsuario extends ChangeNotifier {
  final SharedPreferences _prefs;
  TemaType _temaActual;
  String _dificultad; // 'facil', 'medio', 'dificil'
  bool _sonidosActivados;
  bool _animacionesActivadas;
  String _estiloNumeros; // 'clasico', 'colorido', 'retro', 'minimalista'

  PreferenciasUsuario(this._prefs)
      : _temaActual = TemaType.values.firstWhere(
          (e) => e.name == _prefs.getString('tema'),
          orElse: () => TemaType.automatico,
        ),
        _dificultad = _prefs.getString('dificultad') ?? 'facil',
        _sonidosActivados = _prefs.getBool('sonidos') ?? true,
        _animacionesActivadas = _prefs.getBool('animaciones') ?? true,
        _estiloNumeros = _prefs.getString('estiloNumeros') ?? 'clasico';

  TemaType get temaActual => _temaActual;
  String get dificultad => _dificultad;
  bool get sonidosActivados => _sonidosActivados;
  bool get animacionesActivadas => _animacionesActivadas;
  String get estiloNumeros => _estiloNumeros;

  void setTema(TemaType nuevoTema) async {
    _temaActual = nuevoTema;
    await _prefs.setString('tema', nuevoTema.name);
    notifyListeners();
  }

  void setDificultad(String nueva) async {
    _dificultad = nueva;
    await _prefs.setString('dificultad', nueva);
    notifyListeners();
  }

  void setSonidos(bool valor) async {
    _sonidosActivados = valor;
    await _prefs.setBool('sonidos', valor);
    notifyListeners();
  }

  void setAnimaciones(bool valor) async {
    _animacionesActivadas = valor;
    await _prefs.setBool('animaciones', valor);
    notifyListeners();
  }

  void setEstiloNumeros(String estilo) async {
    _estiloNumeros = estilo;
    await _prefs.setString('estiloNumeros', estilo);
    notifyListeners();
  }

  List<ScoreEntry> getHighScores(String dificultad) {
    final raw = _prefs.getString('scores_$dificultad');
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    final scores = decoded
        .map((item) => ScoreEntry.fromJson(item as Map<String, dynamic>))
        .toList();
    scores.sort((a, b) {
      final byTime = a.seconds.compareTo(b.seconds);
      if (byTime != 0) return byTime;
      return a.attempts.compareTo(b.attempts);
    });
    return scores;
  }

  Future<bool> saveHighScore(String dificultad, ScoreEntry entry) async {
    final scores = getHighScores(dificultad);
    scores.add(entry);
    scores.sort((a, b) {
      final byTime = a.seconds.compareTo(b.seconds);
      if (byTime != 0) return byTime;
      return a.attempts.compareTo(b.attempts);
    });
    final trimmed = scores.length > 5 ? scores.sublist(0, 5) : scores;
    await _prefs.setString('scores_$dificultad', jsonEncode(trimmed.map((e) => e.toJson()).toList()));
    notifyListeners();
    return trimmed.isNotEmpty && trimmed.first == entry;
  }

  Future<void> clearHighScores(String dificultad) async {
    await _prefs.remove('scores_$dificultad');
    notifyListeners();
  }

  Future<void> clearAllHighScores() async {
    for (final nivel in ['facil', 'medio', 'dificil']) {
      await _prefs.remove('scores_$nivel');
    }
    notifyListeners();
  }
}