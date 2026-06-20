import 'package:flutter/material.dart';

/// Shared safe-area helpers for consistent layout across Quby screens.
abstract final class QubyLayout {
  /// Device insets that stay stable when the keyboard opens.
  static EdgeInsets viewPadding(BuildContext context) =>
      MediaQuery.viewPaddingOf(context);

  static double topInset(BuildContext context) => viewPadding(context).top;

  static double bottomInset(BuildContext context) =>
      viewPadding(context).bottom;

  /// Total height of the main shell bottom navigation bar.
  static double bottomNavHeight(BuildContext context) =>
      _bottomBarTopPadding +
      _bottomBarContentHeight +
      _bottomBarBottomPadding +
      bottomInset(context);

  static const double _bottomBarTopPadding = 8;
  static const double _bottomBarContentHeight = 50;
  static const double _bottomBarBottomPadding = 6;

  /// Trailing spacer inside tab scroll views (nav inset applied by [MainShell]).
  static const double tabScrollEnd = 16;

  /// Trailing spacer for full-screen routes without bottom nav.
  static double screenScrollEnd(BuildContext context) =>
      bottomInset(context) + 24;
}

/// Trailing spacer for tab screens inside [MainShell].
class TabScrollSpacer extends StatelessWidget {
  const TabScrollSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: QubyLayout.tabScrollEnd);
  }
}

/// Trailing spacer for pushed full-screen routes.
class ScreenScrollSpacer extends StatelessWidget {
  const ScreenScrollSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: QubyLayout.screenScrollEnd(context));
  }
}

/// Standard modal sheet wrapper with bottom safe-area padding.
class SheetContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final BorderRadius borderRadius;

  const SheetContainer({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      padding: EdgeInsets.only(bottom: QubyLayout.bottomInset(context)),
      child: child,
    );
  }
}

/// Back button for [SliverAppBar] hero headers — respects the status-bar inset.
class SliverHeroBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const SliverHeroBackButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: QubyLayout.topInset(context)),
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}
