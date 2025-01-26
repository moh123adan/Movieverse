import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:image_picker/image_picker.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initialize Firestore

  Rx<File?> pickedImage = Rx<File?>(null);
  final RxString gender = ''.obs;

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
      final user = Get.find<AuthController>().user.value;
      if (user == null) return;

      final ref = _storage.ref().child('profilePics/${user.uid}');
      await ref.putFile(pickedImage.value!);
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': url,
      });

      Get.find<AuthController>().userModel.value?.photoUrl = url;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> updateProfile({
    required String name,
    required String username,
    required String bio,
  }) async {
    try {
      final user = Get.find<AuthController>().user.value;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'username': username,
        'bio': bio,
        'gender': gender.value,
      });

      await Get.find<AuthController>().loadUserData(user.uid);
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
