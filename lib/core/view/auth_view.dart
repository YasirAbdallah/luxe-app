import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxe/core/controller/auth_controller.dart';

class SignInPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'مرحباً بك في تطبيق Luxe Shop!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Image.asset(
                          'images/logo.png',
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'يرجى تسجيل الدخول للاستفادة من جميع المزايا التي نقدمها. '
                          'يمكنك تسجيل الدخول باستخدام حساب جوجل الخاص بك للوصول السريع والآمن.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'إذا كنت لا تملك حساب، يمكنك إنشاء حساب جديد مباشرة من هنا. '
                          'نحن نضمن لك تجربة مميزة وآمنة عند استخدام تطبيقنا.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16.0),
                        Obx(() {
                          return controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.green)
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await controller
                                          .signInWithGoogle(context);
                                    } catch (e) {
                                      print('Error during sign-in: $e');
                                    }
                                  },
                                  child:
                                      const Text('تسجيل الدخول بواسطة Google'),
                                );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
