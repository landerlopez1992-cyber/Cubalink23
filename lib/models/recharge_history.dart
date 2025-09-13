enum RechargeStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum PaymentMethod {
  paypal,
  creditCard,
  bankTransfer,
  wallet,
}

class RechargeHistory {
  final String id;
  final String userId;
  final String phoneNumber;
  final String operator;
  final String operatorId;
  final double amount;
  final DateTime timestamp;
  final DateTime createdAt;
  final String status;
  final String transactionId;
  final String? paymentMethod;
  final double? fee;
  final double? total;

  RechargeHistory({
    required this.id,
    required this.userId,
    required this.phoneNumber,
    required this.operator,
    required this.operatorId,
    required this.amount,
    required this.timestamp,
    required this.createdAt,
    required this.status,
    required this.transactionId,
    this.paymentMethod,
    this.fee,
    this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'phoneNumber': phoneNumber,
      'phone_number': phoneNumber,
      'operator': operator,
      'operator_id': operatorId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'transaction_id': transactionId,
      'payment_method': paymentMethod,
      'fee': fee,
      'total': total,
    };
  }

  factory RechargeHistory.fromJson(Map<String, dynamic> json) {
    return RechargeHistory(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '',
      operator: json['operator'] ?? '',
      operatorId: json['operator_id'] ?? json['operatorId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      timestamp: json['timestamp'] is String ? DateTime.parse(json['timestamp']) : DateTime.now(),
      createdAt: json['created_at'] is String ? DateTime.parse(json['created_at']) : DateTime.now(),
      status: json['status'] ?? 'completed',
      transactionId: json['transaction_id'] ?? json['transactionId'] ?? '',
      paymentMethod: json['payment_method'] ?? json['paymentMethod'],
      fee: json['fee']?.toDouble(),
      total: json['total']?.toDouble(),
    );
  }

  /// Método estático para obtener historial de muestra
  static List<RechargeHistory> getSampleHistory() {
    final now = DateTime.now();
    return [
      RechargeHistory(
        id: 'rh_001',
        userId: 'user_001',
        phoneNumber: '+52 55 1234 5678',
        operator: 'Telcel',
        operatorId: 'telcel_mx',
        amount: 100,
        timestamp: now.subtract(Duration(hours: 2)),
        createdAt: now.subtract(Duration(hours: 2)),
        status: 'completed',
        transactionId: 'square_001',
        paymentMethod: 'square',
        fee: 4.99,
        total: 104.99,
      ),
      RechargeHistory(
        id: 'rh_002',
        userId: 'user_001',
        phoneNumber: '+53 5 234 5678',
        operator: 'CubaCel',
        operatorId: 'cubacel_cu',
        amount: 500,
        timestamp: now.subtract(Duration(minutes: 30)),
        createdAt: now.subtract(Duration(minutes: 30)),
        status: 'pending',
        transactionId: 'square_002',
        paymentMethod: 'square',
        fee: 21.99,
        total: 521.99,
      ),
      RechargeHistory(
        id: 'rh_003',
        userId: 'user_001',
        phoneNumber: '+1 305 123 4567',
        operator: 'AT&T',
        operatorId: 'att_us',
        amount: 25,
        timestamp: now.subtract(Duration(days: 1)),
        createdAt: now.subtract(Duration(days: 1)),
        status: 'completed',
        transactionId: 'square_003',
        paymentMethod: 'square',
        fee: 1.99,
        total: 26.99,
      ),
    ];
  }
}

class RechargeTransaction {
  final String id;
  final String recipientPhone;
  final String recipientName;
  final String countryCode;
  final String operatorId;
  final double amount;
  final double cost;
  final RechargeStatus status;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionReference;

  RechargeTransaction({
    required this.id,
    required this.recipientPhone,
    required this.recipientName,
    required this.countryCode,
    required this.operatorId,
    required this.amount,
    required this.cost,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.completedAt,
    this.transactionReference,
  });

  RechargeTransaction copyWith({
    String? id,
    String? recipientPhone,
    String? recipientName,
    String? countryCode,
    String? operatorId,
    double? amount,
    double? cost,
    RechargeStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    DateTime? completedAt,
    String? transactionReference,
  }) {
    return RechargeTransaction(
      id: id ?? this.id,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      countryCode: countryCode ?? this.countryCode,
      operatorId: operatorId ?? this.operatorId,
      amount: amount ?? this.amount,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      transactionReference: transactionReference ?? this.transactionReference,
    );
  }

  String get statusText {
    switch (status) {
      case RechargeStatus.pending:
        return 'Pendiente';
      case RechargeStatus.completed:
        return 'Completada';
      case RechargeStatus.failed:
        return 'Fallida';
      case RechargeStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.creditCard:
        return 'Tarjeta de Crédito';
      case PaymentMethod.bankTransfer:
        return 'Transferencia Bancaria';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientPhone': recipientPhone,
      'recipientName': recipientName,
      'countryCode': countryCode,
      'operatorId': operatorId,
      'amount': amount,
      'cost': cost,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionReference': transactionReference,
    };
  }
  
  /// Alias for toJson() for compatibility
  Map<String, dynamic> toMap() => toJson();

  factory RechargeTransaction.fromJson(Map<String, dynamic> json) {
    return RechargeTransaction(
      id: json['id'],
      recipientPhone: json['recipientPhone'],
      recipientName: json['recipientName'],
      countryCode: json['countryCode'],
      operatorId: json['operatorId'],
      amount: json['amount'].toDouble(),
      cost: json['cost'].toDouble(),
      status: RechargeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RechargeStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.paypal,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      transactionReference: json['transactionReference'],
    );
  }

  static List<RechargeTransaction> getSampleTransactions() {
    return [
      RechargeTransaction(
        id: 'tx_001',
        recipientPhone: '+52 55 1234 5678',
        recipientName: 'María González',
        countryCode: 'MX',
        operatorId: 'telcel_mx',
        amount: 100,
        cost: 104.99,
        status: RechargeStatus.completed,
        paymentMethod: PaymentMethod.paypal,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        completedAt: DateTime.now().subtract(Duration(hours: 2, minutes: 5)),
        transactionReference: 'TXN123456789',
      ),
      RechargeTransaction(
        id: 'tx_002',
        recipientPhone: '+53 5 234 5678',
        recipientName: 'Carlos Herrera',
        countryCode: 'CU',
        operatorId: 'cubacel_cu',
        amount: 500,
        cost: 21.99,
        status: RechargeStatus.pending,
        paymentMethod: PaymentMethod.creditCard,
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        transactionReference: 'TXN987654321',
      ),
      RechargeTransaction(
        id: 'tx_003',
        recipientPhone: '+1 305 123 4567',
        recipientName: 'Ana Pérez',
        countryCode: 'US',
        operatorId: 'att_us',
        amount: 25,
        cost: 26.99,
        status: RechargeStatus.completed,
        paymentMethod: PaymentMethod.creditCard,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        completedAt: DateTime.now().subtract(Duration(days: 1, minutes: 3)),
        transactionReference: 'TXN456789123',
      ),
    ];
  }
}