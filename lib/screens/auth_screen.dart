import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../state/app_state.dart';
import '../widgets/quby_mark.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;
  bool _loading = false;
  bool _obscure = true;
  String _error = '';

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _navigateToApp() {
    final appState = context.read<AppState>();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (_) => false,
    );
    appState.reload();
  }

  Future<void> _handleEmail() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (!_isSignIn && _passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      if (_isSignIn) {
        await SupabaseService.signInWithEmail(email, password);
      } else {
        await SupabaseService.signUpWithEmail(email, password);
      }
      if (mounted) _navigateToApp();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _loading = false;
        _error = msg.contains('Invalid login') || msg.contains('invalid_grant')
            ? 'Incorrect email or password'
            : msg;
      });
    }
  }

  Future<void> _handleGoogle() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await SupabaseService.signInWithGoogle();
      if (mounted) _navigateToApp();
    } catch (e) {
      setState(() {
        _loading = false;
        if (!e.toString().contains('cancelled')) {
          _error = 'Google sign-in failed. Please try again.';
        }
      });
    }
  }

  Future<void> _handleApple() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await SupabaseService.signInWithApple();
      if (mounted) _navigateToApp();
    } catch (e) {
      setState(() {
        _loading = false;
        if (!e.toString().contains('cancelled') &&
            !e.toString().contains('AuthorizationErrorCode.canceled')) {
          _error = 'Apple sign-in failed. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1F15), Color(0xFF0D2B1C)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 32, 24, bottomPad + 32),
              child: Column(
                children: [
                  // Decorative circle behind logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D193).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00D193).withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: QubyMark(size: 36, accentColor: Color(0xFF00D193)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    _isSignIn ? 'Welcome back' : 'Create your account',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignIn
                        ? 'Sign in to your Quby wallet'
                        : 'Join Quby and start spending smarter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Sign In / Sign Up tab toggle
                  _TabToggle(
                    isSignIn: _isSignIn,
                    onToggle: (v) => setState(() {
                      _isSignIn = v;
                      _error = '';
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Error
                  if (_error.isNotEmpty) ...[
                    _ErrorBanner(message: _error),
                    const SizedBox(height: 16),
                  ],

                  // Email field
                  _InputField(
                    label: 'Email',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    hint: 'you@example.com',
                  ),
                  const SizedBox(height: 14),

                  // Password field
                  _PasswordField(
                    label: 'Password',
                    controller: _passCtrl,
                    obscure: _obscure,
                    onToggle: () => setState(() => _obscure = !_obscure),
                  ),

                  if (!_isSignIn) ...[
                    const SizedBox(height: 14),
                    _PasswordField(
                      label: 'Confirm Password',
                      controller: _confirmCtrl,
                      obscure: _obscure,
                      onToggle: () => setState(() => _obscure = !_obscure),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // Primary action button
                  _PrimaryButton(
                    label: _isSignIn ? 'Sign In' : 'Create Account',
                    loading: _loading,
                    onTap: _handleEmail,
                  ),

                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: Colors.white.withOpacity(0.1),
                              height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue with',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: Colors.white.withOpacity(0.1),
                              height: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google button
                  _SocialButton(
                    onTap: _loading ? null : _handleGoogle,
                    icon: const _GoogleG(),
                    label: 'Continue with Google',
                  ),

                  // Apple button — iOS only
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 12),
                    _SocialButton(
                      onTap: _loading ? null : _handleApple,
                      icon: const Icon(Icons.apple,
                          color: Colors.white, size: 20),
                      label: 'Continue with Apple',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final bool isSignIn;
  final void Function(bool) onToggle;

  const _TabToggle({required this.isSignIn, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab(label: 'Sign In', active: isSignIn, onTap: () => onToggle(true)),
          _Tab(
              label: 'Sign Up',
              active: !isSignIn,
              onTap: () => onToggle(false)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF00D193).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: active
                ? Border.all(color: const Color(0xFF00D193).withOpacity(0.3))
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active
                    ? const Color(0xFF00D193)
                    : Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.red.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hint;

  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.hint = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
          decoration: _inputDecoration('••••••••').copyWith(
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.4),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton(
      {required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: loading
                  ? const Color(0xFF00D193).withOpacity(0.6)
                  : const Color(0xFF00D193),
              borderRadius: BorderRadius.circular(16),
              boxShadow: loading
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF00D193).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF0A1F15)),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A1F15),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.04),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
      ),
    );
  }
}

// ── Shared styles ─────────────────────────────────────────────────────────────

TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.white.withOpacity(0.55),
    );

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF00D193), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
