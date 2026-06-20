import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/business_map.dart';
import '../widgets/q_icon.dart';
import '../widgets/safe_layout.dart';

class BizDetailScreen extends StatelessWidget {
  final Business biz;

  const BizDetailScreen({super.key, required this.biz});

  void _showPay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickPaySheet(biz: biz),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final bg = isDark ? QubyColors.bgDark : QubyColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: biz.color,
            leading: SliverHeroBackButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: qIcon('back', 18, Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [biz.color, biz.color.withValues(alpha: 0.8)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      BusinessLogo(
                        biz: biz,
                        size: 80,
                        iconSize: 44,
                        borderRadius: 24,
                        backgroundColor: biz.logoUrl != null
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.2),
                        iconColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        biz.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${biz.cat} · ${biz.dist}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Pay button
                  QubyBtn(
                    label: 'Pay here',
                    iconName: 'scan',
                    onTap: () => _showPay(context),
                  ),
                  const SizedBox(height: 20),
                  if (biz.hasLocation) ...[
                    BusinessMap(
                      businesses: [biz],
                      highlight: biz,
                      height: 200,
                      showUserLocation: false,
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Info cards
                  if (biz.addr != null)
                    _infoRow(context, 'pin', biz.addr!, 'Location', isDark,
                        textColor, dimColor, surface, border),
                  if (biz.addr != null) const SizedBox(height: 10),
                  _infoRow(context, 'bell', 'Mon–Sat 7:00–18:00', 'Hours',
                      isDark, textColor, dimColor, surface, border),
                  const SizedBox(height: 10),
                  _infoRow(context, 'contactless', 'Quby · Card · Cash',
                      'Payment', isDark, textColor, dimColor, surface, border),
                  const SizedBox(height: 20),
                  // Rewards section
                  if (biz.offer != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: biz.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: biz.color.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: biz.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: qIcon('star', 22, biz.color),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current offer',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: biz.color.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  biz.offer!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: biz.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Points info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          QubyColors.honey.withValues(alpha: 0.1),
                          const Color(0xFFE2911F).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: QubyColors.honey.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        qIcon('sparkle', 24, QubyColors.honey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Earn points here',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                r'Get 10 points per $1 spent',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: dimColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: ScreenScrollSpacer()),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String icon,
    String value,
    String label,
    bool isDark,
    Color textColor,
    Color dimColor,
    Color surface,
    Color border,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          qIcon(icon, 18, dimColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: dimColor,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Quick pay bottom sheet (mini version)
class _QuickPaySheet extends StatefulWidget {
  final Business biz;
  const _QuickPaySheet({required this.biz});

  @override
  State<_QuickPaySheet> createState() => _QuickPaySheetState();
}

class _QuickPaySheetState extends State<_QuickPaySheet> {
  String _amount = '';
  bool _processing = false;
  bool _done = false;

  void _onKey(String k) {
    setState(() {
      if (k == '⌫') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (k == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.contains('.') && _amount.split('.')[1].length >= 2) {
        return;
      } else {
        _amount += k;
      }
    });
  }

  Future<void> _pay() async {
    final val = double.tryParse(_amount);
    if (val == null || val <= 0) return;
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Provider.of<AppState>(context, listen: false).pay(
      businessId: widget.biz.id,
      amount: val,
      method: 'qr',
    );
    setState(() {
      _processing = false;
      _done = true;
    });
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? QubyColors.lineDark : QubyColors.lineLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          if (_done) ...[
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF00B488).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: qIcon(
                    'check',
                    36,
                    isDark
                        ? QubyColors.accentGreenDark
                        : QubyColors.accentGreenLight),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment sent!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 40),
          ] else ...[
            Text(
              'Pay ${widget.biz.name}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            AmountDisplay(amount: _amount),
            const SizedBox(height: 20),
            NumPad(onKey: _onKey),
            const SizedBox(height: 16),
            QubyBtn(
              label: _amount.isEmpty ? 'Enter amount' : 'Pay \$$_amount',
              onTap: _amount.isNotEmpty ? _pay : null,
              loading: _processing,
            ),
          ],
        ],
      ),
    );
  }
}
