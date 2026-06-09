import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/viewmodels/product_detail_viewmodel.dart';
import 'package:rentshare_app/views/login/login.dart';
import 'package:rentshare_app/views/post_product.dart/post_product_screen.dart';




void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProductViewModel()),
        //ChangeNotifierProvider(create: (_) => ProductDetailViewModel()) 
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
        '/post_product': (context) => const PostProductScreen(), 
      },
    );
  }
}