import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:luxe/core/controller/auth_controller.dart';
import 'package:luxe/core/controller/product_controller.dart';
import 'package:luxe/core/view/product_list_page.dart';
import 'package:luxe/core/view/product_search_page.dart';
import 'package:luxe/core/view/user_cart_page.dart';

class UserPage extends StatefulWidget {
  final UserController userController;
  final ProductController productController;
  

  const UserPage(
      {super.key,
      required this.userController,
      required this.productController});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late UserController _userController;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _userController = widget.userController;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
 
  final List<Widget> _pages = [
    ProductListPage(),
    const ProductSearchPage(),
    UserCartPage(
      productController: ProductController(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Luxe Shop',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),),centerTitle: true,),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(

              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        _userController.currentUser?.photoURL ?? ''),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _userController.currentUser?.username ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _userController.currentUser?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('قائمة المنتجات'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('سلة المشتريات'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context); // Close the drawer
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('البحث عن منتج'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.green.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.green,
              hoverColor: Colors.green,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.green,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.list,
                  text: 'قائمة المنتجات',
                ),
                GButton(
                  icon: Icons.search,
                  text: 'البحث',
                ),
                GButton(
                  icon: Icons.shopping_cart,
                  text: 'سلة المشتريات',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
