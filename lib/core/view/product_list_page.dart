import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/model/product_model.dart';
import 'package:luxe/core/view/product_detail_page.dart';

class ProductListPage extends StatelessWidget {
  final ProductController productController = Get.put(ProductController());
  ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return GetBuilder<ProductController>(
      builder: (controller) {
        return Scaffold(
          body: StreamBuilder<List<Product>>(
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
                  crossAxisCount: 2, // عدد العناصر في الصف الواحد
                  childAspectRatio: 0.9, // نسبة العرض إلى الارتفاع لكل عنصر
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            product: product,
                            productController: controller,
                          ),
                        ),
                      );
                    },
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Card(
                        margin: const EdgeInsets.all(
                            8.0), // تعديل الهوامش بين العناصر
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  product.imageUrls.first,
                                  width: double.infinity,
                                  height: screenHeight *
                                      0.15, // استخدام ارتفاع الشاشة لضبط ارتفاع الصورة
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                        width: double.infinity,
                                  height: screenHeight * 0.15,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.green,
                                          value:
                                              loadingProgress.expectedTotalBytes !=
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
                                      const Icon(Icons.error),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            
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
