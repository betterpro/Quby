import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/geo_utils.dart';
import '../widgets/business_map.dart';
import '../widgets/common.dart';
import '../widgets/q_icon.dart';
import '../widgets/safe_layout.dart';
import 'biz_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final bool isActive;

  const DiscoverScreen({super.key, this.isActive = true});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  LatLng? _userLocation;
  Business? _selectedBusiness;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshBusinesses();
    });
  }

  Future<void> _refresh() async {
    await context.read<AppState>().refreshBusinesses();
  }

  Future<void> _loadUserLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  List<Business> _sorted(List<Business> businesses) {
    final result = List<Business>.from(businesses);
    if (_userLocation != null) {
      result.sort((a, b) {
        final aDist = a.hasLocation
            ? GeoUtils.distanceMeters(
                _userLocation!.latitude,
                _userLocation!.longitude,
                a.lat!,
                a.lng!,
              )
            : double.infinity;
        final bDist = b.hasLocation
            ? GeoUtils.distanceMeters(
                _userLocation!.latitude,
                _userLocation!.longitude,
                b.lat!,
                b.lng!,
              )
            : double.infinity;
        return aDist.compareTo(bDist);
      });
    }
    return result;
  }

  List<Business> _filtered(List<Business> businesses) {
    var result = _sorted(businesses);
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((b) =>
              b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              b.cat.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (b.addr?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }
    if (_selectedCategory != null && _selectedCategory != 'All') {
      result = result.where((b) => b.cat == _selectedCategory).toList();
    }
    return result;
  }

  List<String> _categories(List<Business> businesses) {
    final cats = businesses.map((b) => b.cat).toSet().toList()..sort();
    return ['All', ...cats];
  }

  String _distanceLabel(Business biz) {
    if (_userLocation != null && biz.hasLocation) {
      return GeoUtils.formatDistance(
        GeoUtils.distanceMeters(
          _userLocation!.latitude,
          _userLocation!.longitude,
          biz.lat!,
          biz.lng!,
        ),
      );
    }
    return biz.dist;
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
    final surface2 =
        isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final businesses = state.businesses;
        final filtered = _filtered(businesses);
        final categories = _categories(businesses);
        final mappedCount = businesses.where((b) => b.hasLocation).length;

        return RefreshIndicator(
          onRefresh: _refresh,
          color: accent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BusinessMap(
                        active: widget.isActive,
                        businesses: businesses,
                        userLocation: _userLocation,
                        highlight: _selectedBusiness,
                        height: 260,
                        onBusinessTap: (biz) {
                          setState(() => _selectedBusiness = biz);
                          _pushDetail(biz);
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          qIcon('pin', 14, accent),
                          const SizedBox(width: 6),
                          Text(
                            mappedCount > 0
                                ? '$mappedCount pinned on map'
                                : 'No pinned businesses yet',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: dimColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (categories.length > 1)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final selected = cat == (_selectedCategory ?? 'All');
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategory = cat == 'All' ? null : cat;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? accent : surface2,
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
                    businesses.isEmpty
                        ? 'No spots yet'
                        : '${filtered.length} spot${filtered.length == 1 ? '' : 's'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: dimColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (businesses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'Businesses will appear here once loaded from the database.',
                        textAlign: TextAlign.center,
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
                    final biz = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: _BizListTile(
                        biz: biz,
                        distanceLabel: _distanceLabel(biz),
                        onTap: () => _pushDetail(biz),
                        isDark: isDark,
                        textColor: textColor,
                        dimColor: dimColor,
                        border: border,
                        accent: accent,
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
              const SliverToBoxAdapter(child: TabScrollSpacer()),
            ],
          ),
        );
      },
    );
  }
}

class _BizListTile extends StatelessWidget {
  final Business biz;
  final String distanceLabel;
  final VoidCallback onTap;
  final bool isDark;
  final Color textColor;
  final Color dimColor;
  final Color border;
  final Color accent;

  const _BizListTile({
    required this.biz,
    required this.distanceLabel,
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
            BusinessLogo(biz: biz, size: 52, iconSize: 26, borderRadius: 14),
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
                        ' · $distanceLabel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: dimColor,
                        ),
                      ),
                    ],
                  ),
                  if (biz.addr != null && biz.addr!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      biz.addr!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: dimColor,
                      ),
                    ),
                  ],
                  if (biz.offer != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: biz.color.withValues(alpha: 0.12),
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
