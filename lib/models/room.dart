class Room {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final bool isAvailable;
  final double latitude;
  final double longitude;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      capacity: json['capacity'],
      isAvailable: json['isAvailable'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'isAvailable': isAvailable,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}