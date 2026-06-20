import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/stripe_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/card_brand_logos.dart';
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
  bool _loading = false;
  String _error = '';
  String _paymentMethod = 'card';

  static const _eTransferEmail = 'pay@qubypay.com';

  double get _value => double.tryParse(_amount) ?? 0.0;

  void _onKey(String k) {
    setState(() {
      if (k == '⌫') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (k == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.length >= 7) {
        return;
      } else {
        _amount += k;
      }
    });
  }

  Future<void> _confirm() async {
    if (_value <= 0 || _loading) return;

    if (_paymentMethod == 'etransfer') {
      setState(() => _step = 4);
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _step = 2;
    });

    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      await StripeService.presentTopUpSheet(amount: _value, isDark: isDark);
      if (!mounted) return;
      await context.read<AppState>().reload();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _step = 3;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _step = 1;
        _error = StripeService.friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return FlowSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_step == 0) _buildAmount(isDark, textColor, dimColor, accent),
          if (_step == 1) _buildConfirm(isDark, textColor, dimColor, accent),
          if (_step == 2) _buildProcessing(isDark, accent, textColor),
          if (_step == 3) _buildSuccess(isDark, accent, textColor),
          if (_step == 4) _buildETransfer(isDark, textColor, dimColor, accent),
        ],
      ),
    );
  }

  Widget _buildAmount(bool isDark, Color text, Color dim, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Text('Add money',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 17, fontWeight: FontWeight.w700, color: text)),
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

  Widget _buildConfirm(bool isDark, Color text, Color dim, Color accent) {
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final surface2 =
        isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm top up',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 17, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w600, color: dim)),
                const SizedBox(height: 4),
                Text('\$${_value.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: text)),
                const SizedBox(height: 12),
                Text('Payment method',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w600, color: dim)),
                const SizedBox(height: 8),
                _paymentOption(
                  id: 'card',
                  title: 'Pay by credit card',
                  subtitleWidget: const CardBrandLogos(height: 16),
                  icon: 'card',
                  isDark: isDark,
                  text: text,
                  dim: dim,
                  accent: accent,
                  border: border,
                  surface2: surface2,
                ),
                const SizedBox(height: 8),
                _paymentOption(
                  id: 'etransfer',
                  title: 'Pay by e-Transfer',
                  subtitle: _eTransferEmail,
                  icon: 'bank',
                  isDark: isDark,
                  text: text,
                  dim: dim,
                  accent: accent,
                  border: border,
                  surface2: surface2,
                ),
              ],
            ),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_error,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: QubyColors.danger)),
          ],
          const SizedBox(height: 16),
          QubyBtn(
            label: _paymentMethod == 'card'
                ? 'Pay \$${_value.toStringAsFixed(2)}'
                : 'Continue',
            onTap: _loading ? null : _confirm,
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
              child: CircularProgressIndicator(strokeWidth: 3, color: accent)),
          const SizedBox(height: 20),
          Text('Adding funds…',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w600, color: text)),
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
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Center(child: qIcon('check', 28, accent)),
          ),
          const SizedBox(height: 16),
          Text('Money added!',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 6),
          Text(
            '\$${_value.toStringAsFixed(2)} added to your wallet',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color:
                    isDark ? QubyColors.textDimDark : QubyColors.textDimLight),
          ),
          const SizedBox(height: 28),
          QubyBtn(label: 'Done', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _paymentOption({
    required String id,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    required String icon,
    required bool isDark,
    required Color text,
    required Color dim,
    required Color accent,
    required Color border,
    required Color surface2,
  }) {
    final selected = _paymentMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent : border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            qIcon(icon, 20, selected ? accent : dim),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: text)),
                  const SizedBox(height: 4),
                  if (subtitleWidget != null)
                    subtitleWidget
                  else if (subtitle != null)
                    Text(subtitle,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected ? text : dim)),
                ],
              ),
            ),
            if (selected) qIcon('check', 18, accent),
          ],
        ),
      ),
    );
  }

  Widget _buildETransfer(bool isDark, Color text, Color dim, Color accent) {
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final surface2 =
        isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send e-Transfer',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 17, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(height: 8),
          Text(
            'Send \$${_value.toStringAsFixed(2)} to the email below. '
            'Your wallet will update once the transfer is received.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: dim),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send to',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w600, color: dim)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    qIcon('bank', 20, accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_eTransferEmail,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: text)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            const ClipboardData(text: _eTransferEmail));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied $_eTransferEmail',
                                style: GoogleFonts.plusJakartaSans()),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Copy',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: accent)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          QubyBtn(label: 'Done', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
