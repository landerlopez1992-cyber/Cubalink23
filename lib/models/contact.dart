class Contact {
  final String id;
  final String name;
  final String phone;
  final String countryCode;
  final String operatorId;
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.countryCode,
    required this.operatorId,
    required this.createdAt,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? countryCode,
    String? operatorId,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      operatorId: operatorId ?? this.operatorId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'countryCode': countryCode,
      'operatorId': operatorId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      countryCode: json['countryCode'],
      operatorId: json['operatorId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static List<Contact> getSampleContacts() {
    return [
      Contact(
        id: '1',
        name: 'María González',
        phone: '5512345678',
        countryCode: 'MX',
        operatorId: 'telcel_mx',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      Contact(
        id: '2',
        name: 'Carlos Rodríguez',
        phone: '5587654321',
        countryCode: 'MX',
        operatorId: 'movistar_mx',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
      ),
      Contact(
        id: '3',
        name: 'Ana Pérez',
        phone: '3051234567',
        countryCode: 'US',
        operatorId: 'att_us',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
      ),
    ];
  }
}