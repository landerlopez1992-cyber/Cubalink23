class Flight {
  final String id;
  final String airline;
  final String flightNumber;
  final String departure;
  final String arrival;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double economyPrice;
  final double businessPrice;
  final double firstClassPrice;
  final int availableSeats;

  Flight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.arrivalTime,
    required this.economyPrice,
    required this.businessPrice,
    required this.firstClassPrice,
    required this.availableSeats,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'airline': airline,
      'flightNumber': flightNumber,
      'departure': departure,
      'arrival': arrival,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'economyPrice': economyPrice,
      'businessPrice': businessPrice,
      'firstClassPrice': firstClassPrice,
      'availableSeats': availableSeats,
    };
  }

  static Flight fromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id'] ?? '',
      airline: map['airline'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      departure: map['departure'] ?? '',
      arrival: map['arrival'] ?? '',
      departureTime: DateTime.parse(map['departureTime']),
      arrivalTime: DateTime.parse(map['arrivalTime']),
      economyPrice: (map['economyPrice'] ?? 0).toDouble(),
      businessPrice: (map['businessPrice'] ?? 0).toDouble(),
      firstClassPrice: (map['firstClassPrice'] ?? 0).toDouble(),
      availableSeats: map['availableSeats'] ?? 0,
    );
  }
}

class FlightBooking {
  final String id;
  final String userId;
  final Flight flight;
  final String flightClass;
  final int passengers;
  final double totalPrice;
  final DateTime bookingDate;
  final String status;

  FlightBooking({
    required this.id,
    required this.userId,
    required this.flight,
    required this.flightClass,
    required this.passengers,
    required this.totalPrice,
    required this.bookingDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'flight': flight.toMap(),
      'flightClass': flightClass,
      'passengers': passengers,
      'totalPrice': totalPrice,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
    };
  }

  static FlightBooking fromMap(Map<String, dynamic> map) {
    return FlightBooking(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      flight: Flight.fromMap(map['flight']),
      flightClass: map['flightClass'] ?? '',
      passengers: map['passengers'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      bookingDate: DateTime.parse(map['bookingDate']),
      status: map['status'] ?? '',
    );
  }
}