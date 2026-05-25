import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/socio_nexus.dart';
import '../services/api_service.dart';
import 'inicio_screen.dart' show NexusBlue;
import 'socio_nexus_dashboard.dart';

// ──────────────────────────────────────────────────────────────────────────────
/// [SocioNexusOnboarding] — Formulario de registro para Socios Nexus.
///
/// Recopila: Nombre, Correo, Password, Modelo del Vehículo, Placas.
/// Permite subir foto de perfil y foto del vehículo vía image_picker.
/// Envía un POST multipart a /perfiles/.
// ──────────────────────────────────────────────────────────────────────────────
class SocioNexusOnboarding extends StatefulWidget {
  const SocioNexusOnboarding({super.key});

  @override
  State<SocioNexusOnboarding> createState() => _SocioNexusOnboardingState();
}

class _SocioNexusOnboardingState extends State<SocioNexusOnboarding>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _placasCtrl = TextEditingController();

  bool _enviando = false;
  bool _obscurePass = true;

  File? _fotoPerfil;
  File? _fotoCarro;

  final ImagePicker _picker = ImagePicker();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    _modeloCtrl.dispose();
    _placasCtrl.dispose();
    super.dispose();
  }

  // ── Seleccionar imagen ────────────────────────────────────────────────────
  Future<void> _seleccionarImagen({required bool esPerfil}) async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (imagen != null) {
      setState(() {
        if (esPerfil) {
          _fotoPerfil = File(imagen.path);
        } else {
          _fotoCarro = File(imagen.path);
        }
      });
    }
  }

  // ── Envío del formulario ──────────────────────────────────────────────────
  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fotoPerfil == null) {
      _mostrarError('Por favor sube tu foto de perfil.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _enviando = true);

    try {
      final respuesta = await ApiService.crearPerfilSocioNexus(
        nombreCompleto: _nombreCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        password: _passwordCtrl.text,
        modeloCarro: _modeloCtrl.text.trim(),
        placas: _placasCtrl.text.trim().toUpperCase(),
        fotoPerfil: _fotoPerfil!,
        fotoCarro: _fotoCarro,
      );

      if (!mounted) return;

      final perfilCreado = SocioNexus.fromJson(respuesta);

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, _) =>
              SocioNexusDashboard(perfil: perfilCreado),
          transitionsBuilder: (context, animation, _, child) {
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
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFB33A3A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: NexusBlue.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.03),

                    // ── Back + Badge ───────────────────────────────────────
                    _buildTopBar(),
                    const SizedBox(height: 28),

                    // ── Encabezado ─────────────────────────────────────────
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // ── Fotos ──────────────────────────────────────────────
                    _buildPhotoSection(),
                    const SizedBox(height: 28),

                    // ── Campos de texto ────────────────────────────────────
                    _buildLabel('Nombre Completo'),
                    const SizedBox(height: 8),
                    _OnboardingTextField(
                      controller: _nombreCtrl,
                      hintText: 'Juan Pérez López',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu nombre completo';
                        }
                        if (v.trim().length < 3) {
                          return 'Mínimo 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Correo electrónico'),
                    const SizedBox(height: 8),
                    _OnboardingTextField(
                      controller: _correoCtrl,
                      hintText: 'socio@nexustrack.mx',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu correo';
                        }
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Contraseña'),
                    const SizedBox(height: 8),
                    _OnboardingTextField(
                      controller: _passwordCtrl,
                      hintText: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePass,
                      suffix: GestureDetector(
                        onTap: () =>
                            setState(() => _obscurePass = !_obscurePass),
                        child: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: NexusBlue.textSecondary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (v.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Modelo del Vehículo'),
                    const SizedBox(height: 8),
                    _OnboardingTextField(
                      controller: _modeloCtrl,
                      hintText: 'Toyota Corolla 2024',
                      icon: Icons.directions_car_outlined,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa el modelo del vehículo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Placas'),
                    const SizedBox(height: 8),
                    _OnboardingTextField(
                      controller: _placasCtrl,
                      hintText: 'ABC-123-D',
                      icon: Icons.confirmation_number_outlined,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa las placas del vehículo';
                        }
                        if (v.trim().length < 5) {
                          return 'Mínimo 5 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 36),

                    // ── Botón de envío ─────────────────────────────────────
                    _buildSubmitButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      children: [
        // Back button
        GestureDetector(
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
        ),
        const Spacer(),
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: NexusBlue.ice,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.business_center_outlined,
                  size: 14, color: NexusBlue.steel),
              SizedBox(width: 6),
              Text(
                'Socio Nexus',
                style: TextStyle(
                  fontSize: 12,
                  color: NexusBlue.navy,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crea tu cuenta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: NexusBlue.midnight,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Completa tus datos para empezar a recibir viajes.',
          style: TextStyle(
            fontSize: 14,
            color: NexusBlue.textSecondary,
            fontWeight: FontWeight.w400,
            height: 1.5,
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

  Widget _buildPhotoSection() {
    return Row(
      children: [
        // ── Foto de perfil ────────────────────────────────────────────────
        Expanded(
          child: _ImagePickerTile(
            label: 'Foto de Perfil',
            icon: Icons.account_circle_outlined,
            file: _fotoPerfil,
            isCircle: true,
            onTap: () => _seleccionarImagen(esPerfil: true),
          ),
        ),
        const SizedBox(width: 14),
        // ── Foto del vehículo ─────────────────────────────────────────────
        Expanded(
          child: _ImagePickerTile(
            label: 'Foto del Vehículo',
            icon: Icons.directions_car_outlined,
            file: _fotoCarro,
            isCircle: false,
            onTap: () => _seleccionarImagen(esPerfil: false),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _enviando
              ? NexusBlue.navy.withValues(alpha: 0.6)
              : NexusBlue.navy,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _enviando
              ? []
              : const [
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
            onTap: _enviando ? null : _enviarFormulario,
            splashColor: NexusBlue.white.withValues(alpha: 0.08),
            highlightColor: NexusBlue.white.withValues(alpha: 0.04),
            child: Center(
              child: _enviando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Completar Registro',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
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

// ─────────────────────────────────────────────────────────────────────────────
/// Tile para seleccionar imagen con preview.
// ─────────────────────────────────────────────────────────────────────────────
class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.label,
    required this.icon,
    required this.file,
    required this.isCircle,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final File? file;
  final bool isCircle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NexusBlue.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null ? NexusBlue.steel : NexusBlue.ice,
            width: file != null ? 1.5 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: NexusBlue.shadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Preview o placeholder
            if (file != null)
              isCircle
                  ? CircleAvatar(
                      radius: 38,
                      backgroundImage: FileImage(file!),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        file!,
                        width: double.infinity,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
                    )
            else
              Container(
                width: isCircle ? 76 : double.infinity,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FE),
                  borderRadius:
                      isCircle ? null : BorderRadius.circular(10),
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  border: Border.all(
                    color: NexusBlue.ice,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 28,
                      color: NexusBlue.medium,
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 14,
                      color: NexusBlue.textSecondary.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Text(
              file != null ? '✓ $label' : label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: file != null ? NexusBlue.steel : NexusBlue.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              file != null ? 'Toca para cambiar' : 'Subir desde galería',
              style: TextStyle(
                fontSize: 10,
                color: NexusBlue.textSecondary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Campo de texto estilo onboarding Nexus (fondo blanco, borde azul hielo).
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingTextField extends StatefulWidget {
  const _OnboardingTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  State<_OnboardingTextField> createState() => _OnboardingTextFieldState();
}

class _OnboardingTextFieldState extends State<_OnboardingTextField> {
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
        color: _focused ? const Color(0xFFF4F8FE) : const Color(0xFFFAFCFF),
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
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
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
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: false,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
            errorStyle: const TextStyle(
              color: Color(0xFFB33A3A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}
