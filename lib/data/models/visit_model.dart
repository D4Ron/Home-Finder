class VisitModel {
  final int id;
  final int propertyId;
  final String propertyTitle;
  final String? propertyAddress;
  final String? propertyImageUrl;
  final int visitorId;
  final String visitorName;
  final int ownerId;
  final DateTime scheduledDate;
  final String status; // PENDING, CONFIRMED, CANCELLED, COMPLETED
  final String? notes;
  final DateTime createdAt;

  const VisitModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    this.propertyAddress,
    this.propertyImageUrl,
    required this.visitorId,
    required this.visitorName,
    required this.ownerId,
    required this.scheduledDate,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory VisitModel.fromJson(Map<String, dynamic> j) => VisitModel(
    id: j['id'],
    propertyId: j['property']?['id'] ?? j['propertyId'] ?? 0,
    propertyTitle: j['property']?['title'] ?? j['propertyTitle'] ?? '',
    propertyAddress: j['property']?['address'] ?? j['propertyAddress'],
    propertyImageUrl: (j['property']?['imageUrls'] as List?)?.isNotEmpty == true
        ? j['property']['imageUrls'][0]
        : null,
    visitorId: j['visitor']?['id'] ?? j['visitorId'] ?? 0,
    visitorName: j['visitor']?['name'] ?? j['visitorName'] ?? '',
    ownerId: j['property']?['owner']?['id'] ?? j['ownerId'] ?? 0,
    scheduledDate: DateTime.parse(j['scheduledDate']),
    status: j['status'] ?? 'PENDING',
    notes: j['notes'],
    createdAt: j['createdAt'] != null
        ? DateTime.parse(j['createdAt'])
        : DateTime.now(),
  );

  String get statusLabel => switch (status) {
    'PENDING' => 'En attente',
    'CONFIRMED' => 'Confirmée',
    'CANCELLED' => 'Annulée',
    'COMPLETED' => 'Effectuée',
    _ => status,
  };
}