import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models.dart';
import '../data/seed_data.dart';
import '../theme/app_colors.dart';
import '../widgets/q_icon.dart';
import 'biz_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  final _categories = ['All', 'Café', 'Bakery', 'Juice', 'Tea house', 'Deli'];

  List<Business> get _filtered {
    var result = List<Business>.from(BUSINESSES);
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((b) =>
              b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              b.cat.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_selectedCategory != null && _selectedCategory != 'All') {
      result = result.where((b) => b.cat == _selectedCategory).toList();
    }
    return result;
  }

  void _pushDetail(Business biz) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => BizDetailScreen(biz: biz),
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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface2 = isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final accent = isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find places near you',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: dimColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: qIcon('search', 18, dimColor),
                      ),
                      hintText: 'Search spots…',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: dimColor,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Map card placeholder
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildMapCard(context, isDark, textColor, dimColor),
          ),
        ),
        // Category chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected =
                    cat == (_selectedCategory ?? 'All');
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = cat == 'All' ? null : cat;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? accent
                          : surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? accent : border,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : dimColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              '${_filtered.length} spot${_filtered.length == 1 ? '' : 's'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: dimColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final biz = _filtered[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _BizListTile(
                  biz: biz,
                  onTap: () => _pushDetail(biz),
                  isDark: isDark,
                  textColor: textColor,
                  dimColor: dimColor,
                  border: border,
                  accent: accent,
                ),
              );
            },
            childCount: _filtered.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildMapCard(
      BuildContext context, bool isDark, Color textColor, Color dimColor) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A2A3A), const Color(0xFF0F1E2E)]
              : [const Color(0xFFD4E8D0), const Color(0xFFB8D4B2)],
        ),
      ),
      child: Stack(
        children: [
          // Grid lines to simulate map
          CustomPaint(
            size: const Size(double.infinity, 160),
            painter: _MapGridPainter(isDark: isDark),
          ),
          // Spot markers
          ...BUSINESSES.take(4).toList().asMap().entries.map((e) {
            final positions = [
              const Offset(0.2, 0.3),
              const Offset(0.5, 0.5),
              const Offset(0.7, 0.25),
              const Offset(0.35, 0.65),
            ];
            return Positioned(
              left: MediaQuery.of(context).size.width * positions[e.key].dx - 60,
              top: 160 * positions[e.key].dy - 16,
              child: _MapPin(biz: e.value),
            );
          }),
          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.6),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  qIcon('pin', 14, isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight),
                  const SizedBox(width: 6),
                  Text(
                    'Dublin City Centre',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${BUSINESSES.length} spots nearby',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: dimColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final bool isDark;
  _MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.05)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MapPin extends StatelessWidget {
  final Business biz;
  const _MapPin({required this.biz});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: biz.color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: biz.color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            biz.name.split(' ').first,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          width: 2,
          height: 6,
          color: biz.color,
        ),
      ],
    );
  }
}

class _BizListTile extends StatelessWidget {
  final Business biz;
  final VoidCallback onTap;
  final bool isDark;
  final Color textColor;
  final Color dimColor;
  final Color border;
  final Color accent;

  const _BizListTile({
    required this.biz,
    required this.onTap,
    required this.isDark,
    required this.textColor,
    required this.dimColor,
    required this.border,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: biz.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: qIcon(biz.icon, 26, biz.color)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    biz.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        biz.cat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: dimColor,
                        ),
                      ),
                      Text(
                        ' · ${biz.dist}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: dimColor,
                        ),
                      ),
                    ],
                  ),
                  if (biz.offer != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: biz.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        biz.offer!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: biz.color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            qIcon('chevron', 18, dimColor),
          ],
        ),
      ),
    );
  }
}
