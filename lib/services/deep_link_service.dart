import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';
import '../screens/biz_detail_screen.dart';
import '../screens/business_settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_business_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/splits/group_detail_screen.dart';
import '../services/supabase_service.dart';

// Tabs in MainShell (IndexedStack order)
const _kTabHome     = 0;
const _kTabExplore  = 1;
const _kTabSplits   = 2;
const _kTabActivity = 3;

class DeepLinkService {
  DeepLinkService._();

  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  // Registered by MainShell on mount
  static void Function(int tab)? _switchTab;
  static VoidCallback? _openPay;

  static final _navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static void registerShell({
    required void Function(int) switchTab,
    required VoidCallback openPay,
  }) {
    _switchTab = switchTab;
    _openPay = openPay;
  }

  static Future<void> initialize() async {
    // Link that cold-started the app
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      // Delay so the widget tree is fully mounted first
      Future.delayed(const Duration(milliseconds: 300), () => _handle(initial));
    }

    _sub = _appLinks.uriLinkStream.listen(_handle);
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
    _switchTab = null;
    _openPay = null;
  }

  static void _handle(Uri uri) {
    if (uri.scheme != 'quby') return;

    final host = uri.host;          // e.g. "explore"
    final segments = uri.pathSegments; // e.g. ["business", "abc123"]

    switch (host) {
      case 'home':
        _switchTab?.call(_kTabHome);

      case 'explore':
        if (segments.length >= 2 && segments[0] == 'business') {
          _openBusiness(segments[1]);
        } else {
          _switchTab?.call(_kTabExplore);
        }

      case 'pay':
        _openPay?.call();

      case 'splits':
        if (segments.isNotEmpty) {
          _openGroup(segments[0]);
        } else {
          _switchTab?.call(_kTabSplits);
        }

      case 'activity':
        _switchTab?.call(_kTabActivity);

      case 'profile':
        _push(const ProfileScreen());

      case 'rewards':
        _push(const RewardsScreen());

      case 'business':
        if (segments.isNotEmpty && segments[0] == 'register') {
          _push(const RegisterBusinessScreen());
        } else {
          _push(const BusinessSettingsScreen());
        }

      // Supabase auth callback — handled internally by Supabase SDK
      case 'login-callback':
        break;
    }
  }

  static Future<void> _openBusiness(String id) async {
    final biz = await SupabaseService.getBusiness(id);
    if (biz == null) return;
    _push(BizDetailScreen(biz: biz));
  }

  static Future<void> _openGroup(String id) async {
    final groups = await SupabaseService.getGroups();
    final group = groups.cast<Group?>().firstWhere(
          (g) => g?.id == id,
          orElse: () => null,
        );
    if (group == null) return;
    _push(GroupDetailScreen(group: group));
  }

  static void _push(Widget screen) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
