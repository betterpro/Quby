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

class SendFlow extends StatefulWidget {
  final Contact? contact;

  const SendFlow({super.key, this.contact});

  @override
  State<SendFlow> createState() => _SendFlowState();
}

class _SendFlowState extends State<SendFlow> {
  int _step = 0;
  Contact? _contact;
  String _amount = '';

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _contact = widget.contact;
      _step = 1;
    }
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

  void _send() {
    if (_value <= 0 || _contact == null) return;
    setState(() => _step = 2);
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      context.read<AppState>().send(contact: _contact!, amount: _value);
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
          if (_step == 0) _buildContactPick(isDark, textColor, dimColor, accent),
          if (_step == 1) _buildAmountEntry(isDark, textColor, dimColor, accent),
          if (_step == 2) _buildProcessing(isDark, accent, textColor),
          if (_step == 3) _buildSuccess(isDark, accent, textColor),
        ],
      ),
    );
  }

  Widget _buildContactPick(bool isDark, Color text, Color dim, Color accent) {
    final surface2 = isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send money', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 20),
          ...CONTACTS.map((c) => GestureDetector(
            onTap: () => setState(() {
              _contact = c;
              _step = 1;
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 0.5),
              ),
              child: Row(
                children: [
                  Avatar(initials: c.initials, color: c.color, size: 40),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: text)),
                      Text(c.handle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: dim)),
                    ],
                  ),
                  const Spacer(),
                  qIcon('chevron', 18, dim),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAmountEntry(bool isDark, Color text, Color dim, Color accent) {
    if (_contact == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Avatar(initials: _contact!.initials, color: _contact!.color, size: 36),
              const SizedBox(width: 10),
              Text(_contact!.name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: text)),
            ],
          ),
          const SizedBox(height: 24),
          AmountDisplay(amount: _amount),
          const SizedBox(height: 24),
          NumPad(onKey: _onKey),
          const SizedBox(height: 16),
          QubyBtn(
            label: _value > 0 ? 'Send \$${_value.toStringAsFixed(2)}' : 'Enter amount',
            onTap: _value > 0 ? _send : null,
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
          SizedBox(width: 56, height: 56, child: CircularProgressIndicator(strokeWidth: 3, color: accent)),
          const SizedBox(height: 20),
          Text('Sending…', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: text)),
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
          Text('Sent!', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 6),
          Text(
            '\$${_value.toStringAsFixed(2)} to ${_contact?.name}',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? QubyColors.textDimDark : QubyColors.textDimLight),
          ),
          const SizedBox(height: 28),
          QubyBtn(label: 'Done', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
