import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/socio_nexus.dart';
import '../services/api_service.dart';
import 'inicio_screen.dart' show NexusBlue;

// ──────────────────────────────────────────────────────────────────────────────
/// [SocioNexusDashboard] — Dashboard para Socios Nexus.
///
/// Muestra nombre del perfil, foto descargada de la BD, calificación con
/// estrellas, y una lista de viajes disponibles obtenida de GET /rutas/.
///
/// Diseño minimalista corporativo en paleta azul.
// ──────────────────────────────────────────────────────────────────────────────
class SocioNexusDashboard extends StatefulWidget {
  const SocioNexusDashboard({super.key, this.perfil});

  /// Perfil del socio. Si es null, se usa datos genéricos.
  final SocioNexus? perfil;

  @override
  State<SocioNexusDashboard> createState() => _SocioNexusDashboardState();
}

class _SocioNexusDashboardState extends State<SocioNexusDashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _fade;

  List<Map<String, dynamic>> _viajes = [];
  bool _cargandoViajes = true;

  String get _nombre =>
      widget.perfil?.nombreCompleto ?? 'Socio Nexus';
  String? get _fotoPerfil => widget.perfil?.fotoPerfil;
  double get _calificacion => widget.perfil?.calificacion ?? 5.0;
  String? get _modeloCarro => widget.perfil?.modeloCarro;
  String? get _placas => widget.perfil?.placas;

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
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _cargarViajes();
  }

  Future<void> _cargarViajes() async {
    try {
      final rutas = await ApiService.obtenerRutas();
      if (!mounted) return;
      setState(() {
        _viajes = rutas.cast<Map<String, dynamic>>();
        _cargandoViajes = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargandoViajes = false);
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusBlue.white,
      appBar: AppBar(
        backgroundColor: NexusBlue.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: Container(
            margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: NexusBlue.white,
              border: Border.all(color: NexusBlue.ice, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: NexusBlue.midnight,
            ),
          ),
        ),
        title: const Text(
          'Panel Nexus',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: NexusBlue.midnight,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: NexusBlue.navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.business_center_outlined,
                size: 18, color: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: NexusBlue.ice),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Saludo con foto de perfil ────────────────────────────────
              _buildGreeting(),
              const SizedBox(height: 28),

              // ── KPI Cards ───────────────────────────────────────────────
              _buildSectionTitle('Resumen del día'),
              const SizedBox(height: 14),
              _buildKpiRow(),
              const SizedBox(height: 28),

              // ── Viajes disponibles ──────────────────────────────────────
              _buildSectionTitle('Viajes disponibles'),
              const SizedBox(height: 14),
              _buildViajesDisponibles(),
              const SizedBox(height: 28),

              // ── Acciones rápidas ────────────────────────────────────────
              _buildSectionTitle('Acciones rápidas'),
              const SizedBox(height: 14),
              _buildQuickActions(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: NexusBlue.navy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A1A3A6B),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ── Foto de perfil ──────────────────────────────────────────
              _buildProfileAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buenos días,',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$_nombre 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 14),
          // ── Calificación + info del vehículo ──────────────────────────
          Row(
            children: [
              _buildRatingBadge(),
              const SizedBox(width: 14),
              if (_modeloCarro != null && _placas != null)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car_outlined,
                          size: 14, color: Colors.white54),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '$_modeloCarro · $_placas',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: NexusBlue.steel,
        backgroundImage:
            _fotoPerfil != null ? NetworkImage(_fotoPerfil!) : null,
        child: _fotoPerfil == null
            ? const Icon(Icons.person, size: 26, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
          const SizedBox(width: 4),
          Text(
            _calificacion.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: NexusBlue.steel,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: NexusBlue.midnight,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            value: _viajes.length.toString(),
            label: 'Viajes activos',
            icon: Icons.route_rounded,
            accentColor: NexusBlue.steel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            value: '${_calificacion.toStringAsFixed(1)} ⭐',
            label: 'Calificación',
            icon: Icons.star_outline_rounded,
            accentColor: const Color(0xFF1D7AB8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            value: _viajes.fold<int>(
                    0, (sum, v) => sum + ((v['lugares_disponibles'] ?? 0) as int))
                .toString(),
            label: 'Lugares disp.',
            icon: Icons.event_seat_outlined,
            accentColor: NexusBlue.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildViajesDisponibles() {
    if (_cargandoViajes) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(NexusBlue.steel),
            ),
          ),
        ),
      );
    }

    if (_viajes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: NexusBlue.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NexusBlue.ice, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.route_outlined,
              size: 36,
              color: NexusBlue.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 10),
            const Text(
              'No hay viajes disponibles',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NexusBlue.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Los viajes aparecerán aquí cuando estén activos.',
              style: TextStyle(
                fontSize: 12,
                color: NexusBlue.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _viajes.map((viaje) => _buildViajeTile(viaje)).toList(),
    );
  }

  Widget _buildViajeTile(Map<String, dynamic> viaje) {
    final origen = viaje['origen'] as String? ?? '—';
    final destino = viaje['destino'] as String? ?? '—';
    final conductor = viaje['conductor'] as String? ?? '—';
    final lugares = viaje['lugares_disponibles'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexusBlue.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexusBlue.ice, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A143050),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Ícono de ruta ──────────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: NexusBlue.steel.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.route_rounded,
              size: 22,
              color: NexusBlue.steel,
            ),
          ),
          const SizedBox(width: 14),
          // ── Info ───────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$origen → $destino',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NexusBlue.midnight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 13, color: NexusBlue.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      conductor,
                      style: const TextStyle(
                        fontSize: 11,
                        color: NexusBlue.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Lugares disponibles badge ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: lugares > 0
                  ? NexusBlue.steel.withValues(alpha: 0.1)
                  : const Color(0xFFFDEDED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_seat_outlined,
                  size: 13,
                  color:
                      lugares > 0 ? NexusBlue.steel : const Color(0xFFB33A3A),
                ),
                const SizedBox(width: 4),
                Text(
                  '$lugares',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: lugares > 0
                        ? NexusBlue.steel
                        : const Color(0xFFB33A3A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.person_add_outlined,
                label: 'Registrar Alumno',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.qr_code_outlined,
                label: 'Generar QR',
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.bar_chart_rounded,
                label: 'Reportes',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Tarjeta KPI pequeña.
// ─────────────────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexusBlue.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexusBlue.ice, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A143050),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: NexusBlue.midnight,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: NexusBlue.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Tile de acción rápida.
// ─────────────────────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: NexusBlue.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NexusBlue.ice, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A143050),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: NexusBlue.steel),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NexusBlue.midnight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
