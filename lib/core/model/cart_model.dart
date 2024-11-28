import 'package:luxe/core/model/product_model.dart';

class CartModel {
  final Product product;
  final String size;
  final double price;
  final int quantity;
  final String userId;
  final String userEmail;
  final String? userName;
  final String? userPhotoURL;
  final DateTime orderTime;

  CartModel({
    required this.product,
    required this.size,
    required this.price,
    required this.quantity,
    required this.userId,
    required this.userEmail,
    this.userName,
    this.userPhotoURL,
    required this.orderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'size': size,
      'price': price,
      'quantity': quantity,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userPhotoURL': userPhotoURL,
      'orderTime': orderTime.toIso8601String(),
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      product: Product.fromMap(map['product']),
      size: map['size'],
      price: map['price'],
      quantity: map['quantity'],
      userId: map['userId'],
      userEmail: map['userEmail'],
      userName: map['userName'],
      userPhotoURL: map['userPhotoURL'],
      orderTime: DateTime.parse(map['orderTime']),
    );
  }
}
