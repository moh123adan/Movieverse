import 'package:get/get.dart';

class AuthController extends GetxController {
  void signUp() {
    // Add authentication logic here (e.g., Firebase or API call).
    Get.toNamed('/home');
  }
}
