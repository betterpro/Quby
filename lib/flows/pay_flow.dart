import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/qr_payment.dart';
import '../widgets/common.dart';
import '../widgets/q_icon.dart';

class PayFlow extends StatefulWidget {
  final Business? business;

  const PayFlow({super.key, this.business});

  @override
  State<PayFlow> createState() => _PayFlowState();
}

class _PayFlowState extends State<PayFlow> {
  /// 0 = scan, 1 = amount/confirm, 2 = processing, 3 = success
  int _step = 0;
  final String _method = 'qr';
  String _amount = '';
  Business? _biz;
  bool _amountFromQr = false;
  bool _resolving = false;
  bool _scanHandled = false;
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _biz = widget.business;
    if (_biz != null) {
      _step = 1;
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  double get _value => double.tryParse(_amount) ?? 0.0;

  void _onKey(String k) {
    setState(() {
      if (k == '⌫') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (k == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.length >= 7) {
        return;
      } else {
        _amount += k;
      }
    });
  }

  String _formatPresetAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    if (_scanHandled || _step != 0 || _resolving) return;

    final raw =
        capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (raw == null) return;

    final payload = QrPaymentPayload.tryParse(raw);
    if (payload == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unrecognized QR code. Try a Quby merchant code.')),
      );
      return;
    }

    _scanHandled = true;
    setState(() => _resolving = true);
    final state = context.read<AppState>();
    await _scannerController.stop();

    if (!mounted) return;
    final biz = await state.resolveBusiness(payload.businessId);

    if (!mounted) return;

    if (biz == null) {
      _scanHandled = false;
      setState(() => _resolving = false);
      if (!mounted) return;
      await _scannerController.start();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Merchant not found. Check the QR code and try again.')),
      );
      return;
    }

    final presetAmount = payload.amount;
    setState(() {
      _biz = biz;
      _resolving = false;
      _amountFromQr = presetAmount != null && presetAmount > 0;
      if (_amountFromQr) {
        _amount = _formatPresetAmount(presetAmount!);
      } else {
        _amount = '';
      }
      _step = 1;
    });
  }

  void _pay(AppState state) {
    final biz = _biz;
    if (_value <= 0 || biz == null) return;
    if (_value > state.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance. Top up your wallet first.'),
        ),
      );
      return;
    }
    setState(() => _step = 2);
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      try {
        context.read<AppState>().pay(
              businessId: biz.id,
              amount: _value,
              method: _method,
            );
        setState(() => _step = 3);
      } catch (_) {
        setState(() => _step = 1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient balance. Top up your wallet first.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? QubyColors.textDark : QubyColors.textLight;
    final dimColor = isDark ? QubyColors.textDimDark : QubyColors.textDimLight;
    final accent =
        isDark ? QubyColors.accentGreenDark : QubyColors.accentGreenLight;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return FlowSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_step == 0)
                _buildScanner(context, isDark, textColor, dimColor, accent),
              if (_step == 1 && _biz != null)
                _amountFromQr
                    ? _buildConfirm(
                        context, _biz!, isDark, textColor, dimColor, accent)
                    : _buildAmountEntry(
                        context, _biz!, isDark, textColor, dimColor, accent),
              if (_step == 2) _buildProcessing(isDark, accent, textColor),
              if (_step == 3 && _biz != null)
                _buildSuccess(context, _biz!, isDark, accent, textColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanner(
    BuildContext context,
    bool isDark,
    Color text,
    Color dim,
    Color accent,
  ) {
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;
    final surface2 =
        isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan to pay',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Point your camera at the merchant\'s Quby QR code',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: dim),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onQrDetected,
                  ),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: border, width: 0.5),
                      ),
                      child: CustomPaint(painter: _ScanOverlayPainter(accent)),
                    ),
                  ),
                  if (_resolving)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Loading merchant…',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Row(
              children: [
                qIcon('qr', 18, accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'The amount may be included on the QR, or you\'ll enter it next.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: dim,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          QubyBtn(
            label: 'Cancel',
            primary: false,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountEntry(
    BuildContext context,
    Business biz,
    bool isDark,
    Color text,
    Color dim,
    Color accent,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          _buildMerchantHeader(biz, text, dim),
          const SizedBox(height: 20),
          Text('Enter amount',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: dim)),
          const SizedBox(height: 16),
          AmountDisplay(amount: _amount),
          const SizedBox(height: 24),
          NumPad(onKey: _onKey),
          const SizedBox(height: 16),
          QubyBtn(
            label: _value > 0
                ? 'Pay \$${_value.toStringAsFixed(2)}'
                : 'Enter amount',
            onTap: _value > 0 ? () => _pay(context.read<AppState>()) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirm(
    BuildContext context,
    Business biz,
    bool isDark,
    Color text,
    Color dim,
    Color accent,
  ) {
    final surface2 =
        isDark ? QubyColors.surface2Dark : QubyColors.surface2Light;
    final border = isDark ? QubyColors.lineDark : QubyColors.lineLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          _buildMerchantHeader(biz, text, dim),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Column(
              children: [
                Text('Amount due',
                    style:
                        GoogleFonts.plusJakartaSans(fontSize: 13, color: dim)),
                const SizedBox(height: 8),
                Text(
                  '\$${_value.toStringAsFixed(2)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: text,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'From merchant QR',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: dim),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          QubyBtn(
            label: 'Pay \$${_value.toStringAsFixed(2)}',
            onTap: () => _pay(context.read<AppState>()),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantHeader(Business biz, Color text, Color dim) {
    return Row(
      children: [
        BusinessLogo(biz: biz, size: 40, iconSize: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                biz.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: text,
                ),
              ),
              Text(
                biz.cat,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: dim),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessing(bool isDark, Color accent, Color text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: accent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Processing payment…',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(
    BuildContext context,
    Business biz,
    bool isDark,
    Color accent,
    Color text,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: qIcon('check', 28, accent)),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment sent!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${_value.toStringAsFixed(2)} to ${biz.name}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? QubyColors.textDimDark : QubyColors.textDimLight,
            ),
          ),
          const SizedBox(height: 28),
          QubyBtn(label: 'Done', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    const frameSize = 200.0;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;
    final frame = Rect.fromLTWH(left, top, frameSize, frameSize);

    final overlay = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(frame, const Radius.circular(16)),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, overlay, hole),
      paint,
    );

    final corner = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    canvas.drawLine(
        frame.topLeft, frame.topLeft + const Offset(len, 0), corner);
    canvas.drawLine(
        frame.topLeft, frame.topLeft + const Offset(0, len), corner);
    canvas.drawLine(
      frame.topRight,
      frame.topRight + const Offset(-len, 0),
      corner,
    );
    canvas.drawLine(
      frame.topRight,
      frame.topRight + const Offset(0, len),
      corner,
    );
    canvas.drawLine(
      frame.bottomLeft,
      frame.bottomLeft + const Offset(len, 0),
      corner,
    );
    canvas.drawLine(
      frame.bottomLeft,
      frame.bottomLeft + const Offset(0, -len),
      corner,
    );
    canvas.drawLine(
      frame.bottomRight,
      frame.bottomRight + const Offset(-len, 0),
      corner,
    );
    canvas.drawLine(
      frame.bottomRight,
      frame.bottomRight + const Offset(0, -len),
      corner,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
