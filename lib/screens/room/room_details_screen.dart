import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class RoomDetailsScreen extends StatefulWidget {
  final String roomId;

  RoomDetailsScreen({required this.roomId});

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _bookRoom() async {
    if (selectedDate == null || selectedTime == null) return;

    final startTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final endTime = startTime.add(Duration(hours: 2)); // 2-hour booking slots

    try {
      final isAvailable = await _firestoreService.isRoomAvailable(
        widget.roomId,
        startTime,
        endTime,
      );

      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room not available for selected time')),
        );
        return;
      }

      final currentUser = AuthService().currentUser;
      if (currentUser == null) return;

      final booking = Booking(
        id: '',
        roomId: widget.roomId,
        userId: currentUser.uid,
        startTime: startTime,
        endTime: endTime,
      );

      await _firestoreService.createBooking(booking);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room booked successfully')),
      );

      Navigator.pushReplacementNamed(context, '/bookings');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking room: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Details'),
      ),
      body: FutureBuilder<Room?>(
        future: _firestoreService.getRoom(widget.roomId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final room = snapshot.data;
          if (room == null) {
            return Center(child: Text('Room not found'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.meeting_room,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  room.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  room.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Capacity'),
                  trailing: Text('${room.capacity} people'),
                ),
                Divider(),
                if (room.isAvailable) ...[
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Select Date'),
                    trailing: Text(
                      selectedDate != null
                          ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                          : 'Pick a date',
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text('Select Time'),
                    trailing: Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Pick a time',
                    ),
                    onTap: () => _selectTime(context),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedDate != null && selectedTime != null
                          ? _bookRoom
                          : null,
                      child: Text('Book Room'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ] else
                  Center(
                    child: Text(
                      'Room currently unavailable',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}