import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  Rx<File?> pickedImage = Rx<File?>(null);
  RxString gender = ''.obs;
  RxString name = ''.obs;
  RxString username = ''.obs;
  RxString bio = ''.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initUserData();
  }

  Future<void> _initUserData() async {
    isLoading.value = true;
    try {
      final isDataLoaded = await _authController.ensureUserDataLoaded();
      if (isDataLoaded) {
        final user = _authController.userModel.value;
        if (user != null) {
          username.value = user.username ?? '';
          bio.value = user.bio ?? '';
          gender.value = user.gender ?? '';
          name.value = user.name ?? '';
        } else {
          throw Exception('User model is null');
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      pickedImage.value = File(image.path);
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (pickedImage.value == null) return;

    try {
      final user = _authController.firebaseUser.value;
      if (user == null) return;

      final ref = _storage.ref().child('profilePics/${user.uid}');
      await ref.putFile(pickedImage.value!);
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': url,
      });

      await _authController.loadUserData(user.uid);

      Get.snackbar('Success', 'Profile picture updated successfully');
    } catch (e) {
      Get.snackbar(
          'Error', 'Failed to update profile picture: ${e.toString()}');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String username,
    required String bio,
  }) async {
    try {
      final user = _authController.firebaseUser.value;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'username': username,
        'bio': bio,
        'gender': gender.value,
      });

      // Update local Rx variables
      this.name.value = name;
      this.username.value = username;
      this.bio.value = bio;

      await _authController.loadUserData(user.uid);
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    }
  }

  void updateGender(String newGender) {
    gender.value = newGender;
  }
}
