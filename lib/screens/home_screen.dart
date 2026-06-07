import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/seed_data.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/q_icon.dart';
import '../widgets/quby_mark.dart';
import 'biz_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onPayTap;
  final VoidCallback onTopUpTap;
  final VoidCallback onSendTap;

  const HomeScreen({
    super.key,
    required this.onPayTap,
    required this.onTopUpTap,
    required this.onSendTap,
  });

  void _pushBizDetail(BuildContext context, Business biz) {
    Navigator.of(context).push(_slideRoute(BizDetailScreen(biz: biz)));
  }

  PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildHeader(context, isDark, textColor, dimColor),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildBalanceCard(context, state, isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildQuickActions(context, isDark, textColor, dimColor),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
                child: SectionTitle(
                  title: 'Your spots',
                  action: 'See all',
                  onAction: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildBizCarousel(context),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildGroupsCard(context, state, isDark, textColor, dimColor),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: SectionTitle(
                  title: 'Recent',
                  action: 'All activity',
                  onAction: () {},
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final tx = state.transactions.take(5).toList()[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        TransactionTile(tx: tx),
                      ],
                    ),
                  );
                },
                childCount: state.transactions.take(5).length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor, Color dimColor) {
    return Row(
      children: [
        const QubyMark(size: 28),
        const SizedBox(width: 8),
        Text(
          'Quby',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF5B6CE0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'MO',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, AppState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172235), Color(0xFF0B1322)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    qIcon('sparkle', 12, const Color(0xFFFFB638)),
                    const SizedBox(width: 4),
                    Text(
                      '${state.points} pts',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFB638),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '€${state.balance.toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _balanceAction(
                label: 'Top Up',
                icon: 'up',
                onTap: onTopUpTap,
              ),
              const SizedBox(width: 10),
              _balanceAction(
                label: 'Send',
                icon: 'send',
                onTap: onSendTap,
              ),
              const SizedBox(width: 10),
              _balanceAction(
                label: 'Card',
                icon: 'card',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceAction({
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              qIcon(icon, 18, Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, bool isDark, Color textColor, Color dimColor) {
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;
    final surface2 =
        isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    final actions = [
      {'icon': 'scan', 'label': 'Pay', 'primary': true},
      {'icon': 'send', 'label': 'Send', 'primary': false},
      {'icon': 'up', 'label': 'Top Up', 'primary': false},
      {'icon': 'receipt', 'label': 'Split', 'primary': false},
    ];

    return Row(
      children: actions.asMap().entries.map((e) {
        final isPrimary = e.value['primary'] as bool;
        final iconColor = isPrimary ? Colors.white : accent;
        final bg = isPrimary ? accent : surface2;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < actions.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () {
                if (e.value['label'] == 'Pay') onPayTap();
                if (e.value['label'] == 'Send') onSendTap();
                if (e.value['label'] == 'Top Up') onTopUpTap();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: isPrimary ? null : Border.all(color: border),
                ),
                child: Column(
                  children: [
                    qIcon(e.value['icon'] as String, 22, iconColor),
                    const SizedBox(height: 6),
                    Text(
                      e.value['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBizCarousel(BuildContext context) {
    return SizedBox(
      height: 164,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: BUSINESSES.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          return BizBadge(
            biz: BUSINESSES[i],
            onTap: () => _pushBizDetail(context, BUSINESSES[i]),
          );
        },
      ),
    );
  }

  Widget _buildGroupsCard(BuildContext context, AppState state, bool isDark,
      Color textColor, Color dimColor) {
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    final netBalance = state.groups.fold<double>(0, (s, g) => s + g.myBalance);
    final isPositive = netBalance >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Groups',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? accent.withOpacity(0.12)
                      : QubyColors.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}€${netBalance.toStringAsFixed(2)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? accent : QubyColors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...state.groups.take(3).map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: g.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          g.emoji ?? '👥',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '${g.expenses.length} expense${g.expenses.length == 1 ? '' : 's'}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: dimColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      g.myBalance >= 0
                          ? '+€${g.myBalance.toStringAsFixed(2)}'
                          : '-€${g.myBalance.abs().toStringAsFixed(2)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: g.myBalance >= 0 ? accent : QubyColors.danger,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
