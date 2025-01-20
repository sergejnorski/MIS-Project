import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../room/room_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  int _selectedIndex = 0;

  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.9981, 21.4254),
    zoom: 14.0,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _loadRoomMarkers() {
    _firestoreService.getRooms().listen((rooms) {
      setState(() {
        markers = rooms.map((room) {
          return Marker(
            markerId: MarkerId(room.id),
            position: LatLng(room.latitude, room.longitude),
            infoWindow: InfoWindow(
              title: room.name,
              snippet: 'Capacity: ${room.capacity}',
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/room-details',
                arguments: room.id,
              );
            },
          );
        }).toSet();
      });
    });
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRoomMarkers();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Map
        break;
      case 1: // List
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoomListScreen()),
        );
        break;
      case 2: // Bookings
        Navigator.pushNamed(context, '/bookings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Room Finder'),
        actions: [
          TextButton(
            onPressed: _handleLogout,
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialPosition,
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Bookings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}