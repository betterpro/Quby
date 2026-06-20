import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/q_icon.dart';
import 'register_business_screen.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() =>
      _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  List<BusinessRequest> _requests = [];
  List<Business> _businesses = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final results = await Future.wait([
        SupabaseService.getMyBusinessRequests(),
        SupabaseService.getMyBusinesses(),
      ]);
      if (mounted) {
        setState(() {
          _requests = results[0] as List<BusinessRequest>;
          _businesses = results[1] as List<Business>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load businesses. Please try again.';
        });
      }
    }
  }

  void _openEdit(Business biz, Color surface, Color border, Color textColor,
      Color dimColor, Color accent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditBusinessSheet(
        business: biz,
        surface: surface,
        border: border,
        textColor: textColor,
        dimColor: dimColor,
        accent: accent,
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? QubyColors.bgDark : QubyColors.bgLight;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: qIcon('back', 20, textColor),
                  ),
                  Expanded(
                    child: Text(
                      'My Businesses',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const RegisterBusinessScreen(),
                      ));
                      _load();
                    },
                    icon: Icon(Icons.add, size: 16, color: accent),
                    label: Text(
                      'Add',
                      style: GoogleFonts.plusJakartaSans(
                        color: accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(color: accent))
                  : _error.isNotEmpty
                      ? _buildError(textColor, dimColor, accent)
                      : _buildContent(textColor, dimColor, surface, border,
                          accent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Color textColor, Color dimColor, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: dimColor, size: 40),
            const SizedBox(height: 12),
            Text(
              _error,
              style: GoogleFonts.plusJakartaSans(color: dimColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _load,
              child: Text('Retry', style: TextStyle(color: accent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor, Color dimColor, Color surface,
      Color border, Color accent) {
    if (_requests.isEmpty && _businesses.isEmpty) {
      return _buildEmpty(textColor, dimColor, accent);
    }

    return RefreshIndicator(
      color: accent,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (_businesses.isNotEmpty) ...[
            _sectionLabel('Active Businesses', dimColor),
            const SizedBox(height: 10),
            ..._businesses.map((b) => _BusinessCard(
                  business: b,
                  surface: surface,
                  border: border,
                  textColor: textColor,
                  dimColor: dimColor,
                  onEdit: () =>
                      _openEdit(b, surface, border, textColor, dimColor, accent),
                )),
            const SizedBox(height: 20),
          ],
          if (_requests.isNotEmpty) ...[
            _sectionLabel('Applications', dimColor),
            const SizedBox(height: 10),
            ..._requests.map((r) => _RequestCard(
                  request: r,
                  surface: surface,
                  border: border,
                  textColor: textColor,
                  dimColor: dimColor,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(Color textColor, Color dimColor, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.store_outlined, color: accent, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              'No businesses yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register your business on Quby to reach more customers.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: dimColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const RegisterBusinessScreen(),
                  ));
                  _load();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark
                      ? QubyColors.accentGreenOnDark
                      : QubyColors.accentGreenOnLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Register Business',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, Color dimColor) => Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: dimColor,
          letterSpacing: 0.8,
        ),
      );
}

// ── Cards ─────────────────────────────────────────────────────────────────────

class _BusinessCard extends StatelessWidget {
  final Business business;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color dimColor;
  final VoidCallback onEdit;

  const _BusinessCard({
    required this.business,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.dimColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: business.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(business.icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          business.name,
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          [business.cat, if (business.addr?.isNotEmpty == true) business.addr!]
              .join('  ·  '),
          style: GoogleFonts.plusJakartaSans(color: dimColor, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _StatusBadge('active'),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit_outlined, color: textColor, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BusinessRequest request;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color dimColor;

  const _RequestCard({
    required this.request,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.dimColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          request.category,
                          if (request.address?.isNotEmpty == true)
                            request.address!,
                        ].join('  ·  '),
                        style: GoogleFonts.plusJakartaSans(
                            color: dimColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(request.status),
              ],
            ),
            if (request.status == 'rejected' &&
                request.rejectionReason != null) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: QubyColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: QubyColors.danger.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: QubyColors.danger, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.rejectionReason!,
                        style: GoogleFonts.plusJakartaSans(
                          color: QubyColors.danger,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, label) = switch (status) {
      'approved' || 'active' => (
          isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight,
          'Active'
        ),
      'rejected' => (
          isDark ? QubyColors.dangerDark : QubyColors.danger,
          'Rejected'
        ),
      _ => (QubyColors.honeyDark, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit Business Sheet ───────────────────────────────────────────────────────

class _EditBusinessSheet extends StatefulWidget {
  final Business business;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color dimColor;
  final Color accent;
  final VoidCallback onSaved;

  const _EditBusinessSheet({
    required this.business,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.dimColor,
    required this.accent,
    required this.onSaved,
  });

  @override
  State<_EditBusinessSheet> createState() => _EditBusinessSheetState();
}

class _EditBusinessSheetState extends State<_EditBusinessSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addrCtrl;
  String _category = '';
  bool _loading = false;
  String _error = '';

  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounce;
  double? _lat;
  double? _lng;

  static const _categories = [
    'Food & Drink',
    'Retail',
    'Services',
    'Entertainment',
    'Health & Beauty',
    'Education',
    'Travel',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.business.name);
    _addrCtrl = TextEditingController(text: widget.business.addr ?? '');
    _lat = widget.business.lat;
    _lng = widget.business.lng;
    _category = _categories.contains(widget.business.cat)
        ? widget.business.cat
        : 'Other';
    _addrCtrl.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addrCtrl.removeListener(_onAddressChanged);
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  void _onAddressChanged() {
    _debounce?.cancel();
    final q = _addrCtrl.text.trim();
    if (q.isEmpty) {
      setState(() { _suggestions = []; _showSuggestions = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await SupabaseService.placesAutocomplete(q);
      if (mounted) setState(() { _suggestions = results; _showSuggestions = results.isNotEmpty; });
    });
  }

  Future<void> _selectPlace(Map<String, dynamic> suggestion) async {
    setState(() { _showSuggestions = false; _suggestions = []; });
    final details = await SupabaseService.placeDetails(suggestion['place_id'] as String);
    if (!mounted) return;
    setState(() {
      _addrCtrl.text = details?['address'] as String? ?? suggestion['description'] as String;
      _lat = details?['lat'] as double?;
      _lng = details?['lng'] as double?;
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await SupabaseService.updateBusiness(
        widget.business.id,
        name: name,
        category: _category,
        address: _addrCtrl.text.trim().isEmpty ? null : _addrCtrl.text.trim(),
        lat: _lat,
        lng: _lng,
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not save. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final accentOn = Theme.of(context).brightness == Brightness.dark
        ? QubyColors.accentGreenOnDark
        : QubyColors.accentGreenOnLight;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, insets + bottomPad + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Edit Business',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.textColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon:
                    Icon(Icons.close, color: widget.dimColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_error.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: QubyColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: QubyColors.danger.withValues(alpha: 0.2)),
              ),
              child: Text(_error,
                  style: GoogleFonts.plusJakartaSans(
                      color: QubyColors.danger, fontSize: 13)),
            ),
            const SizedBox(height: 14),
          ],

          Text('Business Name',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.dimColor)),
          const SizedBox(height: 8),
          _field(_nameCtrl, 'Business name'),
          const SizedBox(height: 14),

          Text('Category',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.dimColor)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: widget.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              dropdownColor: widget.surface,
              underline: const SizedBox.shrink(),
              icon:
                  Icon(Icons.keyboard_arrow_down, color: widget.dimColor),
              style: GoogleFonts.plusJakartaSans(
                  color: widget.textColor, fontSize: 14),
              onChanged: (v) => setState(() => _category = v!),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),

          Text('Location',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.dimColor)),
          const SizedBox(height: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _field(_addrCtrl, 'Search address or place…'),
              if (_showSuggestions)
                Positioned(
                  top: 52,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: widget.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: widget.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: widget.border),
                        itemBuilder: (context, i) {
                          final s = _suggestions[i];
                          return InkWell(
                            onTap: () => _selectPlace(s),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 16, color: widget.accent),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      s['description'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: widget.textColor),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_lat != null && _lng != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.check_circle_outline,
                  size: 13, color: widget.accent),
              const SizedBox(width: 5),
              Text(
                'Pinned: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: widget.accent),
              ),
            ]),
          ],
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accent,
                foregroundColor: accentOn,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: accentOn),
                    )
                  : Text(
                      'Save Changes',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        style: GoogleFonts.plusJakartaSans(
            color: widget.textColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: widget.dimColor, fontSize: 14),
          filled: true,
          fillColor: widget.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: widget.accent, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
