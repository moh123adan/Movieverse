import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  Rx<UserModel?> userModel = Rx<UserModel?>(UserModel(
    id: '',
    email: '',
    name: '',
    username: '',
    bio: '',
    photoUrl: '',
    gender: '',
  ));

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      try {
        await loadUserData(user.uid);
        Get.offAllNamed('/home');
      } catch (e) {
        Get.snackbar('Error', 'Failed to load user data. Please try again.');
        Get.offAllNamed('/login');
      }
    }
  }

  Future<void> loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userModel.value = UserModel.fromJson(doc.data()!);
      } else {
        Get.snackbar('Error', 'User data not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data. Please try again.');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    if (name.isEmpty || username.isEmpty) {
      Get.snackbar('Error', 'Name and username cannot be empty.');
      return;
    }

    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: cred.user!.uid,
        email: email,
        name: name,
        username: username,
        bio: '',
        photoUrl: '',
        gender: '',
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(user.toJson());

      // Navigate to MoviesScreen after successful sign-up
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      }
      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Navigation is handled in _setInitialScreen
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Invalid email or password.';
      }
      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      userModel.value = null; // Reset userModel
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
