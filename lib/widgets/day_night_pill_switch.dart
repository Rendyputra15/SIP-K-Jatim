import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class DayNightPillSwitch extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onToggled;

  const DayNightPillSwitch({
    super.key,
    this.width = 130,
    this.height = 38,
    this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final knobSize = height - 8;

        return Tooltip(
          message: isDark ? 'Beralih ke Light Mode' : 'Beralih ke Dark Mode',
          child: GestureDetector(
            onTap: () {
              ThemeService.toggleTheme();
              onToggled?.call();
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF4F6F8), Color(0xFFE5E9EC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: const Color(0xFFD3DAE2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Label Teks: LIGHT MODE (Kiri) atau DARK MODE (Kanan)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    left: isDark ? null : 12,
                    right: isDark ? 12 : null,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) {
                        return FadeTransition(opacity: anim, child: child);
                      },
                      child: Text(
                        isDark ? 'DARK MODE' : 'LIGHT MODE',
                        key: ValueKey<bool>(isDark),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: isDark
                              ? const Color(0xFF1E3A8A)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),

                  // Knob Melayang dengan Ikon Matahari / Bulan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      alignment:
                          isDark ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        width: knobSize,
                        height: knobSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.2, -0.2),
                            radius: 0.85,
                            colors: isDark
                                ? const [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFE0E7FF),
                                    Color(0xFFC7D2FE),
                                  ]
                                : const [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFFEF9C3),
                                    Color(0xFFFEF08A),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0xFF818CF8)
                                      .withValues(alpha: 0.4)
                                  : const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: Size(knobSize * 0.7, knobSize * 0.7),
                            painter: isDark
                                ? MoonKnobIconPainter()
                                : SunKnobIconPainter(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Painter Matahari dengan 3 sinar memancar ke atas sesuai gambar referensi
class SunKnobIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.58);
    final radius = size.width * 0.26;

    final sunPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final rayPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Kubah setengah lingkaran matahari
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, pi, pi, true, sunPaint);

    // 3 Garis Sinar Matahari
    final rayDist = radius + 3.0;
    const rayLength = 3.8;

    // Sinar tegak tengah
    canvas.drawLine(
      Offset(center.dx, center.dy - rayDist),
      Offset(center.dx, center.dy - rayDist - rayLength),
      rayPaint,
    );

    // Sinar kiri (sudut 135 derajat)
    const cos45 = 0.7071;
    const sin45 = 0.7071;
    canvas.drawLine(
      Offset(center.dx - rayDist * cos45, center.dy - rayDist * sin45),
      Offset(
        center.dx - (rayDist + rayLength) * cos45,
        center.dy - (rayDist + rayLength) * sin45,
      ),
      rayPaint,
    );

    // Sinar kanan (sudut 45 derajat)
    canvas.drawLine(
      Offset(center.dx + rayDist * cos45, center.dy - rayDist * sin45),
      Offset(
        center.dx + (rayDist + rayLength) * cos45,
        center.dy - (rayDist + rayLength) * sin45,
      ),
      rayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter Bulan Sabit dengan diagonal streak putih sesuai gambar referensi
class MoonKnobIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.44, size.height * 0.48);
    final radius = size.width * 0.30;

    // Garis aksen putih diagonal
    final streakPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.78),
      Offset(size.width * 0.78, size.height * 0.22),
      streakPaint,
    );

    // Bulan sabit gradasi biru tua ke cyan
    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFF1E3A8A), Color(0xFF0284C7), Color(0xFF38BDF8)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    final innerCenter = Offset(
      center.dx + radius * 0.58,
      center.dy - radius * 0.32,
    );
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: innerCenter, radius: radius * 0.85));

    final crescentPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    canvas.drawPath(crescentPath, moonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
