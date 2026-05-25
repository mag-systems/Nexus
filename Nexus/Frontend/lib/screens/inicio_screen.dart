import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/user_role.dart';
import 'login_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Paleta monocromática azul corporativo · Nexus Track
// ──────────────────────────────────────────────────────────────────────────────
class NexusBlue {
  NexusBlue._();

  /// Azul medianoche – títulos y textos principales
  static const midnight = Color(0xFF0D1B3E);

  /// Azul naval / acero oscuro – botones primarios
  static const navy = Color(0xFF1A3A6B);

  /// Azul corporativo vibrante – acento activo
  static const steel = Color(0xFF1D5FA8);

  /// Azul medio – iconos y subtítulos
  static const medium = Color(0xFF2D7DD2);

  /// Azul hielo / gris-azulado – bordes y acentos suaves
  static const ice = Color(0xFFD6E4F7);

  /// Blanco puro – fondo
  static const white = Colors.white;

  /// Gris azulado claro – texto secundario
  static const textSecondary = Color(0xFF5B7499);

  /// Sombra muy suave
  static const shadow = Color(0x14143050);
}

// ──────────────────────────────────────────────────────────────────────────────
/// [InicioScreen] – Pantalla de bienvenida minimalista de Nexus Track.
///
/// Rutas de salida:
///   · "Soy Alumno"       → [LoginScreen] con rol [UserRole.alumno]
///   · "Soy Socio Nexus"  → [LoginScreen] con rol [UserRole.socioNexus]
// ──────────────────────────────────────────────────────────────────────────────
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen>
    with TickerProviderStateMixin {
  // ── Animaciones de entrada ────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _contentCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Navegación ────────────────────────────────────────────────────────────
  void _navegarALogin(UserRole role) {
    Navigator.push(
      context,
      _fadeSlideRoute(LoginScreen(role: role)),
    );
  }

  static PageRouteBuilder<void> _fadeSlideRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, _, child) {
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
      transitionDuration: const Duration(milliseconds: 380),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: NexusBlue.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.09),

                  // ── Logo ────────────────────────────────────────────────
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const _LogoSection(),
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // ── Tagline ─────────────────────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          _buildTagline(),
                          SizedBox(height: size.height * 0.07),

                          // ── Etiqueta de selección ───────────────────────
                          _buildSelectLabel(),
                          const SizedBox(height: 20),

                          // ── Botón Alumno ────────────────────────────────
                          _NexusRoleButton(
                            label: 'Soy Alumno',
                            description: 'Accede con tu cuenta estudiantil',
                            icon: Icons.school_outlined,
                            isPrimary: true,
                            onPressed: () => _navegarALogin(UserRole.alumno),
                          ),
                          const SizedBox(height: 16),

                          // ── Botón Socio Nexus ───────────────────────────
                          _NexusRoleButton(
                            label: 'Soy Socio Nexus',
                            description: 'Panel de gestión para socios',
                            icon: Icons.business_center_outlined,
                            isPrimary: false,
                            onPressed: () => _navegarALogin(UserRole.socioNexus),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.07),

                  // ── Footer ──────────────────────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: _buildFooter(),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Column(
      children: [
        const Text(
          'Movilidad estudiantil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: NexusBlue.textSecondary,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'verificada y segura.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: NexusBlue.textSecondary,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectLabel() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: NexusBlue.ice,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Selecciona tu rol',
            style: TextStyle(
              fontSize: 12,
              color: NexusBlue.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: NexusBlue.ice,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: NexusBlue.ice, thickness: 1),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: NexusBlue.steel,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Nexus Track · v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: NexusBlue.textSecondary,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Sección del logo: ícono + wordmark Nexus Track.
// ─────────────────────────────────────────────────────────────────────────────
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Ícono ──────────────────────────────────────────────────────────
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: NexusBlue.navy,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: NexusBlue.shadow,
                blurRadius: 24,
                offset: Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.route_rounded,
              size: 46,
              color: NexusBlue.white,
            ),
          ),
        ),
        const SizedBox(height: 22),

        // ── Wordmark ────────────────────────────────────────────────────────
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Nexus',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: NexusBlue.midnight,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              TextSpan(
                text: ' Track',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w300,
                  color: NexusBlue.steel,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Línea acento ────────────────────────────────────────────────────
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: NexusBlue.medium,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Botón de selección de rol con animación de prensa.
// ─────────────────────────────────────────────────────────────────────────────
class _NexusRoleButton extends StatefulWidget {
  const _NexusRoleButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  State<_NexusRoleButton> createState() => _NexusRoleButtonState();
}

class _NexusRoleButtonState extends State<_NexusRoleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    final bgColor = widget.isPrimary ? NexusBlue.navy : NexusBlue.white;
    final textColor = widget.isPrimary ? NexusBlue.white : NexusBlue.midnight;
    final descColor = widget.isPrimary
        ? NexusBlue.white.withValues(alpha: 0.65)
        : NexusBlue.textSecondary;
    final iconColor = widget.isPrimary ? NexusBlue.white : NexusBlue.steel;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPrimary ? Colors.transparent : NexusBlue.ice,
              width: 1.5,
            ),
            boxShadow: widget.isPrimary
                ? const [
                    BoxShadow(
                      color: Color(0x281A3A6B),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: NexusBlue.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 3),
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isPrimary
                      ? NexusBlue.white.withValues(alpha: 0.12)
                      : NexusBlue.ice,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: descColor,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: widget.isPrimary
                    ? NexusBlue.white.withValues(alpha: 0.6)
                    : NexusBlue.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
