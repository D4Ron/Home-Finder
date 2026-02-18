class PropertyModel {
  final int id;
  final String title;
  final String description;
  final String propertyType;
  final double price;
  final String address;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final int? parkingSpaces;
  final List<String> amenities;
  final List<String> imageUrls;
  final int ownerId;
  final String ownerName;
  final String? ownerImageUrl;
  final double rating;
  final int viewCount;
  final String status;
  final String listingType;
  final bool isFavourited;
  final DateTime createdAt;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.price,
    required this.address,
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.parkingSpaces,
    required this.amenities,
    required this.imageUrls,
    required this.ownerId,
    required this.ownerName,
    this.ownerImageUrl,
    required this.rating,
    required this.viewCount,
    required this.status,
    required this.listingType,
    this.isFavourited = false,
    required this.createdAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> j) => PropertyModel(
    id: j['id'],
    title: j['title'],
    description: j['description'],
    propertyType: j['propertyType'],
    price: (j['price'] as num).toDouble(),
    address: j['address'],
    city: j['city'],
    country: j['country'],
    latitude: j['latitude']?.toDouble(),
    longitude: j['longitude']?.toDouble(),
    bedrooms: j['bedrooms'],
    bathrooms: j['bathrooms'],
    area: j['area']?.toDouble(),
    parkingSpaces: j['parkingSpaces'],
    amenities: List<String>.from(j['amenities'] ?? []),
    imageUrls: List<String>.from(j['imageUrls'] ?? []),
    ownerId: j['owner']?['id'] ?? j['ownerId'] ?? 0,
    ownerName: j['owner']?['name'] ?? '',
    ownerImageUrl: j['owner']?['profileImageUrl'],
    rating: (j['rating'] ?? 0).toDouble(),
    viewCount: j['viewCount'] ?? 0,
    status: j['status'] ?? 'ACTIVE',
    listingType: j['listingType'] ?? 'SALE',
    isFavourited: j['isFavourited'] ?? false,
    createdAt: DateTime.parse(j['createdAt']),
  );

  PropertyModel copyWith({bool? isFavourited}) => PropertyModel(
    id: id,
    title: title,
    description: description,
    propertyType: propertyType,
    price: price,
    address: address,
    city: city,
    country: country,
    latitude: latitude,
    longitude: longitude,
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    area: area,
    parkingSpaces: parkingSpaces,
    amenities: amenities,
    imageUrls: imageUrls,
    ownerId: ownerId,
    ownerName: ownerName,
    ownerImageUrl: ownerImageUrl,
    rating: rating,
    viewCount: viewCount,
    status: status,
    listingType: listingType,
    isFavourited: isFavourited ?? this.isFavourited,
    createdAt: createdAt,
  );
}