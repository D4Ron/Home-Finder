class AlertModel {
  final int id;
  final String name;
  final String? propertyType;
  final String? city;
  final String? country;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? minBathrooms;
  final double? radiusKm;
  final String frequency; // INSTANT, DAILY, WEEKLY
  final bool active;
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.name,
    this.propertyType,
    this.city,
    this.country,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minBathrooms,
    this.radiusKm,
    required this.frequency,
    required this.active,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> j) => AlertModel(
    id: j['id'],
    name: j['name'],
    propertyType: j['propertyType'],
    city: j['city'],
    country: j['country'],
    minPrice: j['minPrice']?.toDouble(),
    maxPrice: j['maxPrice']?.toDouble(),
    minBedrooms: j['minBedrooms'],
    minBathrooms: j['minBathrooms'],
    radiusKm: j['radiusKm']?.toDouble(),
    frequency: j['frequency'] ?? 'INSTANT',
    active: j['active'] ?? true,
    createdAt: j['createdAt'] != null
        ? DateTime.parse(j['createdAt'])
        : DateTime.now(),
  );

  String get frequencyLabel => switch (frequency) {
    'INSTANT' => 'Instantané',
    'DAILY'   => 'Quotidien',
    'WEEKLY'  => 'Hebdomadaire',
    _ => frequency,
  };
}