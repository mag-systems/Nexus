import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/user_role.dart';
import 'alumno_dashboard.dart';
import 'socio_nexus_dashboard.dart';
import 'socio_nexus_onboarding.dart';
import 'transportista_onboarding.dart';
import 'inicio_screen.dart' show NexusBlue;

// ──────────────────────────────────────────────────────────────────────────────
/// [LoginScreen] — Formulario de login minimalista para cada rol.
///
/// · No realiza validación de credenciales real.
/// · Al presionar "Entrar" navega al dashboard correspondiente.
/// · Botón secundario "¿Nuevo? Regístrate aquí" lleva al Onboarding.
// ──────────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePass = true;
  bool _loading = false;

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // ── Meta por rol ──────────────────────────────────────────────────────────
  String get _roleLabel =>
      widget.role == UserRole.alumno ? 'Alumno' : 'Socio Nexus';

  IconData get _roleIcon => widget.role == UserRole.alumno
      ? Icons.school_outlined
      : Icons.business_center_outlined;

  String get _emailHint => widget.role == UserRole.alumno
      ? 'correo@universidad.edu.mx'
      : 'socio@nexustrack.mx';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Lógica simulada de login ──────────────────────────────────────────────
  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    // Simula latencia de red (600 ms)
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _loading = false);

    final Widget dashboard = widget.role == UserRole.alumno
        ? const AlumnoDashboard()
        : const SocioNexusDashboard();

    Navigator.pushReplacement(
      context,
      _fadeSlideRoute(dashboard),
    );
  }

  void _irAOnboarding() {
    final Widget onboarding = widget.role == UserRole.socioNexus
        ? const SocioNexusOnboarding()
        : const TransportistaOnboarding();

    Navigator.push(
      context,
      _fadeSlideRoute(onboarding),
    );
  }

  static PageRouteBuilder<void> _fadeSlideRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (ctx, animation, _) => page,
      transitionsBuilder: (ctx, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.06),

                      // ── Back & badge de rol ─────────────────────────────
                      Row(
                        children: [
                          _BackButton(),
                          const Spacer(),
                          _RoleBadge(label: _roleLabel, icon: _roleIcon),
                        ],
                      ),

                      SizedBox(height: size.height * 0.05),

                      // ── Encabezado ─────────────────────────────────────
                      _buildHeader(),

                      SizedBox(height: size.height * 0.05),

                      // ── Campo correo ───────────────────────────────────
                      _buildLabel('Correo institucional'),
                      const SizedBox(height: 8),
                      _NexusTextField(
                        controller: _emailCtrl,
                        hintText: _emailHint,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),

                      const SizedBox(height: 20),

                      // ── Campo contraseña ───────────────────────────────
                      _buildLabel('Contraseña'),
                      const SizedBox(height: 8),
                      _NexusTextField(
                        controller: _passCtrl,
                        hintText: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePass,
                        autofillHints: const [AutofillHints.password],
                        suffix: GestureDetector(
                          onTap: () => setState(() => _obscurePass = !_obscurePass),
                          child: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: NexusBlue.textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── ¿Olvidaste tu contraseña? ──────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {},
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              fontSize: 13,
                              color: NexusBlue.medium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.045),

                      // ── Botón Entrar ───────────────────────────────────
                      _EntrarButton(loading: _loading, onPressed: _entrar),

                      const SizedBox(height: 24),

                      // ── Separador ──────────────────────────────────────
                      _buildDivider(),
                      const SizedBox(height: 24),

                      // ── Botón Registro / Onboarding ────────────────────
                      _RegisterButton(onPressed: _irAOnboarding),

                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido,',
          style: TextStyle(
            fontSize: 13,
            color: NexusBlue.textSecondary,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Inicia sesión',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: NexusBlue.midnight,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: NexusBlue.steel,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: NexusBlue.midnight,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: NexusBlue.ice, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '¿Primera vez?',
            style: TextStyle(
              fontSize: 12,
              color: NexusBlue.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const Expanded(child: Divider(color: NexusBlue.ice, thickness: 1)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Campo de texto estilo Nexus.
// ─────────────────────────────────────────────────────────────────────────────
class _NexusTextField extends StatefulWidget {
  const _NexusTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final Iterable<String>? autofillHints;

  @override
  State<_NexusTextField> createState() => _NexusTextFieldState();
}

class _NexusTextFieldState extends State<_NexusTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? NexusBlue.steel : NexusBlue.ice,
          width: _focused ? 1.5 : 1.0,
        ),
        color: _focused
            ? const Color(0xFFF4F8FE)
            : const Color(0xFFFAFCFF),
        boxShadow: _focused
            ? const [
                BoxShadow(
                  color: Color(0x141D5FA8),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          style: const TextStyle(
            fontSize: 15,
            color: NexusBlue.midnight,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: NexusBlue.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              widget.icon,
              size: 20,
              color: _focused ? NexusBlue.steel : NexusBlue.textSecondary,
            ),
            suffixIcon: widget.suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffix,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: false,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Botón principal de login con estado de carga.
// ─────────────────────────────────────────────────────────────────────────────
class _EntrarButton extends StatelessWidget {
  const _EntrarButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: NexusBlue.navy,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x301A3A6B),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: loading ? null : onPressed,
            splashColor: NexusBlue.white.withValues(alpha: 0.08),
            highlightColor: NexusBlue.white.withValues(alpha: 0.04),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: NexusBlue.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: NexusBlue.white,
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

// ─────────────────────────────────────────────────────────────────────────────
/// Botón de registro secundario minimalista.
// ─────────────────────────────────────────────────────────────────────────────
class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: NexusBlue.ice, width: 1.5),
          backgroundColor: NexusBlue.white,
          foregroundColor: NexusBlue.midnight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '¿Nuevo? ',
                style: TextStyle(
                  fontSize: 14,
                  color: NexusBlue.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Regístrate aquí',
                style: TextStyle(
                  fontSize: 14,
                  color: NexusBlue.steel,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: NexusBlue.steel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Badge de rol en la esquina superior derecha del login.
// ─────────────────────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: NexusBlue.ice,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: NexusBlue.steel),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: NexusBlue.navy,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Botón de regreso con estilo limpio.
// ─────────────────────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: NexusBlue.white,
          border: Border.all(color: NexusBlue.ice, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: NexusBlue.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: NexusBlue.midnight,
        ),
      ),
    );
  }
}
