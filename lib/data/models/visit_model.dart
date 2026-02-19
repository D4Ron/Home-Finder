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

  factory VisitModel.fromJson(Map<String, dynamic> j) {
    // Spring Boot VisitService sets visit.setUser(user) — so the JSON field
    // is "user", NOT "visitor". We fall back to the old keys for safety.
    final userObj     = j['user']     as Map<String, dynamic>?
        ?? j['visitor']  as Map<String, dynamic>?;
    final propertyObj = j['property'] as Map<String, dynamic>?;

    // Image: property.imageUrls[0] if present
    String? imageUrl;
    final imageUrls = propertyObj?['imageUrls'];
    if (imageUrls is List && imageUrls.isNotEmpty) {
      imageUrl = imageUrls[0] as String?;
    }

    return VisitModel(
      id:              j['id'],
      propertyId:      propertyObj?['id']      ?? j['propertyId']      ?? 0,
      propertyTitle:   propertyObj?['title']   ?? j['propertyTitle']   ?? '',
      propertyAddress: propertyObj?['address'] ?? j['propertyAddress'],
      propertyImageUrl: imageUrl,
      visitorId:   userObj?['id']   ?? j['visitorId']   ?? j['userId']   ?? 0,
      visitorName: userObj?['name'] ?? j['visitorName'] ?? j['userName'] ?? '',
      ownerId:     propertyObj?['owner']?['id'] ?? j['ownerId'] ?? 0,
      scheduledDate: DateTime.parse(j['scheduledDate']),
      status:  j['status'] ?? 'PENDING',
      notes:   j['notes'],
      createdAt: j['createdAt'] != null
          ? DateTime.parse(j['createdAt'])
          : DateTime.now(),
    );
  }

  String get statusLabel => switch (status) {
    'PENDING'   => 'En attente',
    'CONFIRMED' => 'Confirmée',
    'CANCELLED' => 'Annulée',
    'COMPLETED' => 'Effectuée',
    _ => status,
  };
}