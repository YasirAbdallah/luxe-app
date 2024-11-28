import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/model/product_model.dart';
import 'package:luxe/core/view/admin_product_details.dart';

class AdminProductListPage extends StatelessWidget {
  final ProductController _productController = Get.put(ProductController());

  AdminProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.add_circle, size: 50),
        ),
        color: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, '/add-product');
        },
      ),
      body: GetBuilder<ProductController>(
        builder: (controller) {
          return StreamBuilder<List<Product>>(
            stream: controller.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products found'));
              }
              final products = snapshot.data!;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () async {
                      // bool result =
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminProductDetailPage(
                            product: product,
                            index: index,
                            products: products,
                            productController: _productController,
                          ),
                        ),
                      );
                      // if (result == true) {
                      //   controller.getOrdersFuture(); // Refresh orders on result
                      // }
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                product.imageUrls.first,
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.green,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: const CircularProgressIndicator(
                                      color: Colors.green),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${product.sizePrices.values.first.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
