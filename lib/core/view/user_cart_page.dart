// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_types_as_parameter_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luxe/core/controller/product_controller.dart'; // Import your ProductController
import 'package:luxe/core/model/cart_model.dart'; // Import your CartModel
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class UserCartPage extends StatefulWidget {
  final ProductController productController;

  const UserCartPage({super.key, required this.productController});

  @override
  _UserCartPageState createState() => _UserCartPageState();
}

class _UserCartPageState extends State<UserCartPage> {
  bool _isOrdering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        margin: EdgeInsets.all(15),
        child: FutureBuilder<Stream<List<CartModel>>>(
          future: widget.productController.getCartItems(),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (futureSnapshot.hasError) {
              return Center(child: Text('Error: ${futureSnapshot.error}'));
            } else if (!futureSnapshot.hasData) {
              return const Center(child: Text('لم تقم بإضافة أي منتج'));
            } else {
              return StreamBuilder<List<CartModel>>(
                stream: futureSnapshot.data,
                builder: (context, streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (streamSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${streamSnapshot.error}'));
                  } else if (!streamSnapshot.hasData ||
                      streamSnapshot.data!.isEmpty) {
                    return const Center(child: Text('لم تقم بإضافة أي منتج'));
                  } else {
                    List<CartModel> cartItems = streamSnapshot.data!;
                    double totalCartPrice = cartItems.fold(
                      0.0,
                      (sum, item) => sum + (item.price * item.quantity),
                    );
                    return Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  CartModel cartItem = cartItems[index];
                                  double totalPrice =
                                      cartItem.price * cartItem.quantity;

                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              cartItem.product.imageUrls.first,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.error),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartItem.product.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  cartItem.product.description,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Unit Price: \$${cartItem.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Total: \$${totalPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              _deleteCartItem(context, index);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.info),
                                            onPressed: () {
                                              _navigateToEditCartItemPage(
                                                  context, cartItem, index);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    'السعر الكلي: \$${totalCartPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.green[300],
                                      ),
                                      foregroundColor:
                                          const WidgetStatePropertyAll(
                                        Colors.black,
                                      ),
                                      fixedSize: const WidgetStatePropertyAll(
                                        Size(200, 45),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        _isOrdering = true;
                                      });
                                      await _orderNow(
                                          context, totalCartPrice, cartItems);
                                      setState(() {
                                        _isOrdering = false;
                                      });
                                    },
                                    child: const Text(
                                      'تأكيد الطلب',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_isOrdering)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteCartItem(BuildContext context, int index) async {
    try {
      await widget.productController.deleteCartItemByIndex(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted from cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
    }
  }

  void _navigateToEditCartItemPage(
      BuildContext context, CartModel cartItem, int index) {
    Navigator.pushNamed(
      context,
      '/editCartItem',
      arguments: {
        'cartItem': cartItem,
        'index': index,
      },
    );
  }

  Future<void> _orderNow(BuildContext context, double totalCartPrice,
      List<CartModel> cartItems) async {
    // تكوين نص الرسالة
    StringBuffer message = StringBuffer();
    message.writeln('ملخص الطلب:');
    message.writeln('-------------------------------------------');
    for (var item in cartItems) {
      message.writeln('المنتج: ${item.product.name}');
      message.writeln('الوصف: ${item.product.description}');
      message.writeln('الكمية: ${item.quantity}');
      message.writeln('السعر للوحدة: \$${item.price.toStringAsFixed(2)}');
      message.writeln(
          'المجموع: \$${(item.quantity * item.price).toStringAsFixed(2)}');
      message.writeln('-------------------------------------------');
    }
    message.writeln('السعر الكلي: \$${totalCartPrice.toStringAsFixed(2)}');

    // افتح واتساب باستخدام الرابط المعد
    await _launchUrl(message.toString());
  }

  Future<void> _launchUrl(String message) async {
    try {
      // Retrieve the single document from the admins collection
      QuerySnapshot adminsSnapshot =
          await FirebaseFirestore.instance.collection('admins').limit(1).get();

      if (adminsSnapshot.size > 0) {
        // There should be only one document, so get the first one
        DocumentSnapshot adminSnapshot = adminsSnapshot.docs.first;

        // Extract the phone number from the document
        String phoneNumber = adminSnapshot['number'];

        // Compose the WhatsApp message URL
        final Uri url = Uri.parse(
            'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

        // Launch the URL
        if (!await launchUrl(url)) {
          throw 'Could not launch $url';
        }
      } else {
        throw Exception('No admin document found');
      }
    } catch (e) {
      throw Exception('حدثت مشكلة في الإتصال أعد المحاولة: $e');
    }
  }
}
