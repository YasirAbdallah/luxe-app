// ignore_for_file: avoid_print, unnecessary_cast

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luxe/core/model/auth_model.dart';
import 'package:luxe/core/model/cart_model.dart';
import 'package:luxe/core/model/product_model.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<CartModel> orderList = [];
  
  int currentImageIndex = 0;
  bool isLoadingImage = true;

  Future<List<CroppedFile>> cropImages(List<XFile> images) async {
    List<CroppedFile> croppedImages = [];
    try {
      for (XFile image in images) {
        CroppedFile? croppedImage = await ImageCropper.platform.cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
        );
        if (croppedImage != null) {
          croppedImages.add(croppedImage);
        }
      }
    } catch (e) {
      print('Error cropping images: $e');
    }
    return croppedImages;
  }

  Future<String?> uploadImage(XFile image) async {
    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> addProduct(Product product, List<XFile> images) async {
    try {
      List<String> imageUrls = [];
      for (var image in images) {
        String? imageUrl = await uploadImage(image);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        } else {
          throw Exception('Failed to upload one or more images.');
        }
      }

      await _firestore.collection('products').add({
        ...product.toMap(),
        'imageUrls': imageUrls,
      });
      update();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Stream<List<Product>> getProducts() {
    try {
      return _firestore.collection('products').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Product.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      DocumentSnapshot productDoc =
          await _firestore.collection('products').doc(productId).get();
      List<dynamic> imageUrls = productDoc['imageUrls'];

      for (String imageUrl in imageUrls) {
        await _storage.refFromURL(imageUrl).delete();
      }

      await _firestore.collection('products').doc(productId).delete();
      update();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsFuture() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  Future<List<CartModel>> getOrdersFuture() async {
    try {
      final snapshot = await _firestore.collection('cart').get();
      return snapshot.docs.map((doc) {
        return CartModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      QuerySnapshot productSnapshot =
          await _firestore.collection('products').get();

      List<Product> productList = productSnapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      List<Product> filteredProducts = productList
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return filteredProducts;
    } catch (e) {
      print('Error searching products: $e');
      rethrow;
    }
  }

  Future<void> addToCart({
    required Product product,
    required String size,
    required double price,
    required int quantity,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userEmail = prefs.getString('email');
    String? userName = prefs.getString('username');
    String? userPhotoURL = prefs.getString('photoURL');

    if (userId == null || userEmail == null) {
      print('No user is logged in');
      return;
    }

    DateTime orderTime = DateTime.now();

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('cart')
          .where('product.name', isEqualTo: product.name)
          .get();

      print('Query Snapshot: ${querySnapshot.docs.length} documents found');

      if (querySnapshot.docs.isNotEmpty) {
        // إذا كان المنتج موجودًا بالفعل، قم بتحديث الكمية
        DocumentSnapshot existingCartItem = querySnapshot.docs.first;
        await _firestore
            .collection('cart')
            .doc(existingCartItem.id)
            .update({'quantity': quantity});
        print('Updated quantity for existing product in cart');
      } else {
        // إذا لم يكن المنتج موجودًا، أضف منتجًا جديدًا إلى العربة
        CartModel cartModel = CartModel(
          product: product,
          size: size,
          price: price,
          quantity: quantity,
          userId: userId,
          userEmail: userEmail,
          userName: userName,
          userPhotoURL: userPhotoURL,
          orderTime: orderTime,
        );

        await _firestore.collection('cart').add(cartModel.toMap());
        print('Added new product to cart');
      }
      update();
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<Stream<List<CartModel>>> getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      return _firestore
          .collection('cart')
          .where("userId", isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return CartModel.fromMap(doc.data());
        }).toList();
      });
    } else {
      throw Exception('User ID not found in SharedPreferences.');
    }
  }

  Future<void> deleteCartItemByIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      print('No user is logged in');
      return;
    }

    try {
      final cartDocs = await _firestore
          .collection('cart')
          .where("userId", isEqualTo: userId)
          .get();
      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }
      update();
    } catch (e) {
      print('Error deleting cart item: $e');
      rethrow;
    }
  }

  Future<void> updateCartItemQuantity(int index, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('cart')
          .where("userId", isEqualTo: userId)
          .get();

      if (index < snapshot.docs.length) {
        String docId = snapshot.docs[index].id;
        await _firestore
            .collection('cart')
            .doc(docId)
            .update({'quantity': quantity});
        update();
      }
    } else {
      throw Exception('User ID not found in SharedPreferences.');
    }
  }

  Future<Map<String, CartModel>> getUsersWithOrders() async {
    QuerySnapshot snapshot = await _firestore.collection('cart').get();
    Map<String, CartModel> usersWithOrders = {};

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String userId = data['userId'];

      if (!usersWithOrders.containsKey(userId)) {
        CartModel cart = CartModel.fromMap(data);
        usersWithOrders[userId] = cart;
      }
    }

    // فلترة المستخدمين الذين لديهم طلبات
    usersWithOrders.removeWhere((key, value) => value.quantity == 0);

    return usersWithOrders;
  }

  Stream<List<CartModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<UserModel> getUserById(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((QuerySnapshot query) {
      return query.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> deleteProductByIndex(
    int index,
    List<Product> products,
  ) async {
    orderList = await getOrdersFuture();
    final product = products[index];
    final productDoc = await _firestore
        .collection('products')
        .where('name', isEqualTo: product.name)
        .get();
    final cartDocs = await _firestore
        .collection('cart')
        .where('product.name', isEqualTo: product.name)
        .get();

    if (productDoc.docs.isNotEmpty) {
      final docId = productDoc.docs.first.id;

      for (String imageUrl in product.imageUrls) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }
      // حذف المنتج من Firestore
      try {
        await _firestore.collection('products').doc(docId).delete();
        for (var doc in cartDocs.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Error deleting product: $e');
      }
      update();
    }
  }
}
