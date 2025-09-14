import 'package:cubalink23/models/payment_card.dart';

// Type alias for compatibility with existing code
typedef UserModel = User;

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  double balance;
  final List<PaymentCard> paymentCards;
  final String? profilePhotoUrl;
  final String? profileImageUrl;
  final String? address;
  final String role;
  bool isBlocked;
  final String? status;
  final DateTime? registrationDate;
  final String? referralCode;  // Código único del usuario para compartir
  final String? referredBy;    // ID del usuario que lo refirió
  final bool hasUsedService;   // Si ya usó algún servicio (para activar recompensa)
  final List<String> referredUsers; // Lista de usuarios referidos
  final DateTime? rewardDate;  // Fecha cuando recibió su última recompensa
  final String? country;       // País del usuario
  final String? city;          // Ciudad del usuario

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.balance = 0.0,
    this.paymentCards = const [],
    this.profilePhotoUrl,
    this.profileImageUrl,
    this.address,
    this.role = 'Usuario',
    this.isBlocked = false,
    this.status,
    DateTime? registrationDate,
    this.referralCode,
    this.referredBy,
    this.hasUsedService = false,
    this.referredUsers = const [],
    this.rewardDate,
    this.country,
    this.city,
  }) : registrationDate = registrationDate ?? createdAt;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    double? balance,
    List<PaymentCard>? paymentCards,
    String? profilePhotoUrl,
    String? profileImageUrl,
    String? address,
    String? role,
    bool? isBlocked,
    String? status,
    DateTime? registrationDate,
    String? referralCode,
    String? referredBy,
    bool? hasUsedService,
    List<String>? referredUsers,
    DateTime? rewardDate,
    String? country,
    String? city,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      balance: balance ?? this.balance,
      paymentCards: paymentCards ?? this.paymentCards,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      hasUsedService: hasUsedService ?? this.hasUsedService,
      referredUsers: referredUsers ?? this.referredUsers,
      rewardDate: rewardDate ?? this.rewardDate,
      country: country ?? this.country,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'balance': balance,
      'paymentCards': paymentCards.map((card) => card.toJson()).toList(),
      'profilePhotoUrl': profilePhotoUrl,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'role': role,
      'isBlocked': isBlocked,
      'status': status,
      'registrationDate': registrationDate?.toIso8601String(),
      'referralCode': referralCode,
      'referredBy': referredBy,
      'hasUsedService': hasUsedService,
      'referredUsers': referredUsers,
      'rewardDate': rewardDate?.toIso8601String(),
      'country': country,
      'city': city,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? 'Usuario',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['createdAt'] is String ? DateTime.parse(json['createdAt']) : DateTime.now(),
      balance: (json['balance'] ?? 0.0).toDouble(),
      paymentCards: (json['paymentCards'] as List<dynamic>?)
          ?.map((cardJson) => PaymentCard.fromJson(cardJson))
          .toList() ?? [],
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['profile_photo_url'],
      profileImageUrl: json['profileImageUrl'] ?? json['profilePhotoUrl'],
      address: json['address'],
      role: json['role'] ?? 'Usuario',
      isBlocked: json['isBlocked'] ?? false,
      status: json['status'] ?? 'Activo',
      registrationDate: json['registrationDate'] is String 
          ? DateTime.parse(json['registrationDate']) 
          : null,
      referralCode: json['referralCode'],
      referredBy: json['referredBy'],
      hasUsedService: json['hasUsedService'] ?? false,
      referredUsers: (json['referredUsers'] as List<dynamic>?)
          ?.map((e) => e.toString()).toList() ?? [],
      rewardDate: json['rewardDate'] is String 
          ? DateTime.parse(json['rewardDate']) 
          : null,
      country: json['country'],
      city: json['city'],
    );
  }
  
  // Método para verificar si el usuario es administrador
  bool get isAdmin => role == 'Administrador';
  
  // Método estático para verificar si un email es administrador
  static bool isAdminEmail(String email) {
    final List<String> adminEmails = [
      'landerlopez1992@gmail.com',
    ];
    return adminEmails.contains(email.toLowerCase().trim());
  }
  
}