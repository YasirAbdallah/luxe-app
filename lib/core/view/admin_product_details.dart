import 'package:flutter/material.dart';
import 'package:luxe/core/model/product_model.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:get/get.dart';

class AdminProductDetailPage extends StatelessWidget {
  final Product product;
  final int index;
  final List<Product> products;
  final ProductController productController;

  const AdminProductDetailPage({
    super.key,
    required this.product,
    required this.index,
    required this.products,
    required this.productController,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
            ),
          ],
        ),
        body: GetBuilder<ProductController>(
          builder: (controller) {
            double screenHeight = MediaQuery.of(context).size.height;
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.4,
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: product.imageUrls.length,
                              onPageChanged: (index) {
                                // Handle page changed
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        product.imageUrls[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.green),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: screenHeight * 0.6,
                          child: Card(
                            elevation: 5,
                            margin: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'الأحجام المتاحة',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: product.sizePrices.keys.map((size) {
                                      return Chip(
                                        label: Text(
                                          '$size: \$${product.sizePrices[size]!.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        backgroundColor: Colors.green[200],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف ${product.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                _showLoadingDialog(context);
                await productController.deleteProductByIndex(index, products);
                Get.back(); // Close the loading dialog
                Get.back(); // Close the confirmation dialog
                Get.back();
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        );
      },
    );
  }
}
