import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../models/user_model.dart';

class FirestoreService {
  final CollectionReference _roomsCollection =
  FirebaseFirestore.instance.collection('rooms');
  final CollectionReference _bookingsCollection =
  FirebaseFirestore.instance.collection('bookings');

  // Get all rooms
  Stream<List<Room>> getRooms() {
    return _roomsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Room.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Get single room
  Future<Room?> getRoom(String roomId) async {
    final doc = await _roomsCollection.doc(roomId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return Room.fromJson({...data, 'id': doc.id});
    }
    return null;
  }

  // Add booking
  Future<void> createBooking(Booking booking) async {
    await _bookingsCollection.add(booking.toJson());

    // Update room availability
    // await _roomsCollection.doc(booking.roomId).update({
    //   'isAvailable': false,
    // });
  }

  // Get user's bookings
  Stream<List<Booking>> getUserBookings(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Booking.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, String roomId) async {
    await _bookingsCollection.doc(bookingId).delete();

    // Update room availability back to true
    await _roomsCollection.doc(roomId).update({
      'isAvailable': true,
    });
  }

  // Add some sample rooms
  // Future<void> addSampleRooms() async {
  //   final List<Map<String, dynamic>> sampleRooms = [
  //     {
  //       'name': 'Study Room A1',
  //       'description': 'Quiet study room with whiteboard',
  //       'capacity': 4,
  //       'isAvailable': true,
  //       'latitude': 41.9981,
  //       'longitude': 21.4254,
  //     },
  //     {
  //       'name': 'Study Room B2',
  //       'description': 'Group study room with projector',
  //       'capacity': 6,
  //       'isAvailable': true,
  //       'latitude': 41.9985,
  //       'longitude': 21.4260,
  //     },
  //   ];
  //
  //   for (var room in sampleRooms) {
  //     await _roomsCollection.add(room);
  //   }
  // }

  Future<bool> isRoomAvailable(String roomId, DateTime startTime, DateTime endTime) async {
    try {
      final bookings = await _bookingsCollection
          .where('roomId', isEqualTo: roomId)
          .get();

      // Check if any existing booking overlaps with the requested time slot
      for (var doc in bookings.docs) {
        final booking = Booking.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});

        // Check for overlap
        if (!(endTime.isBefore(booking.startTime) || startTime.isAfter(booking.endTime))) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking room availability: $e');
      throw 'Failed to check room availability';
    }
  }

  // Get room bookings
  Stream<List<Booking>> getRoomBookings(String roomId) {
    return _bookingsCollection
        .where('roomId', isEqualTo: roomId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Booking.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (doc.exists) {
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }
}