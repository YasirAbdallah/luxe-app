import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/model/cart_model.dart';

class UserListOrderPage extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();

  UserListOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (controller) {
        return Scaffold(
          body: FutureBuilder<Map<String, CartModel>>(
            future: controller.getUsersWithOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.green,
                ));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('ليس هناك طلبات للمستخدم'));
              }

              Map<String, CartModel> users = snapshot.data!;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  String userId = users.keys.elementAt(index);
                  CartModel userCart = users[userId]!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.green[100],
                      child: ListTile(
                        leading: userCart.userPhotoURL != null
                            ? CircleAvatar(
                                minRadius: 30,
                                maxRadius: 31,
                                backgroundImage:
                                    NetworkImage(userCart.userPhotoURL!),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(
                          userCart.userName ?? 'Unknown User',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        isThreeLine: true,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${userCart.orderTime.year}/${userCart.orderTime.month}/${userCart.orderTime.day}'),
                            Text(
                                '${userCart.orderTime.hour}:${userCart.orderTime.minute}:${userCart.orderTime.second}'),
                          ],
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              controller.deleteCartItemByIndex(index);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            )),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/userOrders',
                            arguments: userId,
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
