import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/q_icon.dart';
import '../flows/pay_flow.dart';
import '../flows/topup_flow.dart';
import '../flows/send_flow.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'activity_screen.dart';
import 'splits/groups_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  void _showPay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PayFlow(),
    );
  }

  void _showTopUp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TopUpFlow(),
    );
  }

  void _showSend() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SendFlow(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? QubyColors.bgDark : QubyColors.bgLight;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final screens = [
      HomeScreen(
        onPayTap: _showPay,
        onTopUpTap: _showTopUp,
        onSendTap: _showSend,
      ),
      const DiscoverScreen(),
      const GroupsListScreen(),
      const ActivityScreen(),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          IndexedStack(index: _tab, children: screens),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              currentIndex: _tab,
              isDark: isDark,
              bottomPad: bottomPad,
              onTabTap: (i) => setState(() => _tab = i),
              onScanTap: _showPay,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final double bottomPad;
  final void Function(int) onTabTap;
  final VoidCallback onScanTap;

  const _BottomBar({
    required this.currentIndex,
    required this.isDark,
    required this.bottomPad,
    required this.onTabTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final accent = isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;
    final inactive = isDark ? QubyColors.textFaintDark : QubyColors.textFaintLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    const labels = ['Home', 'Explore', '', 'Splits', 'Activity'];
    const icons = ['home', 'pin', 'scan', 'users', 'activity'];

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomPad + 6,
        top: 8,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(5, (i) {
          if (i == 2) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: onScanTap,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(child: qIcon('scan', 22, Colors.white)),
                  ),
                ),
              ),
            );
          }

          final actualIdx = i < 2 ? i : i - 1;
          final isActive = actualIdx == currentIndex;
          final color = isActive ? accent : inactive;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabTap(actualIdx),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  qIcon(icons[i], 22, color),
                  const SizedBox(height: 3),
                  Text(
                    labels[i],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
