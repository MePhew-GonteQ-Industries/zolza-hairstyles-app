class Service {
  final String name;
  final int minPrice;
  final int maxPrice;
  final int averageTime;
  final bool available;
  final String id;
  final int requiredSlots;

  const Service({
    required this.minPrice,
    required this.name,
    required this.maxPrice,
    required this.averageTime,
    required this.available,
    required this.id,
    required this.requiredSlots,
  });

  static Service fromJson(json) => Service(
        name: json['name'],
        minPrice: json['min_price'],
        maxPrice: json['max_price'],
        averageTime: json['average_time_minutes'],
        available: json['available'],
        id: json['id'],
        requiredSlots: json['required_slots'],
      );
}
