class Country {
  final String code;
  final String name;
  final String prefix;
  final String flag;

  Country({
    required this.code,
    required this.name,
    required this.prefix,
    required this.flag,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'prefix': prefix,
      'flag': flag,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  static List<Country> getCountries() {
    return [
      Country(code: 'MX', name: 'México', prefix: '+52', flag: '🇲🇽'),
      Country(code: 'US', name: 'Estados Unidos', prefix: '+1', flag: '🇺🇸'),
      Country(code: 'CO', name: 'Colombia', prefix: '+57', flag: '🇨🇴'),
      Country(code: 'AR', name: 'Argentina', prefix: '+54', flag: '🇦🇷'),
      Country(code: 'PE', name: 'Perú', prefix: '+51', flag: '🇵🇪'),
      Country(code: 'CL', name: 'Chile', prefix: '+56', flag: '🇨🇱'),
      Country(code: 'VE', name: 'Venezuela', prefix: '+58', flag: '🇻🇪'),
      Country(code: 'EC', name: 'Ecuador', prefix: '+593', flag: '🇪🇨'),
      Country(code: 'CU', name: 'Cuba', prefix: '+53', flag: '🇨🇺'),
    ];
  }
}

class Operator {
  final String id;
  final String name;
  final String logo;
  final String countryCode;
  final List<RechargeAmount> amounts;

  Operator({
    required this.id,
    required this.name,
    required this.logo,
    required this.countryCode,
    required this.amounts,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'countryCode': countryCode,
      'amounts': amounts.map((a) => a.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() => toJson();

  static List<Operator> getOperatorsByCountry(String countryCode) {
    switch (countryCode) {
      case 'MX':
        return [
          Operator(
            id: 'telcel_mx',
            name: 'Telcel',
            logo: '📱',
            countryCode: 'MX',
            amounts: RechargeAmount.getMexicoAmounts(),
          ),
          Operator(
            id: 'movistar_mx',
            name: 'Movistar',
            logo: '📞',
            countryCode: 'MX',
            amounts: RechargeAmount.getMexicoAmounts(),
          ),
          Operator(
            id: 'att_mx',
            name: 'AT&T',
            logo: '🔵',
            countryCode: 'MX',
            amounts: RechargeAmount.getMexicoAmounts(),
          ),
        ];
      case 'US':
        return [
          Operator(
            id: 'verizon_us',
            name: 'Verizon',
            logo: '🔴',
            countryCode: 'US',
            amounts: RechargeAmount.getUSAmounts(),
          ),
          Operator(
            id: 'att_us',
            name: 'AT&T',
            logo: '🔵',
            countryCode: 'US',
            amounts: RechargeAmount.getUSAmounts(),
          ),
          Operator(
            id: 'tmobile_us',
            name: 'T-Mobile',
            logo: '🟣',
            countryCode: 'US',
            amounts: RechargeAmount.getUSAmounts(),
          ),
        ];
      case 'CU':
        return [
          Operator(
            id: 'cubacel_cu',
            name: 'CubaCel',
            logo: '🇨🇺',
            countryCode: 'CU',
            amounts: RechargeAmount.getCubaAmounts(),
          ),
        ];
      default:
        return [
          Operator(
            id: 'default_op',
            name: 'Operador Principal',
            logo: '📱',
            countryCode: countryCode,
            amounts: RechargeAmount.getDefaultAmounts(),
          ),
        ];
    }
  }
}

class RechargeAmount {
  final String id;
  final double amount;
  final double cost;
  final String description;
  final String? bonus;

  RechargeAmount({
    required this.id,
    required this.amount,
    required this.cost,
    required this.description,
    this.bonus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'cost': cost,
      'description': description,
      'bonus': bonus,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  static List<RechargeAmount> getMexicoAmounts() {
    return [
      RechargeAmount(id: 'mx_20', amount: 20, cost: 21.99, description: '\$20 MXN'),
      RechargeAmount(id: 'mx_50', amount: 50, cost: 52.99, description: '\$50 MXN'),
      RechargeAmount(id: 'mx_100', amount: 100, cost: 104.99, description: '\$100 MXN'),
      RechargeAmount(id: 'mx_200', amount: 200, cost: 208.99, description: '\$200 MXN'),
      RechargeAmount(id: 'mx_300', amount: 300, cost: 312.99, description: '\$300 MXN'),
      RechargeAmount(id: 'mx_500', amount: 500, cost: 520.99, description: '\$500 MXN'),
    ];
  }

  static List<RechargeAmount> getUSAmounts() {
    return [
      RechargeAmount(id: 'us_10', amount: 10, cost: 10.99, description: '\$10 USD'),
      RechargeAmount(id: 'us_25', amount: 25, cost: 26.99, description: '\$25 USD'),
      RechargeAmount(id: 'us_50', amount: 50, cost: 52.99, description: '\$50 USD'),
      RechargeAmount(id: 'us_100', amount: 100, cost: 104.99, description: '\$100 USD'),
    ];
  }

  static List<RechargeAmount> getCubaAmounts() {
    return [
      RechargeAmount(
        id: 'cu_500_bonus',
        amount: 500,
        cost: 21.99,
        description: '500.00 CUP + Internet ilimitado 24/7 x 10 días',
        bonus: 'Internet ilimitado',
      ),
      RechargeAmount(id: 'cu_100', amount: 100, cost: 5.99, description: '100.00 CUP'),
      RechargeAmount(id: 'cu_250', amount: 250, cost: 12.99, description: '250.00 CUP'),
      RechargeAmount(id: 'cu_750', amount: 750, cost: 32.99, description: '750.00 CUP'),
      RechargeAmount(id: 'cu_1000', amount: 1000, cost: 43.99, description: '1000.00 CUP'),
    ];
  }

  static List<RechargeAmount> getDefaultAmounts() {
    return [
      RechargeAmount(id: 'def_10', amount: 10, cost: 11.99, description: '\$10'),
      RechargeAmount(id: 'def_25', amount: 25, cost: 26.99, description: '\$25'),
      RechargeAmount(id: 'def_50', amount: 50, cost: 52.99, description: '\$50'),
      RechargeAmount(id: 'def_100', amount: 100, cost: 104.99, description: '\$100'),
    ];
  }
}