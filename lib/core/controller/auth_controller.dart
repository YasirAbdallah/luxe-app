import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxe/core/model/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;

  UserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    loadUserFromPreferences();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading.value = true;
    try {
      UserModel? user = await _authService.signInWithGoogle();
      isLoading.value = false;

      if (user != null) {
        _currentUser.value = user;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        String initialRoute = user.isAdmin ? '/admin' : '/user';
        Get.offNamed(initialRoute); // Navigate to '/admin' or '/user'
      } else {
        Get.snackbar('تسجيل الدخول', 'فشل تسجيل الدخول بواسطة Google');
      }
    } catch (error) {
      isLoading.value = false;
      print('Error occurred during sign-in: $error');
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول.';

      if (error is PlatformException) {
        switch (error.code) {
          case 'network_error':
            errorMessage = 'خطأ في الشبكة. يرجى التحقق من الاتصال بالإنترنت.';
            break;
          case 'account_exists_with_different_credentials':
            errorMessage =
                'هناك حساب بنفس البريد الإلكتروني مع اعتمادات مختلفة.';
            break;
          default:
            errorMessage = 'حدث خطأ أثناء تسجيل الدخول.';
            break;
        }
      }

      Get.snackbar('تسجيل الدخول', errorMessage);
    }
  }
 
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser.value = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void loadUserFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userId');
    String? email = prefs.getString('email');
    bool? isAdmin = prefs.getBool('isAdmin');
    String? photoURL = prefs.getString('photoURL');
    String? username = prefs.getString('username');

    if (uid != null && email != null && isAdmin != null) {
      _currentUser.value = UserModel(
        uid: uid,
        email: email,
        isAdmin: isAdmin,
        photoURL: photoURL,
        username: username,
      );
    }
  }
}
