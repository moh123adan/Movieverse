import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Import the generated file
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:movieverse/providers/favorite_provider.dart';
import 'package:movieverse/controllers/auth_controller.dart';
import 'package:movieverse/views/auth/login_screen.dart';
import 'package:movieverse/views/auth/signup_screen.dart';
import 'package:movieverse/views/home/onboarding_screen.dart';
import 'package:movieverse/views/screens/movies_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  // Check if a user is logged in
  String initialRoute =
      FirebaseAuth.instance.currentUser == null ? '/onboarding' : '/';

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
      initialRoute: initialRoute, // Set dynamic initial route
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/', page: () => MoviesScreen()),
      ],
      builder: (context, child) {
        // Initialize GetX controller
        Get.put(AuthController());
        return child!;
      },
    );
  }
}
