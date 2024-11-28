import 'package:flutter/material.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/model/cart_model.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class UserOrdersPage extends StatelessWidget {
  final String userId;
  final ProductController controller = ProductController();

  UserOrdersPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green,
          title: const Text(
            'قائمة الطلبات',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
        body: StreamBuilder<List<CartModel>>(
          stream: controller.getUserOrdersStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('خطأ: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد طلبات لهذا المستخدم'));
            }
            List<CartModel> orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                CartModel order = orders[index];
                String formattedDate =
                    DateFormat('yyyy-MM-dd – kk:mm').format(order.orderTime);
                double totalPrice = order.price * order.quantity;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Builder(builder: (context) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: PageView.builder(
                                itemCount: order.product.imageUrls.length,
                                itemBuilder: (context, imageIndex) {
                                  return Image.network(
                                    order.product.imageUrls[imageIndex],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.product.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'الحجم: ${order.size}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('الكمية: ${order.quantity}'),
                                const SizedBox(height: 4),
                                Text(
                                    'السعر: \$${order.price.toStringAsFixed(2)}'),
                                const SizedBox(height: 4),
                                Text(
                                  'السعر الإجمالي: \$${totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'تاريخ الطلب: $formattedDate',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
