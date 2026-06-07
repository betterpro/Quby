import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/q_icon.dart';
import '../widgets/common.dart';

class TopUpFlow extends StatefulWidget {
  const TopUpFlow({super.key});

  @override
  State<TopUpFlow> createState() => _TopUpFlowState();
}

class _TopUpFlowState extends State<TopUpFlow> {
  int _step = 0;
  String _amount = '';
  String _source = 'bank';

  double get _value => double.tryParse(_amount) ?? 0.0;

  void _onKey(String k) {
    setState(() {
      if (k == '⌫') {
        if (_amount.isNotEmpty) _amount = _amount.substring(0, _amount.length - 1);
      } else if (k == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.length >= 7) {
        return;
      } else {
        _amount += k;
      }
    });
  }

  void _confirm() {
    if (_value <= 0) return;
    setState(() => _step = 2);
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      context.read<AppState>().topUp(
        amount: _value,
        source: _source == 'bank' ? 'Bank transfer' : 'Debit card',
      );
      setState(() => _step = 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final accent = isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? QubyColors.surface3Dark : QubyColors.surface3Light,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          if (_step == 0) _buildAmount(isDark, textColor, dimColor, accent),
          if (_step == 1) _buildSourceSelect(isDark, textColor, dimColor, accent),
          if (_step == 2) _buildProcessing(isDark, accent, textColor),
          if (_step == 3) _buildSuccess(isDark, accent, textColor),
        ],
      ),
    );
  }

  Widget _buildAmount(bool isDark, Color text, Color dim, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Text('Add money', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 24),
          AmountDisplay(amount: _amount),
          const SizedBox(height: 24),
          NumPad(onKey: _onKey),
          const SizedBox(height: 16),
          QubyBtn(
            label: _value > 0 ? 'Continue' : 'Enter amount',
            onTap: _value > 0 ? () => setState(() => _step = 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSelect(bool isDark, Color text, Color dim, Color accent) {
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final surface2 = isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;

    const sources = [
      ('bank', 'Bank Transfer', 'bank', 'Arrives in 1–2 days'),
      ('card', 'Debit Card', 'card', 'Instant'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('From', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: dim)),
          const SizedBox(height: 12),
          ...sources.map((s) {
            final selected = _source == s.$1;
            return GestureDetector(
              onTap: () => setState(() => _source = s.$1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? accent.withOpacity(0.08) : surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? accent : border, width: selected ? 1.5 : 0.5),
                ),
                child: Row(
                  children: [
                    qIcon(s.$3, 20, selected ? accent : dim),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.$2, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: text)),
                          Text(s.$4, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: dim)),
                        ],
                      ),
                    ),
                    if (selected) qIcon('check', 18, accent),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          QubyBtn(label: 'Top up \$${_value.toStringAsFixed(2)}', onTap: _confirm),
        ],
      ),
    );
  }

  Widget _buildProcessing(bool isDark, Color accent, Color text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          SizedBox(width: 56, height: 56, child: CircularProgressIndicator(strokeWidth: 3, color: accent)),
          const SizedBox(height: 20),
          Text('Adding funds…', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: text)),
        ],
      ),
    );
  }

  Widget _buildSuccess(bool isDark, Color accent, Color text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: accent.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(child: qIcon('check', 28, accent)),
          ),
          const SizedBox(height: 16),
          Text('Money added!', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 6),
          Text(
            '\$${_value.toStringAsFixed(2)} added to your wallet',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? QubyColors.textDimDark : QubyColors.textDimLight),
          ),
          const SizedBox(height: 28),
          QubyBtn(label: 'Done', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
