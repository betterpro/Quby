import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/seed_data.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/q_icon.dart';
import '../widgets/common.dart';

class PayFlow extends StatefulWidget {
  final Business? business;

  const PayFlow({super.key, this.business});

  @override
  State<PayFlow> createState() => _PayFlowState();
}

class _PayFlowState extends State<PayFlow> {
  int _step = 0;
  String _method = 'qr';
  String _amount = '';
  late Business _biz;

  @override
  void initState() {
    super.initState();
    _biz = widget.business ?? BUSINESSES.first;
  }

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

  void _pay() {
    if (_value <= 0) return;
    setState(() => _step = 2);
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      context.read<AppState>().pay(
        businessId: _biz.id,
        amount: _value,
        method: _method,
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
          if (_step == 0) _buildMethodSelect(context, isDark, textColor, dimColor, accent, surface),
          if (_step == 1) _buildAmountEntry(context, isDark, textColor, dimColor, accent),
          if (_step == 2) _buildProcessing(isDark, accent, textColor),
          if (_step == 3) _buildSuccess(context, isDark, accent, textColor),
        ],
      ),
    );
  }

  Widget _buildMethodSelect(BuildContext context, bool isDark, Color text, Color dim, Color accent, Color surface) {
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final surface2 = isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _biz.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: qIcon(_biz.icon, 22, _biz.color)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_biz.name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
                  Text(_biz.cat, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: dim)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Payment method', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: dim)),
          const SizedBox(height: 12),
          ...[
            ('qr', 'QR Code', 'qr', 'Scan the merchant QR'),
            ('contactless', 'Contactless', 'contactless', 'Tap your phone to pay'),
          ].map((m) {
            final selected = _method == m.$1;
            return GestureDetector(
              onTap: () => setState(() => _method = m.$1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? accent.withOpacity(0.08) : surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? accent : border,
                    width: selected ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    qIcon(m.$3, 20, selected ? accent : dim),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.$2, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: text)),
                          Text(m.$4, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: dim)),
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
          QubyBtn(
            label: 'Continue',
            onTap: () => setState(() => _step = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountEntry(BuildContext context, bool isDark, Color text, Color dim, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Text('Pay to ${_biz.name}', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: dim)),
          const SizedBox(height: 20),
          AmountDisplay(amount: _amount),
          const SizedBox(height: 24),
          NumPad(onKey: _onKey),
          const SizedBox(height: 16),
          QubyBtn(
            label: _value > 0 ? 'Pay €${_value.toStringAsFixed(2)}' : 'Enter amount',
            onTap: _value > 0 ? _pay : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing(bool isDark, Color accent, Color text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: accent,
            ),
          ),
          const SizedBox(height: 20),
          Text('Processing payment…', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: text)),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, bool isDark, Color accent, Color text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: qIcon('check', 28, accent)),
          ),
          const SizedBox(height: 16),
          Text('Payment sent!', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 6),
          Text(
            '€${_value.toStringAsFixed(2)} to ${_biz.name}',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? QubyColors.textDimDark : QubyColors.textDimLight),
          ),
          const SizedBox(height: 28),
          QubyBtn(label: 'Done', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
