import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/q_icon.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _filterIndex = 0;
  final _filters = ['All', 'Payments', 'Transfers', 'Top Ups'];

  List<Transaction> _filtered(List<Transaction> all) {
    switch (_filterIndex) {
      case 1:
        return all.where((t) => t.type == TransactionType.payment).toList();
      case 2:
        return all
            .where((t) =>
                t.type == TransactionType.send ||
                t.type == TransactionType.receive)
            .toList();
      case 3:
        return all.where((t) => t.type == TransactionType.topup).toList();
      default:
        return all;
    }
  }

  Map<String, List<Transaction>> _grouped(List<Transaction> txs) {
    final now = DateTime.now();
    final map = <String, List<Transaction>>{};

    for (final tx in txs) {
      final diff = now.difference(tx.date).inDays;
      String label;
      if (diff == 0) {
        label = 'Today';
      } else if (diff == 1) {
        label = 'Yesterday';
      } else if (diff < 7) {
        label = 'This week';
      } else {
        label = 'Earlier';
      }
      map.putIfAbsent(label, () => []).add(tx);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final surface2 = isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final accent = isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final filtered = _filtered(state.transactions);
        final grouped = _grouped(filtered);
        final groupOrder = ['Today', 'Yesterday', 'This week', 'Earlier'];
        final orderedGroups = groupOrder
            .where((k) => grouped.containsKey(k))
            .map((k) => MapEntry(k, grouped[k]!))
            .toList();

        // Stats
        final totalSpend = state.transactions
            .where((t) => t.isDebit)
            .fold(0.0, (s, t) => s + t.amount);
        final totalIn = state.transactions
            .where((t) => !t.isDebit)
            .fold(0.0, (s, t) => s + t.amount);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Spent',
                            value: '\$${totalSpend.toStringAsFixed(2)}',
                            icon: 'down',
                            color: QubyColors.danger,
                            isDark: isDark,
                            border: border,
                            surface: surface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Received',
                            value: '\$${totalIn.toStringAsFixed(2)}',
                            icon: 'up',
                            color: accent,
                            isDark: isDark,
                            border: border,
                            surface: surface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Transactions',
                            value: '${state.transactions.length}',
                            icon: 'receipt',
                            color: const Color(0xFF5B6CE0),
                            isDark: isDark,
                            border: border,
                            surface: surface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Filter segments
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: _filters.asMap().entries.map((e) {
                      final selected = _filterIndex == e.key;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _filterIndex = e.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              e.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : dimColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // Grouped transactions
            for (final entry in orderedGroups) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    entry.key,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: dimColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(14),
                      itemCount: entry.value.length,
                      separatorBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: border),
                      ),
                      itemBuilder: (context, i) =>
                          TransactionTile(tx: entry.value[i]),
                    ),
                  ),
                ),
              ),
            ],
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    children: [
                      qIcon('receipt', 40, dimColor),
                      const SizedBox(height: 12),
                      Text(
                        'No transactions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: dimColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: 80 + MediaQuery.of(context).padding.bottom),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  final bool isDark;
  final Color border;
  final Color surface;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.border,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(child: qIcon(icon, 16, color)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: dimColor,
            ),
          ),
        ],
      ),
    );
  }
}
