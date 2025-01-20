import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_room_finder/screens/room/room_list_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/room/room_details_screen.dart';
import 'screens/bookings/bookings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyB_I8KvJ2AlCJa8BluSJFlCdcm6pryMmIM',
      appId: '1:603522094378:android:784b806550b40db93aba53',
      messagingSenderId: '603522094378',
      projectId: 'study-room-finder-1c011',
      databaseURL: 'https://study-room-finder-1c011-default-rtdb.europe-west1.firebasedatabase.app',
      storageBucket: 'study-room-finder-1c011.firebasestorage.app',
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Room Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/bookings': (context) => BookingsScreen(),
        '/room-list': (context) => RoomListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/room-details') {
          final String roomId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(roomId: roomId),
          );
        }
        return null;
      },
    );
  }
}