import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'preferencias_usuario.dart';

class MenuPrincipal extends StatelessWidget {
  // Colores retro para los botones
  static const Map<String, Color> coloresBotones = {
    'Jugar': Color(0xFF4CAF50),
    'Marcadores': Color(0xFF2196F3),
    'Configuración': Color(0xFFFF9800),
    'Instrucciones': Color(0xFF9C27B0),
    'Créditos': Color(0xFFF44336),
  };

  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferenciasUsuario>(context);
    // Usamos el tema actual para el fondo (claro/oscuro)
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Fondo temático estilo "pixel art" / bloques / cielo
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: esModoOscuro
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [Colors.blue[200]!, Colors.lightGreen[100]!],
          ),
          // Patrón de cuadrícula (opcional, simula bloques)
          image: DecorationImage(
            image: _crearPatronCuadricula(context),
            repeat: ImageRepeat.repeat,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título con animación bounce
                      BounceInDown(
                        duration: Duration(milliseconds: 800),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [Colors.yellow, Colors.orange],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'BUSCAMINAS',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(offset: Offset(4, 4), color: Colors.black54),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 60),
                      // Lista de botones con animación de entrada escalonada
                      ...['Jugar', 'Marcadores', 'Configuración', 'Instrucciones'].asMap().entries.map((entry) {
                        int index = entry.key;
                        String titulo = entry.value;
                        return FadeInUp(
                          delay: Duration(milliseconds: 400 + (index * 100)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            child: _BotonMenu(
                              titulo: titulo,
                              color: coloresBotones[titulo]!,
                              onPressed: () => _onBotonPresionado(context, titulo, prefs),
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 30),
                      // Indicador de dificultad actual (pequeño)
                      Text(
                        'Dificultad: ${_traducirDificultad(prefs.dificultad)}',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: SizedBox(
                  width: 120,
                  height: 38,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: coloresBotones['Créditos']!.withValues(alpha: 0.95),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _mostrarCreditos(context),
                    child: Text('Créditos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Función para crear un patrón de cuadrícula
  ImageProvider _crearPatronCuadricula(BuildContext context) {
    return AssetImage('assets/pattern.png');
  }

  // Placeholder: función de navegación según botón
  void _onBotonPresionado(BuildContext context, String titulo, PreferenciasUsuario prefs) {
    // Efecto de sonido opcional (si está activado)
    if (prefs.sonidosActivados) {
      // Aquí llamarías a un paquete de sonidos (ej. audioplayers)
      // print('Sonido de clic');
    }

    switch (titulo) {
      case 'Jugar':
        Navigator.pushNamed(context, '/juego');
        break;
      case 'Marcadores':
        Navigator.pushNamed(context, '/marcadores');
        break;
      case 'Configuración':
        Navigator.pushNamed(context, '/configuracion');
        break;
      case 'Instrucciones':
        Navigator.pushNamed(context, '/instrucciones');
        break;
      case 'Créditos':
        _mostrarCreditos(context);
        break;
    }
  }

  void _mostrarCreditos(BuildContext context) {
    showDialog(
      context: context,
        builder: (_) => AlertDialog(
          title: Text('Créditos'),
          content: Text('Edgar Torres\nNicolas Mendez'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar')),
        ],
      ),
    );
  }

  String _traducirDificultad(String dif) {
    switch (dif) {
      case 'facil': return 'Fácil (6x6)';
      case 'medio': return 'Medio (8x8)';
      case 'dificil': return 'Difícil (10x10)';
      default: return 'Fácil';
    }
  }
}

// Botón personalizado con animación de presión (escala y cambio de color)
class _BotonMenu extends StatefulWidget {
  final String titulo;
  final Color color;
  final VoidCallback onPressed;

  const _BotonMenu({
    required this.titulo,
    required this.color,
    required this.onPressed,
  });

  @override
  __BotonMenuState createState() => __BotonMenuState();
}

class __BotonMenuState extends State<_BotonMenu> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
    _animation.addListener(() {
      setState(() {
        _scale = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 300),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
          ),
          child: Center(
            child: Text(
              widget.titulo,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
