import 'package:flutter/material.dart';
import 'screens/categories_screen.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.initialize();

  await AuthService.signInAnonymously();
  print('Anonymous user signed in: ${AuthService.currentUser?.uid}');

  await NotificationService.scheduleDailyRecipeNotification();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CategoriesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}