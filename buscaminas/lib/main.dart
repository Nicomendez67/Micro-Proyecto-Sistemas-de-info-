import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'menu_principal.dart';
import 'preferencias_usuario.dart';
import 'juego.dart';
import 'configuracion.dart';
import 'marcadores.dart';
import 'instrucciones.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final preferencias = PreferenciasUsuario(prefs);
  runApp(MyApp(preferencias: preferencias));
}

class MyApp extends StatelessWidget {
  final PreferenciasUsuario preferencias;

  const MyApp({super.key, required this.preferencias});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => preferencias,
      child: Consumer<PreferenciasUsuario>(
        builder: (context, prefs, _) {
          return MaterialApp(
            title: 'Buscaminas Flutter',
            theme: _buildAppTheme(Brightness.light),
            darkTheme: _buildAppTheme(Brightness.dark),
            themeMode: prefs.temaActual == TemaType.oscuro
                ? ThemeMode.dark
                : prefs.temaActual == TemaType.claro
                    ? ThemeMode.light
                    : ThemeMode.system,
            home: SplashScreen(),
            routes: {
              '/menu': (context) => MenuPrincipal(),
              '/configuracion': (context) => ConfiguracionScreen(),
              '/marcadores': (context) => MarcadoresScreen(),
              '/instrucciones': (context) => InstruccionesScreen(),
              '/juego': (context) => JuegoScreen(),
            },
          );
        },
      ),
    );
  }

  ThemeData _buildAppTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
    final primary = brightness == Brightness.dark ? Colors.tealAccent : Colors.blueAccent;
    final onPrimary = brightness == Brightness.dark ? Colors.black : Colors.white;

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: brightness == Brightness.dark ? Colors.orangeAccent : Colors.deepPurpleAccent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.85);
            }
            return primary;
          }),
          foregroundColor: WidgetStateProperty.all(onPrimary),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return onPrimary.withValues(alpha: 0.12);
            }
            return null;
          }),
          elevation: WidgetStateProperty.all(6),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 16, horizontal: 28)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.8);
            }
            return primary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.08);
            }
            return null;
          }),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 14, horizontal: 22)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          textStyle: WidgetStateProperty.all(TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.8);
            }
            return primary;
          }),
          side: WidgetStateProperty.all(BorderSide(color: primary, width: 2)),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.08);
            }
            return null;
          }),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 14, horizontal: 22)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          textStyle: WidgetStateProperty.all(TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
      ),
    );
  }
}

// Placeholders para otras pantallas (las desarrollarás después)
class ConfiguracionPlaceholder extends StatelessWidget {
  const ConfiguracionPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración')),
      body: Center(child: Text('Pantalla de Configuración - En desarrollo')),
    );
  }
}
class MarcadoresPlaceholder extends StatelessWidget {
  const MarcadoresPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Marcadores')),
      body: Center(child: Text('Pantalla de Marcadores - En desarrollo')),
    );
  }
}
class InstruccionesPlaceholder extends StatelessWidget {
  const InstruccionesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Instrucciones')),
      body: Center(child: Text('Pantalla de Instrucciones - En desarrollo')),
    );
  }
}
class JuegoPlaceholder extends StatelessWidget {
  const JuegoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Juego')),
      body: Center(child: Text('Tablero de Buscaminas - En desarrollo')),
    );
  }
}