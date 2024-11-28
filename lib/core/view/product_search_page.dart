// ignore_for_file: library_private_types_in_public_api, unused_element, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:luxe/core/model/cart_model.dart';
import 'package:luxe/core/model/product_model.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/view/admin_product_details.dart';
import 'package:luxe/core/view/product_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final ProductController _productController = ProductController();
  final TextEditingController _searchController = TextEditingController();
  Future<List<Product>>? _productsFuture;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts() {
    String query = _searchController.text;
    setState(
      () {
        _productsFuture = _productController.searchProducts(query);
      },
    );
  }

  Future<void> _navigateToDetailPage(
      BuildContext context, Product product, int index) async {
    final prefs = await SharedPreferences.getInstance();
    bool? isAdmin = prefs.getBool('isAdmin');

    if (isAdmin == true) {
      List<Product> products = await _productController.getProductsFuture();
      List<CartModel> orders = await _productController.getOrdersFuture();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminProductDetailPage(
            product: product,
            productController: _productController,
            index: index,
            products: products,
          //  orders: orders,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(
            product: product,
            productController: _productController,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              textDirection: TextDirection.rtl,
              controller: _searchController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                hintText: 'إبحث عن منتجات',
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchProducts,
                ),
              ),
              onSubmitted: (value) => _searchProducts(),
            ),
          ),
          Expanded(
            child: _productsFuture == null
                ? const Center(child: Text(''))
                : FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Colors.green,
                        ));
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('حدثت مشكلة أثناء الإتصال'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('لا توجد منتجات'));
                      }

                      final products = snapshot.data!;
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // عدد العناصر في الصف الواحد
                          childAspectRatio:
                              0.9, // نسبة العرض إلى الارتفاع لكل عنصر
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () {
                              _navigateToDetailPage(context, product, index);
                            },
                            child: Card(
                              margin: const EdgeInsets.all(
                                  5.0), // تعديل الهوامش بين العناصر
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
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
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
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
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                SizedBox(
                                          width: double.infinity,
                                          height: screenHeight *
                                              0.15, // استخدام ارتفاع الشاشة لضبط ارتفاع الصورة
                                          child: const Center(
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.green,
                                            ),
                                          ),
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
                  ),
          ),
        ],
      ),
    );
  }
}
