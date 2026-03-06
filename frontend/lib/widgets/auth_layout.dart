import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F766E),
                  Color(0xFF14B8A6),
                  Color(0xFF0B3D3A)
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -40,
            child: _blurOrb(
                color: Colors.white.withValues(alpha: 0.16), size: 220),
          ),
          Positioned(
            bottom: -100,
            left: -20,
            child: _blurOrb(
                color: const Color(0xFFFFEDD5).withValues(alpha: 0.3),
                size: 260),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    color: Colors.white.withValues(alpha: 0.92),
                    elevation: 14,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.92, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            builder: (_, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF14B8A6)
                                  ],
                                ),
                              ),
                              child: const Icon(Icons.work_outline_rounded,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 24),
                          child,
                          if (footer != null) ...[
                            const SizedBox(height: 12),
                            Center(child: footer!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget _blurOrb({required Color color, required double size}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
