import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:luxe/core/view/admin_product_list.dart';
import 'package:luxe/core/view/product_list_page.dart';
import 'package:luxe/core/view/product_search_page.dart';
import 'package:luxe/core/view/user_list_order_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  AdminPageState createState() => AdminPageState();
}
  
class AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
     AdminProductListPage(),  
    const ProductSearchPage(),
    UserListOrderPage(),
  ];

  void _onItemTapped(int index) {
    setState(() { 
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          primary: true,
          backgroundColor: Colors.green,

        title: const Text(
          'لوحة التحكم',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
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
              tabBackgroundColor: Colors.green[600]!,
              color: const Color.fromARGB(255, 16, 88, 18),
              tabs: const [
                GButton(
                  icon: Icons.list,
                  text: 'قائمة المنتجات',
                ),
              
                GButton(
                  icon: Icons.search,
                  text: 'بحث',
                ),
                GButton(
                  icon: Icons.shopping_cart,
                  text: 'الطلبات',
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
