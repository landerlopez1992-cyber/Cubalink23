import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentApi {
  static const base = 'https://cubalink23-payments.onrender.com';

  static Future<List<CardOnFile>> listCards(String customerId) async {
    final r = await http.get(Uri.parse('$base/api/cards/list?customer_id=$customerId'));
    if (r.statusCode != 200) {
      throw Exception('Error loading cards: ${r.statusCode}');
    }
    final j = jsonDecode(r.body) as List;
    return j.map((e) => CardOnFile.fromJson(e)).toList();
  }

  static Future<PaymentResult> chargeOnFile({
    required String customerId,
    required String cardId,
    required int amountCents,
    String currency = 'USD',
    String note = 'CubaLink23',
  }) async {
    final r = await http.post(
      Uri.parse('$base/api/payments/charge-onfile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_id': customerId,
        'card_id': cardId,
        'amount_money': {'amount': amountCents, 'currency': currency},
        'note': note
      }),
    );
    return PaymentResult.fromJson(jsonDecode(r.body));
  }

  static Future<PaymentResult> processWithNonce({
    required String nonce,
    required int amountCents,
    String currency = 'USD',
    String note = 'CubaLink23',
  }) async {
    final r = await http.post(
      Uri.parse('$base/api/payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nonce': nonce,
        'amount_cents': amountCents,
        'currency': currency,
        'note': note
      }),
    );
    
    final responseData = jsonDecode(r.body);
    
    // Si hay error, devolverlo
    if (r.statusCode != 200 || responseData.containsKey('error')) {
      return PaymentResult(
        status: 'FAILED',
        code: responseData['error']?['errors']?[0]?['code'] ?? 'PAYMENT_ERROR',
        message: responseData['error']?['errors']?[0]?['detail'] ?? 'Error procesando pago',
      );
    }
    
    return PaymentResult.fromJson(responseData);
  }
}

class CardOnFile {
  final String id, brand, last4;
  final int expMonth, expYear;
  
  CardOnFile({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });
  
  factory CardOnFile.fromJson(Map<String, dynamic> j) => CardOnFile(
    id: j['card_id'],
    brand: j['brand'],
    last4: j['last4'],
    expMonth: j['exp_month'],
    expYear: j['exp_year'],
  );
}

class PaymentResult {
  final String status;
  final String? code;
  final String? message;
  final String? receiptUrl;
  final String? paymentId;
  
  PaymentResult({
    required this.status,
    this.code,
    this.message,
    this.receiptUrl,
    this.paymentId,
  });
  
  factory PaymentResult.fromJson(Map<String, dynamic> j) => PaymentResult(
    status: j['status'],
    code: j['code'],
    message: j['message'],
    receiptUrl: j['receipt_url'],
    paymentId: j['id'] ?? j['payment_id'],
  );
  
  bool get isSuccess => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
}
