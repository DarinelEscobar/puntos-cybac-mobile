import 'package:flutter/material.dart';
import '../../../features/client_cards/domain/models/client_card.dart';

class DigitalCard extends StatelessWidget {
  const DigitalCard({
    super.key,
    required this.card,
    this.isBack = false,
    this.onTap,
  });

  final ClientCard card;
  final bool isBack;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final branding = card.branding;
    final primaryColor = _hexToColor(branding.colorPrimary, const Color(0xFF195DE6));
    final secondaryColor = _hexToColor(branding.colorSecondary, const Color(0xFF111621));
    final accentColor = _hexToColor(branding.colorAccent, Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                   painter: _PatternPainter(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: isBack ? _buildBack(context) : _buildFront(context, accentColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    image: card.branding.logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(card.branding.logoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: card.branding.logoUrl == null
                      ? const Icon(Icons.local_cafe, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  card.companyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
               decoration: BoxDecoration(
                 color: accentColor.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(99),
                 border: Border.all(color: accentColor.withOpacity(0.4)),
               ),
               child: Text(
                 'MEMBER',
                 style: TextStyle(
                   color: accentColor,
                   fontSize: 10,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1.2,
                 ),
               ),
             ),
          ],
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo actual',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${card.pointsBalance}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Puntos',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatCardUid(card.cardUid),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Monospace',
                letterSpacing: 2.5,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.contactless, color: Colors.white54, size: 32),
          ],
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(card.qrPayload)}',
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.grey),
                      SizedBox(height: 4),
                      Text("Error QR", style: TextStyle(fontSize: 10)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              card.cardUid,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontFamily: 'Monospace',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardUid(String uid) {
    if (uid.length > 4) {
      return '•••• ${uid.substring(uid.length - 4)}';
    }
    return uid;
  }

  Color _hexToColor(String? hex, Color fallback) {
    if (hex == null) return fallback;
    var hexColor = hex.replaceAll('#', '').trim();
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    try {
      if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
     final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

     canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 80, paint);
     canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.95), 60, paint);

     // Add some grid lines pattern
     paint.strokeWidth = 1;
     paint.style = PaintingStyle.stroke;

     // Removed grid to keep it simpler
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
