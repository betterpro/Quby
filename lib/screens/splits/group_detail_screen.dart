import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/q_icon.dart';

class GroupDetailScreen extends StatelessWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final accent = isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;
    final bg = isDark ? QubyColors.bgDark : QubyColors.bgLight;

    return Consumer<AppState>(
      builder: (context, state, _) {
        // Get fresh group data from state
        final currentGroup = state.groups.firstWhere(
          (g) => g.id == group.id,
          orElse: () => group,
        );

        return Scaffold(
          backgroundColor: bg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: currentGroup.color,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: qIcon('back', 18, Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: qIcon('plus', 18, Colors.white),
                    ),
                    onPressed: () =>
                        _showAddExpense(context, state, currentGroup),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          currentGroup.color,
                          currentGroup.color.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            currentGroup.emoji ?? '👥',
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentGroup.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '\$${currentGroup.totalSpend.toStringAsFixed(2)} total · ${currentGroup.expenses.length} expenses',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Members & balances
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balances',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: border),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(14),
                          itemCount: currentGroup.members.length,
                          separatorBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1, color: border),
                          ),
                          itemBuilder: (context, i) {
                            final member = currentGroup.members[i];
                            final isPositive = member.balance >= 0;
                            final balanceColor =
                                isPositive ? accent : QubyColors.danger;
                            return Row(
                              children: [
                                Avatar(
                                  initials: member.contact.initials,
                                  color: member.contact.color,
                                  size: 38,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.contact.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        isPositive
                                            ? 'owes you'
                                            : 'you owe',
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
                                      '\$${member.balance.abs().toStringAsFixed(2)}',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: balanceColor,
                                      ),
                                    ),
                                    if (member.balance != 0)
                                      GestureDetector(
                                        onTap: () => state.settleDebt(
                                          groupId: currentGroup.id,
                                          memberId: member.contact.id,
                                        ),
                                        child: Text(
                                          'Settle',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Expenses
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SectionTitle(
                    title: 'Expenses',
                    action: 'Add',
                    onAction: () =>
                        _showAddExpense(context, state, currentGroup),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final expense =
                        currentGroup.expenses.reversed.toList()[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _ExpenseTile(
                        expense: expense,
                        isDark: isDark,
                        textColor: textColor,
                        dimColor: dimColor,
                        surface: surface,
                        border: border,
                        accent: accent,
                      ),
                    );
                  },
                  childCount: currentGroup.expenses.length,
                ),
              ),
              if (currentGroup.expenses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        qIcon('receipt', 36, dimColor),
                        const SizedBox(height: 12),
                        Text(
                          'No expenses yet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: dimColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () =>
                              _showAddExpense(context, state, currentGroup),
                          child: Text(
                            'Add the first one',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }

  void _showAddExpense(
      BuildContext context, AppState state, Group currentGroup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: state,
        child: _AddExpenseSheet(group: currentGroup),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final bool isDark;
  final Color textColor;
  final Color dimColor;
  final Color surface;
  final Color border;
  final Color accent;

  const _ExpenseTile({
    required this.expense,
    required this.isDark,
    required this.textColor,
    required this.dimColor,
    required this.surface,
    required this.border,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isPaidByMe = expense.paidBy.id == 'me';
    final amountColor = isPaidByMe ? accent : QubyColors.danger;
    final dayDiff = DateTime.now().difference(expense.date).inDays;
    final dateLabel = dayDiff == 0
        ? 'Today'
        : dayDiff == 1
            ? 'Yesterday'
            : '$dayDiff days ago';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: expense.paidBy.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                expense.paidBy.initials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: expense.paidBy.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense.paidBy.name.split(' ').first} paid · $dateLabel',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: dimColor,
                  ),
                ),
                if (expense.category != null) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: dimColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      expense.category!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: dimColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                isPaidByMe
                    ? '+\$${(expense.amount - expense.perPerson).toStringAsFixed(2)}'
                    : '-\$${expense.perPerson.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  final Group group;
  const _AddExpenseSheet({required this.group});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _titleCtrl = TextEditingController();
  String _amount = '';
  List<Contact> _splitWith = [];

  @override
  void initState() {
    super.initState();
    _splitWith = widget.group.members.map((m) => m.contact).toList();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _onKey(String k) {
    setState(() {
      if (k == '⌫') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (k == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.contains('.') &&
          _amount.split('.')[1].length >= 2) {
        return;
      } else {
        _amount += k;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final surface2 = isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: SingleChildScrollView(
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
              'Add Expense',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.plusJakartaSans(fontSize: 15, color: textColor),
              decoration: InputDecoration(
                hintText: 'What was it for?',
                filled: true,
                fillColor: surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: AmountDisplay(amount: _amount, fontSize: 44)),
            const SizedBox(height: 12),
            NumPad(onKey: _onKey),
            const SizedBox(height: 16),
            Text(
              'Split with',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: dimColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.group.members.map((member) {
                final selected =
                    _splitWith.any((c) => c.id == member.contact.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _splitWith = _splitWith
                            .where((c) => c.id != member.contact.id)
                            .toList();
                      } else {
                        _splitWith = [..._splitWith, member.contact];
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? member.contact.color.withOpacity(0.15)
                          : surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? member.contact.color.withOpacity(0.4)
                            : border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Avatar(
                          initials: member.contact.initials,
                          color: member.contact.color,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          member.contact.name.split(' ').first,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? member.contact.color
                                : textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            QubyBtn(
              label: 'Add Expense',
              onTap: () {
                final val = double.tryParse(_amount);
                if (val != null && val > 0 && _titleCtrl.text.isNotEmpty) {
                  Provider.of<AppState>(context, listen: false).addExpense(
                    groupId: widget.group.id,
                    title: _titleCtrl.text,
                    amount: val,
                    splitWith: _splitWith,
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
