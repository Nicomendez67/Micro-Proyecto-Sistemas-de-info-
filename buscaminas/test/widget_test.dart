// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buscaminas_proyecto/preferencias_usuario.dart';

import 'package:buscaminas_proyecto/main.dart';

void main() {
  testWidgets('App loads with preferences', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'tema': 'automatico',
      'dificultad': 'facil',
      'sonidos': true,
      'animaciones': true,
      'estiloNumeros': 'clasico',
    });
    final prefs = await SharedPreferences.getInstance();
    final preferencias = PreferenciasUsuario(prefs);

    await tester.pumpWidget(MaterialApp(home: MyApp(preferencias: preferencias)));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
