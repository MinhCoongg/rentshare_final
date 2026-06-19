import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/addresses_viewmodel.dart';
import 'package:rentshare_app/viewmodels/checkout_viewmodel.dart';
import 'package:rentshare_app/viewmodels/home_viewmodel.dart'; 
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/viewmodels/product_detail_viewmodel.dart';
import 'package:rentshare_app/viewmodels/rentalOrderDetail_viewmodel.dart';
import 'package:rentshare_app/viewmodels/rental_cart_viewmodel.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/views/home_product/homeProduct.dart';
import 'package:rentshare_app/views/login/login.dart';
import 'package:rentshare_app/views/myorder/myorder.dart';
import 'package:rentshare_app/views/post_product.dart/post_product_screen.dart';
import 'package:rentshare_app/views/product_detail.dart/product_detail_screen.dart';
import 'package:rentshare_app/views/rentalOrderDetail/rentelDetalProduct.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProductViewModel()),
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()), 
        ChangeNotifierProvider(create: (_) => HomeViewModel()), 
        ChangeNotifierProvider(create: (_) => RentalCartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutViewModel()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProvider(create: (_) => RentalOrderViewModel()),
        ChangeNotifierProvider(create: (_) => RentalOrderDetailViewModel()),

      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RentShare App',
      initialRoute: '/login',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomePage(), 
        '/post_product': (context) => const PostProductScreen(), 
        '/product_detail' : (context) => const ProductDetailPage(productId: 4),
        '/my-order' : (context) => const MyRentalsScreen(),

      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/rental-detail') {
          
          final int orderId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => OrderDetailScreen(
              orderId: orderId,
            ),
          );
        }
       
        return null;
      },
    );
  }
}