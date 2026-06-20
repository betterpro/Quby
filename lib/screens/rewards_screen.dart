import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/q_icon.dart';
import '../widgets/safe_layout.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rewards',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Earn & redeem at your spots',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: dimColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildPointsHero(context, state),
              ),
            ),
            if (state.stampCards.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildStampCard(
                    context,
                    state.stampCards.first,
                    isDark,
                    textColor,
                    dimColor,
                    surface,
                    border,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Redeem perks',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ),
            if (state.perks.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No perks available yet.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: dimColor,
                      ),
                    ),
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final perk = state.perks[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _buildPerkTile(
                      context,
                      perk,
                      state,
                      isDark,
                      textColor,
                      dimColor,
                      surface,
                      border,
                    ),
                  );
                },
                childCount: state.perks.length,
              ),
            ),
            const SliverToBoxAdapter(child: TabScrollSpacer()),
          ],
        );
      },
    );
  }

  Widget _buildPointsHero(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [QubyColors.honeyDark, QubyColors.honey],
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
                'Your Points',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Gold Member',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${state.points}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 6),
                child: Text(
                  'pts',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Worth \$${(state.points / 100).toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.points} / 2500 to Platinum',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '${((state.points / 2500) * 100).round()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (state.points / 2500).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStampCard(
    BuildContext context,
    StampCard card,
    bool isDark,
    Color textColor,
    Color dimColor,
    Color surface,
    Color border,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: card.businessColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: qIcon(card.businessIcon, 20, card.businessColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.businessName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Collect ${card.goal} stamps, get a free coffee',
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(card.goal, (i) {
              final filled = i < card.stampCount;
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: filled
                      ? card.businessColor.withValues(alpha: 0.15)
                      : (isDark
                          ? QubyColors.surface2Dark
                          : QubyColors.surface2Light),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: filled
                        ? card.businessColor.withValues(alpha: 0.4)
                        : border,
                  ),
                ),
                child: Center(
                  child: filled
                      ? qIcon('check', 20, card.businessColor)
                      : qIcon('coffee', 18, dimColor.withValues(alpha: 0.3)),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '${card.stampCount} of ${card.goal} stamps collected · ${card.goal - card.stampCount} more to go',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: dimColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkTile(
    BuildContext context,
    Perk perk,
    AppState state,
    bool isDark,
    Color textColor,
    Color dimColor,
    Color surface,
    Color border,
  ) {
    final canRedeem = state.points >= perk.cost;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: perk.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: qIcon(perk.icon, 26, perk.color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perk.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  perk.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: dimColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    qIcon('sparkle', 12, QubyColors.honey),
                    const SizedBox(width: 4),
                    Text(
                      '${perk.cost} pts',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: QubyColors.honey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: canRedeem ? () => state.redeemPerk(perk) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: canRedeem ? accent : dimColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Redeem',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: canRedeem ? Colors.white : dimColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
