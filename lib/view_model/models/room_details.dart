class RoomModel {
  String id;
  String roomType;
  String price;
  List<String> imageUrl;
  Map<String, bool> services; // Changing to bool for services
  Map<String, dynamic> location;
  String rooms;
  Map<String, dynamic> roomAvailability;

  RoomModel({
    required this.id,
    required this.roomType,
    required this.price,
    required this.imageUrl,
    required this.services,
    required this.location,
    required this.rooms,
    required this.roomAvailability,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] ?? '',
      roomType: map['roomType'] ?? '',
      price: map['price'] ?? '',
      imageUrl: List<String>.from(map['imageUrl']),
      services: Map<String, bool>.from(map['Services']), // Cast as Map<String, bool>
      location: Map<String, dynamic>.from(map['location']),
      rooms: map['rooms'] ?? 'N/A', // Handle missing room field
      roomAvailability: Map<String, dynamic>.from(map['roomAvailability']),
    );
  }
}
