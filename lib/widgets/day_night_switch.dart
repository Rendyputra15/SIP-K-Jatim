import 'package:flutter/material.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class DayNightSwitch extends StatelessWidget {
  final double width;
  final double height;

  const DayNightSwitch({
    super.key,
    this.width = 68,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;

        return Tooltip(
          message: isDark
              ? 'Mode Malam (Gelap) - Ketuk untuk Siang'
              : 'Mode Siang (Terang) - Ketuk untuk Malam',
          child: GestureDetector(
            onTap: () => ThemeService.toggleTheme(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: width,
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                      : [const Color(0xFF38BDF8), const Color(0xFF60A5FA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFF93C5FD),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : const Color(0xFF38BDF8).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Latar Dekorasi: Awan (Siang) atau Bintang (Malam)
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isDark)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFFDE047),
                            ),
                          )
                        else
                          const SizedBox(width: 14),
                        if (!isDark)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.cloud_rounded,
                              size: 15,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 10,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Knob Geser: Matahari (Siang) atau Bulan (Malam)
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment:
                        isDark ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: height - 6,
                      height: height - 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF334155)
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
                          size: 15,
                          color: isDark
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFFF59E0B),
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
