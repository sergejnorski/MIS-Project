import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../services/firestore_service.dart';

class RoomListScreen extends StatefulWidget {
  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  bool _showOnlyAvailable = false;
  String _sortBy = 'name';

  List<Room> _filterRooms(List<Room> rooms) {
    return rooms.where((room) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!room.name.toLowerCase().contains(query) &&
            !room.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Apply availability filter
      if (_showOnlyAvailable && !room.isAvailable) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'name') {
          return a.name.compareTo(b.name);
        } else {
          return a.capacity.compareTo(b.capacity);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Rooms'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search rooms...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Text('Sort by name'),
              ),
              PopupMenuItem(
                value: 'capacity',
                child: Text('Sort by capacity'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text('Show only available'),
                Switch(
                  value: _showOnlyAvailable,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyAvailable = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Room>>(
              stream: _firestoreService.getRooms(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final rooms = _filterRooms(snapshot.data ?? []);

                if (rooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No rooms found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(room.name),
                        subtitle: Text(
                          'Capacity: ${room.capacity}\n${room.description}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: TextButton(
                          onPressed: room.isAvailable
                              ? () {
                            Navigator.pushNamed(
                              context,
                              '/room-details',
                              arguments: room.id,
                            );
                          }
                              : null,
                          child: Text(
                            room.isAvailable ? 'Book' : 'Unavailable',
                            style: TextStyle(
                              color: room.isAvailable ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/room-details',
                            arguments: room.id,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}