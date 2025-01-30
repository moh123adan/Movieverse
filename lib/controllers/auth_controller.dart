import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user != null) {
      isLoggedIn.value = true;
      _storage.write('isLoggedIn', true);
      loadUserData(user.uid);
      Get.offAllNamed('/movies');
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
      Get.snackbar('Error', 'Username cannot be empty.');
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

      firebaseUser.value = cred.user;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getFirebaseErrorMessage(e));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      firebaseUser.value = cred.user;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getFirebaseErrorMessage(e));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      firebaseUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
