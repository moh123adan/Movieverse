import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:movieverse/providers/favorite_provider.dart';
import 'package:movieverse/views/auth/login_screen.dart';
import 'package:movieverse/views/auth/signup_screen.dart';
import 'package:movieverse/views/home/onboarding_screen.dart';

import 'views/screens/discover_screen.dart';
import 'views/screens/favorite_screen.dart';
import 'views/screens/movies_screen.dart';
import 'views/screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Check if a user is logged in
  User? user = FirebaseAuth.instance.currentUser;
  String initialRoute = user != null ? '/' : '/onboarding';

  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoriteProvider(),
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movieverse',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.teal,
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/', page: () => const MoviesScreen()),
        GetPage(name: '/discover', page: () => const DiscoverScreen()),
        GetPage(name: '/favorites', page: () => const FavoriteScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
    );
  }
}
