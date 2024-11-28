// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/model/cart_model.dart';

class EditCartItemPage extends StatefulWidget {
  final CartModel cartItem;
  final int index;
  final ProductController productController;

  const EditCartItemPage({
    super.key,
    required this.cartItem,
    required this.index,
    required this.productController,
  });

  @override
  _EditCartItemPageState createState() => _EditCartItemPageState();
}

class _EditCartItemPageState extends State<EditCartItemPage> {
  late int quantity;
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    quantity = widget.cartItem.quantity;
    totalPrice = widget.cartItem.price * quantity;
  }

  void _updateTotalPrice() {
    setState(() {
      totalPrice = widget.cartItem.price * quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cartItem.product.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.cartItem.product.imageUrls.length,
                      itemBuilder: (context, imageIndex) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.cartItem.product.imageUrls[imageIndex],
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الحجم المحدد ${widget.cartItem.size}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                                _updateTotalPrice();
                              });
                            }
                          },
                        ),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                              _updateTotalPrice();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'السعر الكلي \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.green[300],
                      ),
                      foregroundColor: const WidgetStatePropertyAll(
                        Colors.black,
                      ),
                      fixedSize: const WidgetStatePropertyAll(
                        Size(200, 45),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await widget.productController.updateCartItemQuantity(
                          widget.index,
                          quantity,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تحديث معلومات الطلب')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('فشل في تحديث معلومات الطلب')),
                        );
                      }
                    },
                    child: const Text(
                      'تحديث',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
