import 'dart:convert';

/// Payload encoded in merchant payment QR codes.
///
/// Supported formats:
/// - `quby://pay?business=<id>&amount=<optional>`
/// - `https://pay.qubypay.com/pay?business=<id>&amount=<optional>`
/// - `{"business_id":"<id>","amount":12.5}`
/// - bare business UUID
class QrPaymentPayload {
  const QrPaymentPayload({
    required this.businessId,
    this.amount,
  });

  final String businessId;
  final double? amount;

  static QrPaymentPayload? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('{')) {
      try {
        final map = jsonDecode(trimmed) as Map<String, dynamic>;
        final id = (map['business_id'] ?? map['businessId'] ?? map['business'])
            as String?;
        if (id == null || id.isEmpty) return null;
        return QrPaymentPayload(
          businessId: id,
          amount: _parseAmount(map['amount']),
        );
      } catch (_) {
        return null;
      }
    }

    Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      return null;
    }

    if (uri.scheme == 'quby' && (uri.host == 'pay' || uri.path == '/pay')) {
      return _fromQuery(uri.queryParameters);
    }

    if (uri.host.contains('qubypay') &&
        (uri.path.contains('pay') || uri.path == '/')) {
      return _fromQuery(uri.queryParameters);
    }

    const uuidPattern =
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$';
    if (RegExp(uuidPattern).hasMatch(trimmed)) {
      return QrPaymentPayload(businessId: trimmed);
    }

    return null;
  }

  static QrPaymentPayload? _fromQuery(Map<String, String> params) {
    final id = params['business'] ?? params['business_id'] ?? params['b'];
    if (id == null || id.isEmpty) return null;
    return QrPaymentPayload(
      businessId: id,
      amount: _parseAmount(params['amount'] ?? params['amt']),
    );
  }

  static double? _parseAmount(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  static String encode({required String businessId, double? amount}) {
    return Uri(
      scheme: 'quby',
      host: 'pay',
      queryParameters: {
        'business': businessId,
        if (amount != null && amount > 0) 'amount': amount.toStringAsFixed(2),
      },
    ).toString();
  }
}
