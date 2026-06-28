import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/category_model.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/views/filterProduct/product_list_filter_screen.dart';
import 'package:rentshare_app/views/home_product/widget/cardproduct.dart';
import 'package:rentshare_app/views/home_product/widget/shoprate.dart';
import 'package:rentshare_app/views/product_detail.dart/product_detail_screen.dart'; 
import '../../viewmodels/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVm = Provider.of<HomeViewModel>(context, listen: false);
      homeVm.fetchCategories(); 
      homeVm.fetchProducts();   
    });
  }

  @override
  void dispose(){
    super.dispose();
    _searchController.dispose();
  }



  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0056D2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: themeColor, size: 20),
            const SizedBox(width: 4),
            const Text(
              "RENTSHARE",
              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: themeColor));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController, 
                            decoration: const InputDecoration(
                              hintText: "Bạn muốn thuê gì?",
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 13.5),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductListScreen(
                                      categoryId: 0, 
                                      categoryName: "Kết quả: $value",
                                      keyword: value, 
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: themeColor,
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Danh mục phổ biến", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 95, 
                child: vm.categories.isEmpty
                    ? const Center(child: Text("Chưa có danh mục nào", style: TextStyle(color: Colors.grey, fontSize: 12)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: vm.categories.length,
                        itemBuilder: (context, index) {
                          final CategoryModel cat = vm.categories[index]; 
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductListScreen(
                                    categoryId: cat.id,
                                    categoryName: cat.categoryName,
                                  ),
                                ),
                              );
                            },
                              child: Column(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: themeColor.withValues(alpha: 0.06), 
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(26), 
                                      child: cat.categoryImage != null && cat.categoryImage!.isNotEmpty
                                          ? Image.network(
                                              cat.categoryImage!,
                                              fit: BoxFit.cover, 
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                Icons.category_rounded, 
                                                color: themeColor, 
                                                size: 22,
                                              ),
                                            )
                                          : Icon(
                                              Icons.category_rounded, 
                                              color: themeColor, 
                                              size: 22,
                                            ), 
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 75,
                                    child: Text(
                                      cat.categoryName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

                const Divider(height: 25, thickness: 0.5),


                _buildSectionTitle("Sản phẩm nổi bật", themeColor),
                _buildHorizontalProductList(vm.featuredProducts, themeColor),

                _buildSectionTitle("Mới đăng hôm nay", themeColor),
                _buildHorizontalProductList(vm.newestProducts, themeColor),

                _buildSectionTitle("Có thể bạn quan tâm", themeColor),
                _buildHorizontalProductList(vm.suggestedProducts, themeColor),

                _buildSectionTitle("Shop được tin tưởng", themeColor),
                HorizontalShopList(
                  shopList: vm.trustedShops,
                  themeColor: themeColor,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
          TextButton(
            onPressed: () {}, 
            child: Text("Xem tất cả", style: TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }


  Widget _buildHorizontalProductList(List<ProductHomeModel> productList, Color themeColor) {
    if (productList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Text("Hiện tại chưa có sản phẩm nào.", style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }

    return SizedBox(
      height: 210, 
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal, 
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ProductHomeCard(
              product:  product,
              themeColor:  themeColor,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(productId: product.id)));
              },
              
              ),
          );
        },
      ),
    );
  }
}