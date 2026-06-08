import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/q_icon.dart';
import '../widgets/quby_mark.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _slides = [
    _Slide(
      gradient: [Color(0xFF0A1F15), Color(0xFF0D2B1C)],
      accent: Color(0xFF00D193),
      icon: 'sparkle',
      isLogo: true,
      title: 'Welcome to Quby',
      subtitle: 'The smart wallet for everyday spending,\nsplitting, and earning.',
    ),
    _Slide(
      gradient: [Color(0xFF0A0F2E), Color(0xFF0D1340)],
      accent: Color(0xFF5B6CE0),
      icon: 'contactless',
      title: 'Pay Anywhere',
      subtitle: 'Tap or scan to pay at local cafés,\nbakeries, and restaurants instantly.',
    ),
    _Slide(
      gradient: [Color(0xFF1A0F2E), Color(0xFF200D40)],
      accent: Color(0xFF9A6CD4),
      icon: 'users',
      title: 'Split with Friends',
      subtitle: 'Track shared expenses and settle up\nwithout the awkward conversations.',
    ),
    _Slide(
      gradient: [Color(0xFF2E1A0A), Color(0xFF3D2208)],
      accent: Color(0xFFE2911F),
      icon: 'star',
      title: 'Earn as You Spend',
      subtitle: 'Every purchase earns Quby points.\nRedeem for cashback and perks.',
      isLast: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: slide.gradient,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -60,
              right: -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.accent.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.accent.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) {
                setState(() => _page = i);
                _fadeCtrl.reset();
                _fadeCtrl.forward();
              },
              itemCount: _slides.length,
              itemBuilder: (context, i) {
                final s = _slides[i];
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(32, topPad + 40, 32, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon area
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: s.accent.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: s.accent.withOpacity(0.25),
                                width: 1.5,
                              ),
                            ),
                            child: s.isLogo
                                ? Center(
                                    child: QubyMark(size: 52, accentColor: s.accent),
                                  )
                                : Center(child: qIcon(s.icon, 48, s.accent)),
                          ),
                        ),
                        SizedBox(height: size.height * 0.07),

                        // Text
                        Text(
                          s.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.65),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Bottom bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
                child: Column(
                  children: [
                    // Page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? _slides[_page].accent
                                : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: slide.accent,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: slide.accent.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _next,
                            borderRadius: BorderRadius.circular(18),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slide.isLast ? 'Get Started' : 'Continue',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: slide.isLast
                                          ? const Color(0xFF1A0A00)
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    slide.isLast
                                        ? Icons.rocket_launch_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: slide.isLast
                                        ? const Color(0xFF1A0A00)
                                        : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (!slide.isLast) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _finish,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
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

class _Slide {
  final List<Color> gradient;
  final Color accent;
  final String icon;
  final String title;
  final String subtitle;
  final bool isLogo;
  final bool isLast;

  const _Slide({
    required this.gradient,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLogo = false,
    this.isLast = false,
  });
}
