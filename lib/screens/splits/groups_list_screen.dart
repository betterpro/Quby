import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/q_icon.dart';
import 'group_detail_screen.dart';

class GroupsListScreen extends StatelessWidget {
  const GroupsListScreen({super.key});

  void _pushDetail(BuildContext context, Group group) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => GroupDetailScreen(group: group),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final accent = isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final totalBalance = state.groups.fold<double>(
          0.0, (s, g) => s + g.myBalance);
        final isPositive = totalBalance >= 0;
        final balanceColor =
            isPositive ? accent : QubyColors.danger;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Splits',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showCreateGroup(context, state),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                qIcon('plus', 14, Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  'New',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Balance hero
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildBalanceHero(
                    context, totalBalance, isPositive, balanceColor,
                    textColor, dimColor, isDark, state),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Your groups',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final group = state.groups[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _GroupCard(
                      group: group,
                      isDark: isDark,
                      textColor: textColor,
                      dimColor: dimColor,
                      surface: surface,
                      border: border,
                      accent: accent,
                      onTap: () => _pushDetail(context, group),
                    ),
                  );
                },
                childCount: state.groups.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }

  Widget _buildBalanceHero(
    BuildContext context,
    double totalBalance,
    bool isPositive,
    Color balanceColor,
    Color textColor,
    Color dimColor,
    bool isDark,
    AppState state,
  ) {
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net balance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: dimColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}\$${totalBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: balanceColor,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: balanceColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: qIcon(
                      isPositive ? 'up' : 'down', 24, balanceColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  label: 'You are owed',
                  value:
                      '\$${state.groups.fold<double>(0, (s, g) => s + (g.myBalance > 0 ? g.myBalance : 0)).toStringAsFixed(2)}',
                  color: isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight,
                  dimColor: dimColor,
                ),
              ),
              Container(
                  width: 1,
                  height: 32,
                  color: border),
              Expanded(
                child: _miniStat(
                  label: 'You owe',
                  value:
                      '\$${state.groups.fold<double>(0, (s, g) => s + (g.myBalance < 0 ? g.myBalance.abs() : 0)).toStringAsFixed(2)}',
                  color: QubyColors.danger,
                  dimColor: dimColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required String value,
    required Color color,
    required Color dimColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
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
    );
  }

  void _showCreateGroup(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: state,
        child: const _CreateGroupSheet(),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;
  final bool isDark;
  final Color textColor;
  final Color dimColor;
  final Color surface;
  final Color border;
  final Color accent;
  final VoidCallback onTap;

  const _GroupCard({
    required this.group,
    required this.isDark,
    required this.textColor,
    required this.dimColor,
    required this.surface,
    required this.border,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = group.myBalance >= 0;
    final balanceColor = isPositive ? accent : QubyColors.danger;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: group.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      group.emoji ?? '👥',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '${group.members.length} members · ${group.expenses.length} expenses',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: dimColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}\$${group.myBalance.toStringAsFixed(2)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: balanceColor,
                      ),
                    ),
                    Text(
                      isPositive ? 'owed to you' : 'you owe',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: dimColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (group.members.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  MemberStack(
                    members: group.members.map((m) => m.contact).toList(),
                    avatarSize: 24,
                    overlap: 8,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    group.members.map((m) => m.contact.name.split(' ').first).join(', '),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: dimColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CreateGroupSheet extends StatefulWidget {
  const _CreateGroupSheet();

  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _nameCtrl = TextEditingController();
  final _emojiOptions = ['🏠', '✈️', '🍜', '🎉', '💼', '🏋️', '🎮', '🌴'];
  String _emoji = '👥';
  final _colorOptions = [
    const Color(0xFF5B6CE0),
    const Color(0xFF3E9C8E),
    const Color(0xFFE0913B),
    const Color(0xFF9A6CD4),
    const Color(0xFFD8743C),
  ];
  Color _color = const Color(0xFF5B6CE0);

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface2 = isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'New Group',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.plusJakartaSans(fontSize: 15, color: textColor),
            decoration: InputDecoration(
              hintText: 'Group name',
              filled: true,
              fillColor: surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pick an emoji',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: dimColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _emojiOptions.map((e) {
              return GestureDetector(
                onTap: () => setState(() => _emoji = e),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _emoji == e
                        ? _color.withOpacity(0.15)
                        : surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _emoji == e ? _color : border,
                    ),
                  ),
                  child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Color',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: dimColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _colorOptions.map((c) {
              final selected = _color == c;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          QubyBtn(
            label: 'Create Group',
            onTap: () {
              if (_nameCtrl.text.isNotEmpty) {
                Provider.of<AppState>(context, listen: false).createGroup(
                  name: _nameCtrl.text,
                  members: [],
                  color: _color,
                  emoji: _emoji,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
