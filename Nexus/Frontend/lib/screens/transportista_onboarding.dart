import 'package:flutter/material.dart';
import '../models/transportista.dart';
import '../services/api_service.dart';
import 'transportista_dashboard.dart';

/// [TransportistaOnboarding] — Formulario de registro para transportistas.
///
/// Recopila: Nombre Completo, Modelo del Vehículo y Placas.
/// Envía un POST a /perfiles/ con tipo_usuario: "transportista".

class TransportistaOnboarding extends StatefulWidget {
  const TransportistaOnboarding({super.key});

  @override
  State<TransportistaOnboarding> createState() =>
      _TransportistaOnboardingState();
}

class _TransportistaOnboardingState extends State<TransportistaOnboarding>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _placasCtrl = TextEditingController();

  bool _enviando = false;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Colores de la paleta Nexus 
  static const _purple = Color(0xFF6C5CE7);
  static const _teal = Color(0xFF00CEC9);
  static const _dark = Color(0xFF1A1A2E);
  static const _darkCard = Color(0xFF16213E);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nombreCtrl.dispose();
    _modeloCtrl.dispose();
    _placasCtrl.dispose();
    super.dispose();
  }

  // ── envio del formulario ─────────────────────────────────────────────────
  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    final transportista = Transportista(
      nombreCompleto: _nombreCtrl.text.trim(),
      modeloVehiculo: _modeloCtrl.text.trim(),
      placas: _placasCtrl.text.trim().toUpperCase(),
    );

    try {
      final respuesta =
          await ApiService.crearPerfilTransportista(transportista);

      if (!mounted) return;

      final perfilCreado = Transportista.fromJson(respuesta);

      // Navegar al dashboard reemplazando la pila de navegación.
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TransportistaDashboard(transportista: perfilCreado),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 450),
        ),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _mostrarError(e.message);
    } catch (e) {
      if (!mounted) return;
      _mostrarError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── UI ───
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_dark, Color(0xFF0F3460), _darkCard],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Back + Encabezado ──
                    _buildHeader(context),
                    const SizedBox(height: 36),

                    // ── Formulario ──
                    _buildFormCard(),

                    const SizedBox(height: 32),

                    // ── Botón de envío ──
                    _buildSubmitButton(),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bottun regresar
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12),
          ),
          color: Colors.white,
        ),
        const SizedBox(height: 24),

       
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_teal, Color(0xFF008C8A)],
            ),
            boxShadow: [
              BoxShadow(
                color: _teal.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        
        const Text(
          'Registro de\nTransportista',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Completa tus datos para empezar a recibir viajes.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _darkCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Nombre Completo
            _NexusTextField(
              controller: _nombreCtrl,
              label: 'Nombre Completo',
              hint: 'Juan Pérez López',
              icon: Icons.person_rounded,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa tu nombre completo';
                }
                if (v.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Modelo del Vehículo
            _NexusTextField(
              controller: _modeloCtrl,
              label: 'Modelo del Vehículo',
              hint: 'Toyota Corolla 2024',
              icon: Icons.directions_car_rounded,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa el modelo del vehículo';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Placas
            _NexusTextField(
              controller: _placasCtrl,
              label: 'Placas',
              hint: 'ABC-123-D',
              icon: Icons.confirmation_number_rounded,
              textCapitalization: TextCapitalization.characters,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa las placas del vehículo';
                }
                if (v.trim().length < 5) {
                  return 'Las placas deben tener al menos 5 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _enviando
              ? LinearGradient(
                  colors: [
                    _purple.withValues(alpha: 0.5),
                    const Color(0xFF4A3ABF).withValues(alpha: 0.5),
                  ],
                )
              : const LinearGradient(
                  colors: [_purple, Color(0xFF4A3ABF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: _enviando
              ? []
              : [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _enviando ? null : _enviarFormulario,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            disabledBackgroundColor: Colors.transparent,
          ),
          child: _enviando
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'Registrarme',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


class _NexusTextField extends StatelessWidget {
  const _NexusTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF00CEC9);
    const purple = Color(0xFF6C5CE7);

    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.2),
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: teal, size: 22),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
    );
  }
}
