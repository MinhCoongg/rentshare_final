import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/address_viewmodel.dart';
import 'package:rentshare_app/viewmodels/addresses_viewmodel.dart';
import 'package:rentshare_app/viewmodels/auth_viewmodel.dart';
import 'package:rentshare_app/viewmodels/chat_viewmodel.dart';
import 'package:rentshare_app/viewmodels/checkout_viewmodel.dart';
import 'package:rentshare_app/viewmodels/home_viewmodel.dart';
import 'package:rentshare_app/viewmodels/login_viewmodel.dart'; 
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/viewmodels/productFilter.dart';
import 'package:rentshare_app/viewmodels/product_detail_viewmodel.dart';
<<<<<<< HEAD
import 'package:rentshare_app/views/catalog/catalog.dart';
import 'package:rentshare_app/views/post_product.dart/post_product_screen.dart';
import 'package:rentshare_app/views/login/register.dart';
import 'package:rentshare_app/views/login/login.dart';
=======
import 'package:rentshare_app/viewmodels/rental_cart_viewmodel.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/viewmodels/review_viewmodel.dart';
import 'package:rentshare_app/viewmodels/shop_viewmodel.dart';
import 'package:rentshare_app/viewmodels/wallet_viewmodel.dart';
import 'package:rentshare_app/viewmodels/wishlist_viewmodel.dart';
import 'package:rentshare_app/views/home_product/homeProduct.dart';
import 'package:rentshare_app/views/login/login.dart';
import 'package:rentshare_app/views/mainscreen.dart';
import 'package:rentshare_app/views/myorder/myorder.dart';
import 'package:rentshare_app/views/owner/list_rental_product_screen.dart';
import 'package:rentshare_app/views/owner/owner_rental_management_screen.dart';
import 'package:rentshare_app/views/post_product.dart/post_product_screen.dart';
import 'package:rentshare_app/views/profile/profile.dart';
import 'package:rentshare_app/views/rentalOrderDetail/rentelDetalProduct.dart';
>>>>>>> origin/fix

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProductViewModel()),
<<<<<<< HEAD
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()),
=======
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()), 
        ChangeNotifierProvider(create: (_) => HomeViewModel()), 
        ChangeNotifierProvider(create: (_) => RentalCartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutViewModel()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProvider(create: (_) => RentalOrderViewModel()),
        ChangeNotifierProvider(create: (_) => ProductListViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => AddressSelectionViewModel()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
        ChangeNotifierProvider(create: (_) => ShopViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        


>>>>>>> origin/fix
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
<<<<<<< HEAD
      home: CampingProductListScreen(),
=======
      //home: HomePage(),
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomePage(), 
        '/post_product': (context) => const PostProductScreen(), 
        '/my-order' : (context) => const MyRentalsScreen(),
        '/owner-orders-list': (context) => const OwnerRentalListScreen(),
        '/profile' : (context) => const ProfileScreen(),
        '/mainscreen' : (context) => const MainScreen()
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

        if (settings.name == '/owner-filter') {
          final int requestId = settings.arguments != null ? settings.arguments as int : 1003; 
          
          return MaterialPageRoute(
            builder: (context) => OwnerRentalManagementScreen(rentalRequestId: requestId),
          );
        }
       
        return null;
      },
>>>>>>> origin/fix
    );
  }
}
