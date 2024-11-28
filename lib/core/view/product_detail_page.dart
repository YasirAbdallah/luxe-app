// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:luxe/core/model/product_model.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:get/get.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final ProductController productController;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.productController,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductController productController = Get.put(ProductController());
  String? selectedSize;
  late double currentPrice;
  int selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.product.sizePrices.keys.first;
    currentPrice = widget.product.sizePrices[selectedSize!]!;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double totalPrice = currentPrice * selectedQuantity;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product.name),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.4,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: widget.product.imageUrls.length,
                      onPageChanged: (index) {
                        productController.currentImageIndex = index;
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            widget.product.imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                productController.isLoadingImage = false;
                                return child;
                              } else {
                                productController.isLoadingImage = true;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                    if (productController.isLoadingImage) const Center(),
                  ],
                ),
              ),
            
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.grey[200],
                  elevation: 15,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          widget.product.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الأحجام المتاحة',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: widget.product.sizePrices.keys.map(
                          (size) {
                            return ChoiceChip(
                              label: Text(size),
                              selected: selectedSize == size,
                              onSelected: (bool selected) {
                                setState(
                                  () {
                                    selectedSize = size;
                                    currentPrice =
                                        widget.product.sizePrices[size]!;
                                  },
                                );
                              },
                            );
                          },
                        ).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'السعر: \$${currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            //  border: Border.all(),
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (selectedQuantity > 1) {
                                    selectedQuantity--;
                                  }
                                });
                              },
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                selectedQuantity.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  selectedQuantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'السعر الكلي: \$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GetBuilder<ProductController>(
                          init: widget.productController,
                          builder: (controller) {
                            return ElevatedButton(
                              onPressed: () {
                                controller.addToCart(
                                  product: widget.product,
                                  size: selectedSize!,
                                  price: currentPrice,
                                  quantity: selectedQuantity,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تمت إضافة المنتج للسلة'),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.green,
                                ),
                                foregroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                                fixedSize: MaterialStateProperty.all(
                                  Size(200, 45),
                                ),
                              ),
                              child: const Text(
                                'أضف إلى السلة',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
