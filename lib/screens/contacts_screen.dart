import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../services/supabase_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/q_icon.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  void _showAddContact(BuildContext context) {
    final state = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: state,
        child: const _AddContactSheet(),
      ),
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
          final contacts = state.contacts
              .where((c) => c.id != state.me.id)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

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
                  'Friends',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _showAddContact(context),
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
                              'Add',
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
                  ),
                ],
              ),
              if (contacts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: qIcon('users', 36, accent),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No friends yet',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Search for Quby users by name or handle to add them as friends.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: dimColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: () => _showAddContact(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 13),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Find friends',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final contact = contacts[i];
                        return _ContactTile(
                          contact: contact,
                          surface: surface,
                          border: border,
                          textColor: textColor,
                          dimColor: dimColor,
                          accent: accent,
                          onDelete: () =>
                              context.read<AppState>().removeContact(contact.id),
                        );
                      },
                      childCount: contacts.length,
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

class _ContactTile extends StatelessWidget {
  final Contact contact;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color dimColor;
  final Color accent;
  final VoidCallback onDelete;

  const _ContactTile({
    required this.contact,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.dimColor,
    required this.accent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Avatar(initials: contact.initials, color: contact.color, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (contact.handle.isNotEmpty)
                  Text(
                    '@${contact.handle}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: dimColor,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Remove friend?'),
                  content:
                      Text('Remove ${contact.name} from your contacts?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) onDelete();
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: QubyColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: qIcon('close', 16, QubyColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet();

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<UserSearchResult> _results = [];
  bool _loading = false;
  String? _error;
  final Set<String> _added = {};

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value));
  }

  Future<void> _search(String q) async {
    try {
      final results = await SupabaseService.searchUsers(query: q.trim());
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _addContact(UserSearchResult user) async {
    final err =
        await context.read<AppState>().addContactFromSearch(user);
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
    } else {
      setState(() => _added.add(user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? QubyColors.surfaceDark : QubyColors.surfaceLight;
    final surface2 =
        isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
              'Find Friends',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: _onChanged,
              style:
                  GoogleFonts.plusJakartaSans(fontSize: 15, color: textColor),
              decoration: InputDecoration(
                hintText: 'Search by name or @handle',
                filled: true,
                fillColor: surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: qIcon('search', 18, dimColor),
                ),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: QubyColors.danger),
              ),
            ],
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: border),
                  itemBuilder: (context, i) {
                    final user = _results[i];
                    final isAdded = _added.contains(user.id);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Avatar(
                            initials: user.initials,
                            color: user.color,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                if (user.handle.isNotEmpty)
                                  Text(
                                    '@${user.handle}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: dimColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: isAdded ? null : () => _addContact(user),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isAdded
                                    ? accent.withValues(alpha: 0.12)
                                    : accent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isAdded ? 'Added' : 'Add',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isAdded ? accent : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else if (_ctrl.text.length >= 2 && !_loading) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'No users found',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: dimColor,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
