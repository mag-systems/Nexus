import 'dart:math';
import 'package:flutter/material.dart';
import '../models/transportista.dart';
import '../models/alumno_solicitud.dart';

// Paleta compartida
const _purple = Color(0xFF6C5CE7);
const _teal = Color(0xFF00CEC9);
const _dark = Color(0xFF1A1A2E);
const _darkCard = Color(0xFF16213E);

// Drawer del Transportista

class TransportistaDrawer extends StatelessWidget {
  final Transportista transportista;

  const TransportistaDrawer({super.key, required this.transportista});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_purple, Color(0xFF4A3ABF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, size: 42, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(
                  transportista.nombreCompleto,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TRANSPORTISTA',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerInfoTile(icon: Icons.directions_car_rounded, label: 'Vehículo', value: transportista.modeloVehiculo),
          _DrawerInfoTile(icon: Icons.confirmation_number_rounded, label: 'Placas', value: transportista.placas),
          const _DrawerInfoTile(icon: Icons.star_rounded, label: 'Calificación', value: '4.9 ★', valueColor: Color(0xFFFFD700)),
          const _DrawerInfoTile(icon: Icons.route_rounded, label: 'Viajes realizados', value: '127'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Cerrar Sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DrawerInfoTile({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: _purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.confirmation_number_rounded, size: 20, color: _teal),
      ),
      title: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}


// Mapa Simulado

class SimulatedMap extends StatelessWidget {
  final Transportista transportista;

  const SimulatedMap({super.key, required this.transportista});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            CustomPaint(size: const Size(double.infinity, double.infinity), painter: _MapPainter()),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _darkCard,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: _purple.withValues(alpha: 0.3), blurRadius: 12)],
                      border: Border.all(color: _purple.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      transportista.nombreCompleto,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [_purple, _teal], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: _purple.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
                  ),
                  Transform.translate(
                    offset: const Offset(0, 2),
                    child: Container(
                      width: 28,
                      height: 6,
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _MapControlButton(icon: Icons.add, onTap: () {}),
                  const SizedBox(height: 6),
                  _MapControlButton(icon: Icons.remove, onTap: () {}),
                  const SizedBox(height: 6),
                  _MapControlButton(icon: Icons.my_location, onTap: () {}),
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _darkCard.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed, size: 16, color: _teal),
                    SizedBox(width: 8),
                    Text('Tu ubicación actual', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF0D1117), Color(0xFF161B22), Color(0xFF0D1117)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()..color = const Color(0xFF1F2937)..strokeWidth = 0.5;
    const gridSpacing = 30.0;
    for (double x = 0; x < size.width; x += gridSpacing) canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    for (double y = 0; y < size.height; y += gridSpacing) canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

    final streetPaint = Paint()..color = const Color(0xFF2D3748)..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    for (final y in [size.height * 0.25, size.height * 0.5, size.height * 0.75]) canvas.drawLine(Offset(0, y), Offset(size.width, y), streetPaint);
    for (final x in [size.width * 0.2, size.width * 0.5, size.width * 0.8]) canvas.drawLine(Offset(x, 0), Offset(x, size.height), streetPaint);

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.7), Paint()..color = const Color(0xFF374151)..strokeWidth = 5.0..strokeCap = StrokeCap.round);

    final random = Random(42);
    final blockPaint = Paint()..color = const Color(0xFF1A1F2E);
    for (int i = 0; i < 12; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(random.nextDouble() * size.width * 0.8 + size.width * 0.05, random.nextDouble() * size.height * 0.8 + size.height * 0.05, 20.0 + random.nextDouble() * 40, 20.0 + random.nextDouble() * 30), const Radius.circular(4)), blockPaint);
    }

    final poiColors = [const Color(0xFF6C5CE7), const Color(0xFF00CEC9), const Color(0xFFE17055), const Color(0xFFFDCB6E)];
    for (int i = 0; i < 6; i++) {
      final x = random.nextDouble() * size.width * 0.7 + size.width * 0.15;
      final y = random.nextDouble() * size.height * 0.7 + size.height * 0.15;
      final color = poiColors[i % poiColors.length];
      canvas.drawCircle(Offset(x, y), 8, Paint()..color = color.withValues(alpha: 0.15));
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color.withValues(alpha: 0.7));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
        ),
        child: Icon(icon, size: 18, color: Colors.white70),
      ),
    );
  }
}


// Panel de Solicitudes y Tarjeta

class RequestPanel extends StatelessWidget {
  final List<AlumnoSolicitud> solicitudes;
  final Function(AlumnoSolicitud) onAceptar;
  final Function(AlumnoSolicitud) onRechazar;

  const RequestPanel({
    super.key,
    required this.solicitudes,
    required this.onAceptar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _darkCard.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.groups_rounded, color: _teal, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Alumnos Disponibles', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _purple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text('${solicitudes.length}', style: const TextStyle(color: _purple, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ],
            ),
          ),
          Expanded(
            child: solicitudes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text('No hay solicitudes por ahora', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: solicitudes.length,
                    itemBuilder: (_, i) => SolicitudCard(
                      alumno: solicitudes[i],
                      onAceptar: () => onAceptar(solicitudes[i]),
                      onRechazar: () => onRechazar(solicitudes[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class SolicitudCard extends StatelessWidget {
  final AlumnoSolicitud alumno;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  const SolicitudCard({super.key, required this.alumno, required this.onAceptar, required this.onRechazar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _dark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [_purple.withValues(alpha: 0.4), _teal.withValues(alpha: 0.4)]),
                ),
                child: Center(child: Text(alumno.nombre[0], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alumno.nombre, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD700)),
                        const SizedBox(width: 3),
                        Text('${alumno.calificacion}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(alumno.distancia, style: const TextStyle(color: _teal, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('~${alumno.tiempo}', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, size: 8, color: _teal),
                    Container(width: 1, height: 18, color: Colors.white.withValues(alpha: 0.15)),
                    const Icon(Icons.location_on_rounded, size: 14, color: _purple),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alumno.origen, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Text(alumno.destino, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    onPressed: onRechazar,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                    label: const Text('Aceptar Viaje'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    onPressed: onAceptar,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
