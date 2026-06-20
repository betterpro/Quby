import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardBrandLogos extends StatelessWidget {
  final double height;

  const CardBrandLogos({super.key, this.height = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BrandBadge(height: height, child: _visaSvg()),
        SizedBox(width: height * 0.35),
        _BrandBadge(height: height, child: _mastercardSvg()),
        SizedBox(width: height * 0.35),
        _BrandBadge(height: height, child: _amexSvg()),
      ],
    );
  }

  Widget _visaSvg() => SvgPicture.string(
        '<svg viewBox="0 0 48 16" xmlns="http://www.w3.org/2000/svg">'
        '<rect width="48" height="16" rx="2" fill="#1A1F71"/>'
        '<path fill="#FFFFFF" d="M19.2 11.2 21 4.8h2.1l-2.7 6.4h-2.1Zm8.8-4.4c-.4-.2-.9-.3-1.6-.3-1.8 0-3 1-3 2.4 0 1 1 1.6 1.8 1.9.8.4 1.1.6 1.1 1 0 .5-.7.8-1.3.8-.9 0-1.4-.1-2.1-.5l-.3-.2-.3 1.8c.5.2 1.4.4 2.4.4 1.9 0 3.1-.9 3.1-2.5 0-.8-.5-1.4-1.6-1.9-.7-.3-1.1-.5-1.1-.8 0-.3.3-.6 1-.6.6 0 1 .1 1.3.3l.2.1.3-1.7ZM35.5 4.8 33.6 11.2h-2L29.7 4.8h2.1l1 5.2 2.4-5.2h2.3Zm-14.2 0 3.4 6.4-.4-1.9c-.7 1.3-1.8 2.1-3.2 2.6l1.8-7.1h2.2l-.8-.1Z"/>'
        '</svg>',
      );

  Widget _mastercardSvg() => SvgPicture.string(
        '<svg viewBox="0 0 48 16" xmlns="http://www.w3.org/2000/svg">'
        '<rect width="48" height="16" rx="2" fill="#FFFFFF" stroke="#E5E7EB" stroke-width="0.5"/>'
        '<circle cx="19" cy="8" r="5" fill="#EB001B"/>'
        '<circle cx="29" cy="8" r="5" fill="#F79E1B" fill-opacity="0.95"/>'
        '</svg>',
      );

  Widget _amexSvg() => SvgPicture.string(
        '<svg viewBox="0 0 48 16" xmlns="http://www.w3.org/2000/svg">'
        '<rect width="48" height="16" rx="2" fill="#006FCF"/>'
        '<path fill="#FFFFFF" d="M8.5 5.5 6.5 10.5h1.3l.4-1h2.2l.4 1h1.4L9.8 5.5H8.5Zm-.2 2.7.7-1.8.7 1.8h-1.4Zm4.2-2.7v5h2.6l.3-.8h1.5l.3.8H20V5.5h-2.1l-1 2.8-1-2.8h-2.2Zm2.2 3 .6-1.6.6 1.6h-1.2Zm5.5-3v5h3.8v-1.1h-2.5V9.2h2.3V8.1h-2.3V6.6h2.4V5.5h-3.7Zm6.2 0-1.8 5h1.3l.3-.8h2.2l.3.8h1.4l-1.8-5h-2.9Zm-.2 2.7.7-1.8.7 1.8h-1.4Z"/>'
        '</svg>',
      );
}

class _BrandBadge extends StatelessWidget {
  final double height;
  final Widget child;

  const _BrandBadge({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: child,
      ),
    );
  }
}
