import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Map<String, String> _iconPaths = {
  'home':
      '<path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V20h14V9.5"/><path d="M9.5 20v-5h5v5"/>',
  'scan':
      '<path d="M4 8V6a2 2 0 0 1 2-2h2M16 4h2a2 2 0 0 1 2 2v2M20 16v2a2 2 0 0 1-2 2h-2M8 20H6a2 2 0 0 1-2-2v-2"/><path d="M4 12h16"/>',
  'pin':
      '<path d="M12 21s7-5.5 7-11a7 7 0 0 0-14 0c0 5.5 7 11 7 11Z"/><circle cx="12" cy="10" r="2.5" fill="none" stroke="CURRENTSTROKE"/>',
  'users':
      '<circle cx="9" cy="8" r="3.5"/><path d="M3 19.5c1-3 3.3-4.5 6-4.5s5 1.5 6 4.5"/><path d="M16 5.2A3.5 3.5 0 0 1 16 12M18 19.5c-.3-2-1-3.3-2.2-4.3"/>',
  'activity':
      '<path d="M4 7h11M4 12h16M4 17h8"/><circle cx="19" cy="7" r="1.4" fill="FILL" stroke="none"/><circle cx="16" cy="17" r="1.4" fill="FILL" stroke="none"/>',
  'plus': '<path d="M12 5v14M5 12h14"/>',
  'up': '<path d="M12 19V5M6 11l6-6 6 6"/>',
  'down': '<path d="M12 5v14M6 13l6 6 6-6"/>',
  'send': '<path d="M21 4 3 11l7 2.5L13 21l8-17Z"/><path d="m10 13.5 4-4"/>',
  'card':
      '<rect x="3" y="5.5" width="18" height="13" rx="2.5"/><path d="M3 9.5h18M6.5 14.5h3"/>',
  'bank':
      '<path d="M4 10h16M5 10 12 4l7 6M6 10v7M10 10v7M14 10v7M18 10v7M4 20h16"/>',
  'coffee':
      '<path d="M5 8h12v5a5 5 0 0 1-5 5H10a5 5 0 0 1-5-5V8Z"/><path d="M17 9h2.2a2.3 2.3 0 0 1 0 4.6H17"/>',
  'croissant':
      '<path d="M3.5 16.5C7 18 11 18.2 14 17l-2-4.5L3.5 16.5Z"/><path d="M20.5 16.5C17 18 13 18.2 10 17l2-4.5 8.5 4ZM12 12.5 9 6c4-2 6-2 6 0l-3 6.5Z"/>',
  'store':
      '<path d="M4 9.5 5.5 4h13L20 9.5M4 9.5h16M4 9.5v10h16v-10M4 9.5a2.5 2.5 0 0 0 5 0 2.5 2.5 0 0 0 5 0 2.5 2.5 0 0 0 5 0"/><path d="M9 20v-5h6v5"/>',
  'star':
      '<path d="M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8L12 16.9 6.8 19.6l1-5.8-4.3-4.1 5.9-.9L12 3.5Z"/>',
  'gift':
      '<rect x="4" y="9" width="16" height="11" rx="1.5"/><path d="M4 13h16M12 9v11"/><path d="M12 9S10.5 4 8 4.5 9 9 12 9Zm0 0s1.5-5 4-4.5S15 9 12 9Z"/>',
  'settings':
      '<circle cx="12" cy="12" r="3"/><path d="M12 2.5v3M12 18.5v3M21.5 12h-3M5.5 12h-3M18.4 5.6l-2.1 2.1M7.7 16.3l-2.1 2.1M18.4 18.4l-2.1-2.1M7.7 7.7 5.6 5.6"/>',
  'chart':
      '<path d="M4 20V4M4 20h16"/><path d="m7 15 3.5-4 3 2.5L20 7"/>',
  'wallet':
      '<path d="M4 7.5A2.5 2.5 0 0 1 6.5 5H18v3"/><rect x="4" y="7.5" width="16" height="12" rx="2.5"/><circle cx="16.5" cy="13.5" r="1.3" fill="FILL" stroke="none"/>',
  'back': '<path d="m15 6-6 6 6 6"/>',
  'close': '<path d="M6 6l12 12M18 6 6 18"/>',
  'check': '<path d="m5 12.5 4.5 4.5L19 7"/>',
  'bell':
      '<path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Z"/><path d="M10 19a2 2 0 0 0 4 0"/>',
  'search':
      '<circle cx="11" cy="11" r="6.5"/><path d="m20 20-3.5-3.5"/>',
  'filter': '<path d="M4 6h16M7 12h10M10 18h4"/>',
  'more':
      '<circle cx="5" cy="12" r="1.4" fill="FILL" stroke="none"/><circle cx="12" cy="12" r="1.4" fill="FILL" stroke="none"/><circle cx="19" cy="12" r="1.4" fill="FILL" stroke="none"/>',
  'chevron': '<path d="m9 6 6 6-6 6"/>',
  'chevronDown': '<path d="m6 9 6 6 6-6"/>',
  'user':
      '<circle cx="12" cy="8" r="4"/><path d="M4.5 20c1.2-3.5 4-5 7.5-5s6.3 1.5 7.5 5"/>',
  'shield':
      '<path d="M12 3 5 6v5.5c0 4.3 3 7.5 7 9 4-1.5 7-4.7 7-9V6l-7-3Z"/><path d="m9 12 2 2 4-4"/>',
  'tag':
      '<path d="M3.5 10.5 11 3h7v7l-7.5 7.5a2 2 0 0 1-2.8 0l-4.2-4.2a2 2 0 0 1 0-2.8Z"/><circle cx="14.5" cy="6.5" r="1.2" fill="FILL" stroke="none"/>',
  'sparkle':
      '<path d="M12 3.5c.5 3.5 1.5 4.5 5 5-3.5.5-4.5 1.5-5 5-.5-3.5-1.5-4.5-5-5 3.5-.5 4.5-1.5 5-5Z"/><path d="M18.5 14c.2 1.6.7 2.1 2.3 2.3-1.6.2-2.1.7-2.3 2.3-.2-1.6-.7-2.1-2.3-2.3 1.6-.2 2.1-.7 2.3-2.3Z"/>',
  'contactless':
      '<path d="M7 4.5c2.5 2 4 4.5 4 7.5s-1.5 5.5-4 7.5"/><path d="M11.5 3c3 2.3 4.8 5.4 4.8 9s-1.8 6.7-4.8 9"/><path d="M16 2c3.4 2.6 5.5 6.2 5.5 10s-2.1 7.4-5.5 10" opacity="0.55"/>',
  'qr':
      '<rect x="3.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="3.5" y="13.5" width="7" height="7" rx="1.5"/><path d="M14 14h3v3M20 14v.01M14 20h.01M20 17v3h-3"/>',
  'keypad':
      '<circle cx="6" cy="6" r="1.3" fill="FILL" stroke="none"/><circle cx="12" cy="6" r="1.3" fill="FILL" stroke="none"/><circle cx="18" cy="6" r="1.3" fill="FILL" stroke="none"/><circle cx="6" cy="12" r="1.3" fill="FILL" stroke="none"/><circle cx="12" cy="12" r="1.3" fill="FILL" stroke="none"/><circle cx="18" cy="12" r="1.3" fill="FILL" stroke="none"/><circle cx="6" cy="18" r="1.3" fill="FILL" stroke="none"/><circle cx="12" cy="18" r="1.3" fill="FILL" stroke="none"/><circle cx="18" cy="18" r="1.3" fill="FILL" stroke="none"/>',
  'receipt':
      '<path d="M6 3.5h12v17l-2.5-1.5L13 21l-2.5-1.5L8 21l-2.5-1.5L6 3.5Z"/><path d="M9 8h6M9 12h6"/>',
  'logout':
      '<path d="M14 5H6.5A1.5 1.5 0 0 0 5 6.5v11A1.5 1.5 0 0 0 6.5 19H14"/><path d="M17 8.5 20.5 12 17 15.5M20 12H10"/>',
};

String _colorHex(Color color) {
  final r = color.red.toRadixString(16).padLeft(2, '0');
  final g = color.green.toRadixString(16).padLeft(2, '0');
  final b = color.blue.toRadixString(16).padLeft(2, '0');
  return '#$r$g$b';
}

Widget qIcon(String name, double size, Color color) {
  final hex = _colorHex(color);
  String pathData = _iconPaths[name] ?? '<path d="M12 12"/>';
  // Replace fill and stroke placeholders
  pathData = pathData.replaceAll('fill="FILL"', 'fill="$hex"');
  pathData = pathData.replaceAll('stroke="CURRENTSTROKE"', 'stroke="$hex"');

  final svg =
      '<svg viewBox="0 0 24 24" fill="none" stroke="$hex" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">$pathData</svg>';
  return SvgPicture.string(svg, width: size, height: size);
}
