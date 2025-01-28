import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);

    // Check local storage for login state
    isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
  }

  void _setInitialScreen(User? user) async {
    if (user == null) {
      isLoggedIn.value = false;
      _storage.write('isLoggedIn', false);
      Get.offAllNamed('/login');
    } else {
      try {
        await loadUserData(user.uid);
        isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);
        Get.offAllNamed('/');
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
    required String username,
  }) async {
    if (username.isEmpty) {
      Get.snackbar('Error', 'username cannot be empty.');
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
        username: username,
        bio: '',
        photoUrl: '',
        gender: '',
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(user.toJson());

      // The navigation and login state will be handled by _setInitialScreen
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
      // Login state and navigation are handled in _setInitialScreen
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
      userModel.value = null;
      isLoggedIn.value = false;
      _storage.write('isLoggedIn', false);
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
