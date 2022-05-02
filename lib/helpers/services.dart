class Service {
  final String name;
  final int maxPrice;
  final int averageTime;
  final bool available;
  final String id;

  const Service({
    required this.name,
    required this.maxPrice,
    required this.averageTime,
    required this.available,
    required this.id,
  });

  static Service fromJson(json) => Service(
        name: json['name'],
        maxPrice: json['max_price'],
        averageTime: json['average_time_minutes'],
        available: json['available'],
        id: json['id'],
      );
}
