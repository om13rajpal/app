class VesselModel {
  final String id;
  final String name;
  final String vesselId;
  final String type;
  final String captain;
  final String emergencyContact;
  final String? imageUrl;

  VesselModel({required this.id, required this.name, required this.vesselId, required this.type, required this.captain, required this.emergencyContact, this.imageUrl});

  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'vesselId': vesselId, 'type': type, 'captain': captain, 'emergencyContact': emergencyContact, 'imageUrl': imageUrl};
  }

  factory VesselModel.fromJson(Map<String, dynamic> json) {
    return VesselModel(
      id: json['id'],
      name: json['name'],
      vesselId: json['vesselId'],
      type: json['type'],
      captain: json['captain'],
      emergencyContact: json['emergencyContact'],
      imageUrl: json['imageUrl'],
    );
  }
}
