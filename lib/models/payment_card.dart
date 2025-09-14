class PaymentCard {
  final String id;
  final String last4;
  final String cardType;
  final String expiryMonth;
  final String expiryYear;
  final String holderName;
  final String? squareCardId;
  final DateTime createdAt;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.last4,
    required this.cardType,
    required this.expiryMonth,
    required this.expiryYear,
    required this.holderName,
    this.squareCardId,
    required this.createdAt,
    this.isDefault = false,
  });

  String get expiryDate => '$expiryMonth/$expiryYear';

  Map<String, dynamic> toJson() => {
    'id': id,
    'last4': last4,
    'cardType': cardType,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'holderName': holderName,
    'squareCardId': squareCardId,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'isDefault': isDefault,
  };
  
  /// Alias for toJson() for compatibility
  Map<String, dynamic> toMap() => toJson();

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreatedAt;
    try {
      if (json['createdAt'] is int) {
        parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
      } else if (json['createdAt'] is String) {
        parsedCreatedAt = DateTime.parse(json['createdAt']);
      } else if (json['createdAt'] != null) {
        // Handle Firestore Timestamp
        parsedCreatedAt = (json['createdAt'] as dynamic).toDate();
      } else {
        parsedCreatedAt = DateTime.now();
      }
    } catch (e) {
      print('Error parsing createdAt for payment card: $e');
      parsedCreatedAt = DateTime.now();
    }
    
    return PaymentCard(
      id: json['id'] ?? '',
      last4: json['last4'] ?? '',
      cardType: json['cardType'] ?? 'Unknown',
      expiryMonth: json['expiryMonth'] ?? '',
      expiryYear: json['expiryYear'] ?? '',
      holderName: json['holderName'] ?? '',
      squareCardId: json['squareCardId'],
      createdAt: parsedCreatedAt,
      isDefault: json['isDefault'] ?? false,
    );
  }

  PaymentCard copyWith({
    String? id,
    String? last4,
    String? cardType,
    String? expiryMonth,
    String? expiryYear,
    String? holderName,
    String? squareCardId,
    DateTime? createdAt,
    bool? isDefault,
  }) => PaymentCard(
    id: id ?? this.id,
    last4: last4 ?? this.last4,
    cardType: cardType ?? this.cardType,
    expiryMonth: expiryMonth ?? this.expiryMonth,
    expiryYear: expiryYear ?? this.expiryYear,
    holderName: holderName ?? this.holderName,
    squareCardId: squareCardId ?? this.squareCardId,
    createdAt: createdAt ?? this.createdAt,
    isDefault: isDefault ?? this.isDefault,
  );
}