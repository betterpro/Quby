import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';

class RegisterBusinessScreen extends StatefulWidget {
  const RegisterBusinessScreen({super.key});

  @override
  State<RegisterBusinessScreen> createState() =>
      _RegisterBusinessScreenState();
}

class _RegisterBusinessScreenState extends State<RegisterBusinessScreen> {
  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = 'Food & Drink';
  bool _loading = false;
  String _error = '';
  bool _submitted = false;

  static const _categories = [
    'Food & Drink',
    'Retail',
    'Services',
    'Entertainment',
    'Health & Beauty',
    'Education',
    'Travel',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Business name is required');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await SupabaseService.submitBusinessRequest(
        name: name,
        category: _category,
        address: _addrCtrl.text.trim().isEmpty ? null : _addrCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? QubyColors.bgDark : QubyColors.bgLight;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final accent = isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;
    final accentOn = isDark ? QubyColors.accentGreenOnDark : QubyColors.accentGreenOnLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _submitted
            ? _buildSuccess(textColor, dimColor, surface, border, accent, accentOn)
            : _buildForm(textColor, dimColor, surface, border, accent, accentOn),
      ),
    );
  }

  Widget _buildSuccess(Color textColor, Color dimColor, Color surface,
      Color border, Color accent, Color accentOn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.hourglass_top_rounded, color: accent, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              'Application Submitted!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Our team will review your business and get back to you within 1–3 business days.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: dimColor,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: accentOn,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Go to Home',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Color textColor, Color dimColor, Color surface,
      Color border, Color accent, Color accentOn) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).canPop()
                    ? Navigator.of(context).pop()
                    : _goHome(),
                icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
              ),
              Expanded(
                child: Text(
                  'Register Business',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPad + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us about your business',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Submit your details for admin review. Once approved, your business will be listed on Quby.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: dimColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                if (_error.isNotEmpty) ...[
                  _ErrorBanner(message: _error),
                  const SizedBox(height: 16),
                ],

                _label('Business Name *', dimColor),
                const SizedBox(height: 8),
                _textField(_nameCtrl, 'e.g. The Corner Café', surface, border,
                    textColor, dimColor, accent),
                const SizedBox(height: 18),

                _label('Category *', dimColor),
                const SizedBox(height: 8),
                _categoryDropdown(surface, border, textColor, dimColor, accent),
                const SizedBox(height: 18),

                _label('Address', dimColor),
                const SizedBox(height: 8),
                _textField(_addrCtrl, 'e.g. 123 Main St, City', surface, border,
                    textColor, dimColor, accent),
                const SizedBox(height: 18),

                _label('Description', dimColor),
                const SizedBox(height: 8),
                _textField(
                  _descCtrl,
                  'Tell customers what makes your business special…',
                  surface,
                  border,
                  textColor,
                  dimColor,
                  accent,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: accentOn,
                      disabledBackgroundColor: accent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accentOn,
                            ),
                          )
                        : Text(
                            'Submit Application',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _goHome,
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: dimColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, Color dimColor) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: dimColor,
        ),
      );

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    Color surface,
    Color border,
    Color textColor,
    Color dimColor,
    Color accent, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: dimColor, fontSize: 14),
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _categoryDropdown(Color surface, Color border, Color textColor,
      Color dimColor, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<String>(
        value: _category,
        isExpanded: true,
        dropdownColor: surface,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.keyboard_arrow_down, color: dimColor),
        style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 14),
        onChanged: (v) => setState(() => _category = v!),
        items: _categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
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
        color: QubyColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: QubyColors.danger.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: QubyColors.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: QubyColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
