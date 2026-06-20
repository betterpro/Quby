import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/q_icon.dart';
import '../widgets/safe_layout.dart';
import 'auth_screen.dart';
import 'rewards_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use Quby.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await SupabaseService.signOut();
    if (!context.mounted) return;

    await context.read<AppState>().clear();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
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
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return Scaffold(
      backgroundColor: bg,
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final me = state.me;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: bg,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: qIcon('back', 22, textColor),
                ),
                title: Text(
                  'Profile',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    children: [
                      Avatar(initials: me.initials, color: me.color, size: 72),
                      const SizedBox(height: 14),
                      Text(
                        me.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      if (me.handle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '@${me.handle}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: dimColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Balance',
                              value: '\$${state.balance.toStringAsFixed(2)}',
                              surface: surface,
                              border: border,
                              textColor: textColor,
                              dimColor: dimColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Points',
                              value: '${state.points}',
                              surface: surface,
                              border: border,
                              textColor: textColor,
                              dimColor: dimColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SettingsGroup(
                        surface: surface,
                        border: border,
                        children: [
                          _SettingsTile(
                            icon: 'star',
                            label: 'Rewards',
                            textColor: textColor,
                            dimColor: dimColor,
                            accent: accent,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RewardsScreen(),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: border),
                          _SettingsTile(
                            icon: 'settings',
                            label: 'Dark mode',
                            textColor: textColor,
                            dimColor: dimColor,
                            accent: accent,
                            trailing: Switch.adaptive(
                              value: state.isDark,
                              activeTrackColor: accent.withValues(alpha: 0.35),
                              activeThumbColor: accent,
                              onChanged: (_) =>
                                  context.read<AppState>().toggleTheme(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      QubyBtn(
                        label: 'Sign out',
                        primary: false,
                        iconName: 'logout',
                        onTap: () => _signOut(context),
                      ),
                      const TabScrollSpacer(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color dimColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.dimColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: dimColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final Color surface;
  final Color border;
  final List<Widget> children;

  const _SettingsGroup({
    required this.surface,
    required this.border,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String label;
  final Color textColor;
  final Color dimColor;
  final Color accent;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.dimColor,
    required this.accent,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: qIcon(icon, 18, accent)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              trailing ?? qIcon('chevron', 18, dimColor),
            ],
          ),
        ),
      ),
    );
  }
}
