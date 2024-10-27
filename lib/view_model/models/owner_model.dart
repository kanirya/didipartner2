class OwnerModel {
  String name;
  String phone;
  String cnic;
  String imageUrl;
  String createdAt;
  String uid;
  List<String> roomId; // Add the roomIds list

  OwnerModel({
    required this.name,
    required this.phone,
    required this.cnic,
    required this.imageUrl,
    required this.createdAt,
    required this.uid,
    required this.roomId, // Add roomIds to constructor
  });

  // from map
  factory OwnerModel.fromMap(Map<String, dynamic> map) {
    return OwnerModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      cnic: map['cnic'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] ?? '',
      uid: map['uid'] ?? '',
      roomId: List<String>.from(map['roomId'] ?? []), // Map roomIds from Firestore
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "cnic": cnic,
      "imageUrl": imageUrl,
      "createdAt": createdAt,
      "uid": uid,
      "roomId": roomId,
    };
  }
}
