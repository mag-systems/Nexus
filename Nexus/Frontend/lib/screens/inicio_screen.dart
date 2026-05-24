import 'package:flutter/material.dart';

import 'alumno_dashboard.dart';
import 'transportista_onboarding.dart';

class _NexusColors {
  static const blueCool = Color(0xFF0984E3);
  static const blueCoolLight = Color(0xFF74B9FF);
  static const teal = Color(0xFF00CEC9);
  static const dark = Color(0xFF1A1A2E);
  static const darkCard = Color(0xFF16213E);
  static const white = Colors.white;
}


/// [InicioScreen] — Pantalla de bienvenida de la app Nexus Track.
/// [AlumnoDashboard]
/// [TransportistaOnboarding]

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen>
    with TickerProviderStateMixin {
  
  late final AnimationController _heroCtrl;
  late final AnimationController _buttonsCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _buttonsFade;
  late final Animation<Offset> _buttonsSlide;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    // Botones: entran desde abajo con pequeño delay
    _buttonsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonsFade = CurvedAnimation(parent: _buttonsCtrl, curve: Curves.easeOut);
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _buttonsCtrl, curve: Curves.easeOutCubic));


    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );


    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _buttonsCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _buttonsCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }


  void _irAlumnoDashboard() {
    Navigator.push(
      context,
      _buildPageRoute(const AlumnoDashboard()),
    );
  }

  void _irTransportistaOnboarding() {
    Navigator.push(
      context,
      _buildPageRoute(const TransportistaOnboarding()),
    );
  }


  PageRouteBuilder<void> _buildPageRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
   
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _NexusColors.dark,
              Color(0xFF0F3460),
              _NexusColors.darkCard,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.10),

                   
                    FadeTransition(
                      opacity: _heroFade,
                      child: SlideTransition(
                        position: _heroSlide,
                        child: Column(
                          children: [
                            // Orbe de fondo 
                            _buildLogoOrb(),
                            const SizedBox(height: 32),

                            // title principal
                            _buildTitle(),
                            const SizedBox(height: 12),

                            
                            _buildTagline(),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.08),

                    // ── Seccipn Botones ───────────────────────────────────────
                    FadeTransition(
                      opacity: _buttonsFade,
                      child: SlideTransition(
                        position: _buttonsSlide,
                        child: Column(
                          children: [
                            // Chip de selección de rol
                            _buildRoleLabel(),
                            const SizedBox(height: 20),

                            // Botón principal: Alumno
                            _buildAlumnoButton(),
                            const SizedBox(height: 16),

                            // Separador "o"
                            _buildDivider(),
                            const SizedBox(height: 16),

                            // Botón secundario: Transportista
                            _buildTransportistaButton(),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    
                    FadeTransition(
                      opacity: _buttonsFade,
                      child: _buildFooter(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Widgets auxiliares
  // ─────────────────────────────────────────────────────────────────────────

  /// Orbe circular con gradiente y el ícono de la app pulsando.
  Widget _buildLogoOrb() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFF74B9FF),
              _NexusColors.blueCool,
              Color(0xFF095292),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: _NexusColors.blueCool.withValues(alpha: 0.55),
              blurRadius: 40,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: _NexusColors.teal.withValues(alpha: 0.20),
              blurRadius: 60,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.directions_bus_rounded,
          size: 64,
          color: _NexusColors.white,
        ),
      ),
    );
  }

  /// Título "Nexus Track" con gradiente de texto.
  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [_NexusColors.white, _NexusColors.blueCoolLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        'Nexus Track',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          color: _NexusColors.white, // ShaderMask lo sobreescribe
          letterSpacing: -0.5,
          height: 1.1,
        ),
      ),
    );
  }

  /// Tagline descriptivo bajo el título.
  Widget _buildTagline() {
    return Text(
      'Movilidad estudiantil inteligente\nen tu universidad',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: _NexusColors.white.withValues(alpha: 0.65),
        height: 1.5,
        letterSpacing: 0.2,
      ),
    );
  }

  /// Pequeño chip que invita a elegir un rol.
  Widget _buildRoleLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: _NexusColors.teal.withValues(alpha: 0.5),
        ),
        color: _NexusColors.teal.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded,
              size: 15, color: _NexusColors.teal.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            '¿Cuál es tu rol?',
            style: TextStyle(
              fontSize: 13,
              color: _NexusColors.teal.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Botón principal con gradiente para el rol Alumno.
  Widget _buildAlumnoButton() {
    return _NexusButton(
      label: 'Soy Alumno',
      icon: Icons.school_rounded,
      gradient: const LinearGradient(
        colors: [_NexusColors.blueCool, Color(0xFF0564AF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      glowColor: _NexusColors.blueCool,
      onPressed: _irAlumnoDashboard,
    );
  }

  /// Separador con texto "o" en medio.
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: _NexusColors.white.withValues(alpha: 0.12),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'o',
            style: TextStyle(
              color: _NexusColors.white.withValues(alpha: 0.35),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: _NexusColors.white.withValues(alpha: 0.12),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// Botón secundario con gradiente teal para el rol Transportista.
  Widget _buildTransportistaButton() {
    return _NexusButton(
      label: 'Soy Transportista',
      icon: Icons.local_shipping_rounded,
      gradient: const LinearGradient(
        colors: [_NexusColors.teal, Color(0xFF008C8A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      glowColor: _NexusColors.teal,
      onPressed: _irTransportistaOnboarding,
    );
  }

  /// Pie de página con versión y branding.
  Widget _buildFooter() {
    return Column(
      children: [
        Divider(
          color: _NexusColors.white.withValues(alpha: 0.08),
          thickness: 1,
        ),
        const SizedBox(height: 12),
        Text(
          'Nexus Track · v1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: _NexusColors.white.withValues(alpha: 0.25),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Widget reutilizable para los botones de rol de la pantalla de inicio.
///
/// Muestra un [ElevatedButton] estilizado con gradiente, ícono, sombra
/// de color (glow) y animación de escala al presionar.
// ─────────────────────────────────────────────────────────────────────────────
class _NexusButton extends StatefulWidget {
  const _NexusButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color glowColor;
  final VoidCallback onPressed;

  @override
  State<_NexusButton> createState() => _NexusButtonState();
}

class _NexusButtonState extends State<_NexusButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            // El fondo real lo pone el Container con gradiente
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: _NexusColors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: _NexusColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
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
