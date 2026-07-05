import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/auth_viewmodel.dart';
import 'package:rentshare_app/viewmodels/chat_viewmodel.dart';
import 'package:rentshare_app/viewmodels/dashboard_viewmodel.dart';
import 'package:rentshare_app/viewmodels/login_viewmodel.dart';
import 'package:rentshare_app/viewmodels/navigation_provider.dart';
import 'package:rentshare_app/viewmodels/rental_cart_viewmodel.dart';
import 'package:rentshare_app/viewmodels/user_viewmodel.dart';
import 'package:rentshare_app/views/Admin/login/login.dart';
import 'package:rentshare_app/views/Admin/product_management.dart'; 
import 'package:rentshare_app/viewmodels/AdminProductViewModel.dart';
import 'package:rentshare_app/views/Admin/sidebar/main_layout.dart';
import 'package:rentshare_app/views/mainscreen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RentalCartProvider()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel())
      ],
      child: MaterialApp(
        title: 'RentShare Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.indigo),
        initialRoute: '/',
        routes: {
        '/': (context) => LoginView(),
        '/mainscreen': (context) => MainScreen(),
        '/admin-dashboard': (context) => AdminProductScreen(),
        '/admin-layout': (context) => MainLayout(),
      },
      ),
    ),
  );
}