import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/shop_viewmodel.dart';
import 'package:rentshare_app/views/home_product/widget/cardproduct.dart';
import 'package:rentshare_app/views/product_detail.dart/product_detail_screen.dart';


class ShopPage extends StatefulWidget {
  final int shopId;
  const ShopPage({super.key, required this.shopId});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopViewModel>(context, listen: false).loadShopDetail(widget.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Shop", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ShopViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          if (vm.shopDetail == null) return const Center(child: Text("Không tìm thấy shop"));

          final shop = vm.shopDetail!.shopInfo;
          final products = vm.shopDetail!.products;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(shop.shopAvatar ?? ""),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shop.shopName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 16),
                              Text(" ${shop.shopRating} (${shop.totalRentals - 1} đơn thuê)"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ProductHomeCard(
                        product: products[index],
                        themeColor: Colors.indigo,
                        onTap: () { 
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(productId: products[index].id)));
                         },
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}