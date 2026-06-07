import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import 'q_icon.dart';

// ── Avatar ────────────────────────────────────────────────────────────────────

class Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;

  const Avatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.plusJakartaSans(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── MemberStack ───────────────────────────────────────────────────────────────

class MemberStack extends StatelessWidget {
  final List<Contact> members;
  final double avatarSize;
  final double overlap;

  const MemberStack({
    super.key,
    required this.members,
    this.avatarSize = 28,
    this.overlap = 10,
  });

  @override
  Widget build(BuildContext context) {
    final shown = members.take(4).toList();
    final totalWidth =
        avatarSize + (shown.length - 1) * (avatarSize - overlap);

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        children: shown.asMap().entries.map((e) {
          return Positioned(
            left: e.key * (avatarSize - overlap),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
              child: Avatar(
                initials: e.value.initials,
                color: e.value.color,
                size: avatarSize,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── BizBadge ──────────────────────────────────────────────────────────────────

class BizBadge extends StatelessWidget {
  final Business biz;
  final VoidCallback? onTap;

  const BizBadge({super.key, required this.biz, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: biz.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: qIcon(biz.icon, 22, biz.color)),
            ),
            const SizedBox(height: 8),
            Text(
              biz.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              biz.dist,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: dimColor,
              ),
            ),
            if (biz.offer != null) ...[
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: biz.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  biz.offer!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: biz.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── NumPad ────────────────────────────────────────────────────────────────────

class NumPad extends StatelessWidget {
  final void Function(String) onKey;

  const NumPad({super.key, required this.onKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;

    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '.', '0', '⌫',
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.0,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: keys.map((k) {
        final isBackspace = k == '⌫';
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onKey(k),
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: isBackspace
                  ? qIcon('back', 22, dimColor)
                  : Text(
                      k,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── AmountDisplay ─────────────────────────────────────────────────────────────

class AmountDisplay extends StatelessWidget {
  final String amount;
  final double fontSize;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.fontSize = 52,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: fontSize * 0.15),
          child: Text(
            r'$',
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize * 0.5,
              fontWeight: FontWeight.w500,
              color: dimColor,
            ),
          ),
        ),
        Text(
          amount.isEmpty ? '0' : amount,
          style: GoogleFonts.spaceGrotesk(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ── SectionTitle ──────────────────────────────────────────────────────────────

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
      ],
    );
  }
}

// ── QubyBtn ───────────────────────────────────────────────────────────────────

class QubyBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool loading;
  final String? iconName;
  final double height;

  const QubyBtn({
    super.key,
    required this.label,
    this.onTap,
    this.primary = true,
    this.loading = false,
    this.iconName,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;
    final accentInk =
        isDark ? QubyColors.accentGreenInkDark : QubyColors.accentGreenInkLight;
    final surface = isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    final bgColor = primary ? accent : surface;
    final labelColor = primary ? Colors.white : textColor;

    return SizedBox(
      height: height,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: primary
                ? null
                : BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(16),
                  ),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary ? Colors.white : accent,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (iconName != null) ...[
                          qIcon(iconName!, 18,
                              primary ? Colors.white : accentInk),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── QCard ─────────────────────────────────────────────────────────────────────

class QCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final bool bordered;
  final VoidCallback? onTap;

  const QCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = 22,
    this.bordered = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor =
        isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        borderRadius: BorderRadius.circular(radius),
        border: bordered ? Border.all(color: border) : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ── TransactionTile ───────────────────────────────────────────────────────────

class TransactionTile extends StatelessWidget {
  final Transaction tx;

  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    final iconColor = tx.iconColor ?? (isDark ? QubyColors.textDimDark : QubyColors.textDimLight);
    final amountColor = tx.isDebit ? textColor : accent;
    final amountPrefix = tx.isDebit ? '-' : '+';

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: qIcon(tx.icon ?? 'receipt', 22, iconColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tx.subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: dimColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$amountPrefix\$${tx.amount.toStringAsFixed(2)}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
