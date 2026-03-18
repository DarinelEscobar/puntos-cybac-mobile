import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
    final palette = _resolvePalette(card.branding);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [palette.gradientStart, palette.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.gradientStart.withValues(alpha: 0.3),
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
                  painter: _PatternPainter(
                    color: palette.onCardColor.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: isBack
                    ? _buildBack(context)
                    : _buildFront(context, palette),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context, _CardPalette palette) {
    final textColor = palette.onCardColor;
    final textColorMuted = textColor.withValues(alpha: 0.82);
    final chipTextColor = _idealOnColor(palette.accentColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildBrandAvatar(textColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      card.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: palette.accentColor,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: chipTextColor.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                'MEMBER',
                style: TextStyle(
                  color: chipTextColor,
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
              style: TextStyle(
                color: textColorMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${card.pointsBalance}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Puntos',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.9),
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
                color: textColor.withValues(alpha: 0.9),
                fontFamily: 'Monospace',
                letterSpacing: 2.5,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.contactless,
              color: textColor.withValues(alpha: 0.55),
              size: 32,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context) {
    final qrData = card.qrDataForDisplay;
    final manualId = card.displayId.isEmpty
        ? 'ID NO DISPONIBLE'
        : card.displayId;
    final isLongManualId = manualId.length > 18;
    final idStyle = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
      letterSpacing: isLongManualId ? 0.8 : 1.5,
      fontFamily: 'Monospace',
      fontSize: isLongManualId ? 14 : 16,
    );
    const idTextScaler = TextScaler.noScaling;

    return LayoutBuilder(
      builder: (context, constraints) {
        const containerVerticalPadding = 8.0;
        const idSpacing = 10.0;
        const maxQrSize = 132.0;
        const layoutSafetyPx = 6.0;
        final idTextWidth = (constraints.maxWidth - 92.0)
            .clamp(132.0, 180.0)
            .toDouble();
        final idBoxHeight = isLongManualId ? 20.0 : 22.0;

        final qrSize = constraints.maxHeight.isFinite
            ? (constraints.maxHeight -
                      (containerVerticalPadding * 2) -
                      idSpacing -
                      idBoxHeight -
                      layoutSafetyPx)
                  .clamp(0.0, maxQrSize)
                  .toDouble()
            : maxQrSize;

        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: containerVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: qrSize,
                  height: qrSize,
                  child: qrData.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, color: Colors.grey),
                            SizedBox(height: 4),
                            Text(
                              'QR no disponible',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        )
                      : QrImageView(
                          data: qrData,
                          size: qrSize,
                          version: QrVersions.auto,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                          errorCorrectionLevel: QrErrorCorrectLevel.L,
                          errorStateBuilder: (context, error) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.grey),
                                SizedBox(height: 4),
                                Text(
                                  'Error QR',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const SizedBox(height: idSpacing),
                SizedBox(
                  width: idTextWidth,
                  height: idBoxHeight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      manualId,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      textScaler: idTextScaler,
                      style: idStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCardUid(String uid) {
    if (uid.length > 4) {
      return '•••• ${uid.substring(uid.length - 4)}';
    }
    return uid;
  }

  Widget _buildBrandAvatar(Color textColor) {
    final logoUrl = card.branding.logoUrl?.trim();
    final hasLogoUrl = logoUrl != null && logoUrl.isNotEmpty;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: textColor.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogoUrl
          ? Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildLogoFallback(textColor);
              },
            )
          : _buildLogoFallback(textColor),
    );
  }

  Widget _buildLogoFallback(Color textColor) {
    final initials = _companyInitials(card.companyName);

    return Center(
      child: Text(
        initials,
        maxLines: 1,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _companyInitials(String companyName) {
    final cleaned = companyName.trim();
    if (cleaned.isEmpty) return 'PC';

    final words = cleaned
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);

    if (words.isEmpty) return 'PC';
    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    final first = words[0].substring(0, 1);
    final second = words[1].substring(0, 1);
    return '$first$second'.toUpperCase();
  }

  _CardPalette _resolvePalette(CardBranding branding) {
    const defaultPrimary = Color(0xFF195DE6);
    const defaultSecondary = Color(0xFF111621);
    const defaultAccent = Color(0xFFF9C846);

    final brandPrimary = _parseHexColor(branding.colorPrimary);
    final brandSecondary = _parseHexColor(branding.colorSecondary);
    final brandAccent = _parseHexColor(branding.colorAccent);

    final gradientStart =
        brandPrimary ?? brandSecondary ?? brandAccent ?? defaultPrimary;

    Color gradientEnd;
    if (brandSecondary != null) {
      gradientEnd = _areColorsSimilar(gradientStart, brandSecondary)
          ? _deriveCompanionColor(gradientStart)
          : brandSecondary;
    } else if (brandPrimary != null || brandAccent != null) {
      gradientEnd = _deriveCompanionColor(gradientStart);
    } else {
      gradientEnd = defaultSecondary;
    }

    var accent =
        brandAccent ??
        brandSecondary ??
        _deriveAccentColor(gradientStart, gradientEnd, fallback: defaultAccent);

    if (_areColorsSimilar(accent, gradientStart) &&
        _areColorsSimilar(accent, gradientEnd)) {
      accent = _deriveAccentColor(
        gradientStart,
        gradientEnd,
        fallback: defaultAccent,
      );
    }

    final onCardColor = _idealOnColor(
      _mixColors(gradientStart, gradientEnd, 0.5),
    );

    return _CardPalette(
      gradientStart: gradientStart,
      gradientEnd: gradientEnd,
      accentColor: accent,
      onCardColor: onCardColor,
    );
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null) return null;

    var normalized = hex.replaceAll('#', '').trim();
    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return null;
    }

    if (normalized.length == 3 || normalized.length == 4) {
      normalized = normalized
          .split('')
          .map((character) => '$character$character')
          .join();
    }

    if (normalized.length == 6) {
      normalized = 'FF$normalized';
    }

    if (normalized.length != 8) return null;

    try {
      return Color(int.parse(normalized, radix: 16));
    } catch (_) {
      return null;
    }
  }

  Color _deriveCompanionColor(Color base) {
    final hsl = HSLColor.fromColor(base);
    final isLight = hsl.lightness > 0.55;
    final adjustedLightness = isLight
        ? (hsl.lightness - 0.2).clamp(0.0, 1.0)
        : (hsl.lightness + 0.2).clamp(0.0, 1.0);

    return hsl.withLightness(adjustedLightness).toColor();
  }

  Color _deriveAccentColor(Color start, Color end, {required Color fallback}) {
    final base = _mixColors(start, end, 0.5);
    final hsl = HSLColor.fromColor(base);
    final shiftedHue = (hsl.hue + 35.0) % 360;
    final saturation = (hsl.saturation + 0.35).clamp(0.45, 0.95);
    final lightness = hsl.lightness > 0.55 ? 0.25 : 0.82;

    final derived = hsl
        .withHue(shiftedHue)
        .withSaturation(saturation)
        .withLightness(lightness)
        .toColor();

    if (_areColorsSimilar(derived, start) && _areColorsSimilar(derived, end)) {
      return fallback;
    }
    return derived;
  }

  Color _mixColors(Color first, Color second, double ratio) {
    final t = ratio.clamp(0.0, 1.0).toDouble();
    return Color.lerp(first, second, t) ?? first;
  }

  bool _areColorsSimilar(Color first, Color second) {
    final firstHsl = HSLColor.fromColor(first);
    final secondHsl = HSLColor.fromColor(second);
    final rawHueDifference = (firstHsl.hue - secondHsl.hue).abs();
    final hueDifference = rawHueDifference > 180
        ? 360 - rawHueDifference
        : rawHueDifference;
    final saturationDifference = (firstHsl.saturation - secondHsl.saturation)
        .abs();
    final lightnessDifference = (firstHsl.lightness - secondHsl.lightness)
        .abs();

    return hueDifference < 8 &&
        saturationDifference < 0.08 &&
        lightnessDifference < 0.08;
  }

  Color _idealOnColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() < 0.45
        ? Colors.white
        : const Color(0xFF0F172A);
  }
}

class _CardPalette {
  const _CardPalette({
    required this.gradientStart,
    required this.gradientEnd,
    required this.accentColor,
    required this.onCardColor,
  });

  final Color gradientStart;
  final Color gradientEnd;
  final Color accentColor;
  final Color onCardColor;
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
