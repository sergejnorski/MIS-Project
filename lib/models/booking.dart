import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String roomId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;

  Booking({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.startTime,
    required this.endTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      roomId: json['roomId'],
      userId: json['userId'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}