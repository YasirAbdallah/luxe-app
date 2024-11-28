import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxe/core/controller/auth_controller.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/model/cart_model.dart';
import 'package:luxe/core/model/product_model.dart';
import 'package:luxe/core/view/add_product_page.dart';
import 'package:luxe/core/view/admin_page.dart';
import 'package:luxe/core/view/auth_view.dart';
import 'package:luxe/core/view/edit_cart_item_page.dart';
import 'package:luxe/core/view/product_detail_page.dart';
import 'package:luxe/core/view/product_list_page.dart';
import 'package:luxe/core/view/profile_page.dart';
import 'package:luxe/core/view/splash_page.dart';
import 'package:luxe/core/view/user_list_order_page.dart';
import 'package:luxe/core/view/user_order_page.dart';
import 'package:luxe/core/view/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import your splash page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBOdT4eLAn_lxTpcHtqhmVPAalTMLmG8Sw",
      appId: "1:534352654403:android:9a1d750a5e1536e3c0e4f6",
      messagingSenderId: "messagingSenderId",
      projectId: "luxe-b3676",
      storageBucket: 'luxe-b3676.appspot.com',
    ),
  );

  // Initialize UserController with GetX
  Get.put<UserController>(UserController());
  Get.put<ProductController>(ProductController());

  // Load user data from SharedPreferences
  UserController userController = Get.find<UserController>();
  ProductController productController = Get.find<ProductController>();
  userController.loadUserFromPreferences();

  // Check login status from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(
    userController: userController,
    isLoggedIn: isLoggedIn,
    productController: productController,
  ));
}

class MyApp extends StatelessWidget {
  final UserController userController;
  final ProductController productController;

  final bool isLoggedIn;

  const MyApp(
      {super.key,
      required this.userController,
      required this.isLoggedIn,
      required this.productController});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetMaterialApp(
        
        debugShowCheckedModeBanner: false,
        title: 'Luxe Shop',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => SplashView()),
          GetPage(name: '/', page: () => SignInPage()),
          GetPage(name: '/admin', page: () => const AdminPage()),
          GetPage(
              name: '/user',
              page: () => UserPage(
                    userController: userController,
                    productController: productController,
                  )),
          GetPage(name: '/add-product', page: () => const AddProductPage()),
          GetPage(
              name: '/profile',
              page: () => ProfilePage(userController: userController)),
          GetPage(name: '/product_list', page: () => ProductListPage()),
          GetPage(
              name: '/editCartItem',
              page: () {
                final args = Get.arguments as Map<String, dynamic>;
                return EditCartItemPage(
                  cartItem: args['cartItem'] as CartModel,
                  index: args['index'] as int,
                  productController: Get.find<ProductController>(),
                );
              }),
          GetPage(
              name: '/product_details',
              page: () {
                final args = Get.arguments as Product;
                return ProductDetailPage(
                  product: args,
                  productController: Get.find<ProductController>(),
                );
              }),
          GetPage(name: '/userListOrder', page: () => UserListOrderPage()),
          GetPage(
              name: '/userOrders',
              page: () {
                final args = Get.arguments as String;
                return UserOrdersPage(userId: args);
              }),
        ],
      ),
    );
  }
}
