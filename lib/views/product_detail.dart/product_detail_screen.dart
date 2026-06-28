import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/cart_model.dart';
import 'package:rentshare_app/models/product_model.dart';
import 'package:rentshare_app/utils/dialog_confirm.dart';
import 'package:rentshare_app/viewmodels/rental_cart_viewmodel.dart';
import 'package:rentshare_app/views/cartpage/cart.dart';
import 'package:rentshare_app/views/checkout_page/checkout.dart'; 
import 'package:rentshare_app/views/post_product.dart/widgets/prolicies_detail_tab.dart';
import 'package:rentshare_app/views/product_detail.dart/widget/detailProductTab.dart';
import '../../viewmodels/product_detail_viewmodel.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients && _pageController.position.maxScrollExtent > 0) {
        int nextPage = _pageController.page!.toInt() + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0056D2); 
    return ChangeNotifierProvider(
      create: (_) => ProductDetailViewModel()..loadProductDetail(widget.productId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<ProductDetailViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) return const Center(child: CircularProgressIndicator(color: themeColor));
            if (vm.errorMessage != null) return Center(child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)));
            if (vm.product == null) return const Center(child: Text("Không có dữ liệu sản phẩm"));

            final item = vm.product!;
            return Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _buildAppBar(item),
                    _buildTabBar(item),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      DetailTab(item: item),
                      _buildReviewTab(item),     
                      PolicyTab(item: item), 
                    ],
                  ),
                ),
                _buildBottomAction(item),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(ProductModel item) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: _circleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
      ),
      actions: [
        _circleBtn(Icons.favorite_border, () {}),
        const SizedBox(width: 10),
        _circleBtn(Icons.share_outlined, () {}),
        const SizedBox(width: 15),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: item.images.isEmpty ? 1 : 1000, 
              onPageChanged: (i) {
                if (item.images.isNotEmpty) {
                  setState(() => _currentImageIndex = i % item.images.length);
                }
              },
              itemBuilder: (c, i) {
                if (item.images.isEmpty) {
                  return Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 50));
                }
                final index = i % item.images.length;
                return Image.network(
                  item.images[index], 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 50)),
                );
              },
            ),
            if (item.images.isNotEmpty)
              Positioned(
                bottom: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    "${_currentImageIndex + 1}/${item.images.length}", 
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ProductModel item) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0056D2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0056D2),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            const Tab(text: "Chi tiết"),
            Tab(text: "Đánh giá (${item.reviews.length})"), 
            const Tab(text: "Chính sách")
          ],
        ),
      ),
    );
  }

  

  Widget _buildReviewTab(ProductModel item) {
    if (item.reviews.isEmpty) {
      return const Center(child: Text("Sản phẩm chưa có lượt đánh giá nào.", style: TextStyle(color: Colors.grey)));
    }

    int total = item.reviews.length;
    int star5 = item.reviews.where((r) => r.rating == 5).length;
    int star4 = item.reviews.where((r) => r.rating == 4).length;
    int star3 = item.reviews.where((r) => r.rating == 3).length;
    int star2 = item.reviews.where((r) => r.rating == 2).length;
    int star1 = item.reviews.where((r) => r.rating == 1).length;

    double average = item.reviews.map((r) => r.rating).reduce((a, b) => a + b) / total;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text(average.toStringAsFixed(1), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                  const Text("/5", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < average.floor() ? Colors.orange : Colors.grey[300], size: 14))),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  children: [
                    _ratingBar("5 sao", total > 0 ? star5 / total : 0),
                    _ratingBar("4 sao", total > 0 ? star4 / total : 0),
                    _ratingBar("3 sao", total > 0 ? star3 / total : 0),
                    _ratingBar("2 sao", total > 0 ? star2 / total : 0),
                    _ratingBar("1 sao", total > 0 ? star1 / total : 0),
                  ],
                ),
              )
            ],
          ),
          const Divider(height: 40, thickness: 0.5),
          ...item.reviews.map((r) => _reviewItem(r)),
        ],
      ),
    );
  }

  Widget _reviewItem(dynamic review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16, 
              backgroundColor: Colors.grey[200],
              backgroundImage: (review.userAvatar != null && review.userAvatar.isNotEmpty) ? NetworkImage(review.userAvatar) : null,
              child: review.userAvatar == null ? const Icon(Icons.person, size: 16, color: Colors.grey) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.userName ?? "Người dùng ẩn danh", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                Row(
                  children: List.generate(5, (i) => Icon(
                    Icons.star_rounded, 
                    color: i < (review.rating ?? 5) ? Colors.orange : Colors.grey[300], 
                    size: 12
                  )),
                ),
              ],
            ),
            const Spacer(),
            const Text("2 ngày trước", style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        Text(review.comment ?? "Sản phẩm dùng cực kỳ tốt!", style: const TextStyle(height: 1.4, fontSize: 13)),
        const Divider(height: 30, thickness: 0.3),
      ],
    );
  }


  //   Widget _buildBottomAction(ProductModel item) {
  //   const themeColor = Color(0xFF0056D2);

  //   return Positioned(
  //     bottom: 0, left: 0, right: 0,
  //     child: Container(
  //       padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
  //       decoration: BoxDecoration(
  //         color: Colors.white, 
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withValues(alpha: 0.06), 
  //             blurRadius: 10, 
  //             offset: const Offset(0, -4),
  //           )
  //         ],
  //       ),
  //       child: SafeArea(
  //         bottom: true,
  //         top: false,
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: OutlinedButton(
  //                 onPressed: () async {
  //                 final newItem = RentalCartItem(
  //                   productId: item.id, 
  //                   ownerId: item.ownerId,
  //                   ownerAvatar: item.ownerAvatar,
  //                   ownerName: item.ownerName,
  //                   ownerPhone: item.shopInfo?.receiverPhone ?? '0789617936',
  //                   pricePerDay: double.tryParse(item.pricePerDay) ?? 0.0,
  //                   title: item.title,
  //                   image: item.images.isNotEmpty ? item.images.first : '', 
  //                   quantity: 1, 
  //                   maxStock: item.quantity,
  //                   depositAmount: double.tryParse(item.depositAmount) ?? 0.0, 
  //                   ownerAddress: item.location,
  //                   tierPricings: item.tierPricings
  //                 );
  //                 final cartProvider = context.read<RentalCartProvider>();
  //                 String result = await cartProvider.addToCart(newItem);
  //                 if (result == 'DIFFERENT_SHOP') {
  //                   if (!mounted) return;
  //                   bool shouldClearCart = await DifferentShopDialog.show(
  //                     context: context, 
  //                     title: "Thông báo khác Shop", 
  //                     content: "Bạn đang có sản phẩm từ Shop khác trong đơn thuê. Bạn có muốn xóa giỏ hiện tại và thuê sản phẩm mới này không?",
  //                     actionButtonText: "Xóa giỏ và thêm", 
  //                   );
  //                   if (shouldClearCart) {
  //                     await cartProvider.clearAndAddNewProduct(newItem);
                      
  //                     if (!mounted) return;
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                         content: Text("Đã dọn sạch giỏ cũ và làm mới với sản phẩm của Shop này!"), 
  //                         backgroundColor: Color(0xff1B8A4B),
  //                         duration: Duration(milliseconds: 800), 
  //                       ),
  //                     );

  //                     Future.delayed(const Duration(milliseconds: 1000), () {
  //                       if (!mounted) return;
  //                       Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
  //                     });
  //                   }

  //                 } else {
  //                   if (!mounted) return;
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text("Đã thêm sản phẩm vào giỏ thuê thành công!"), 
  //                       backgroundColor: Color(0xff1B8A4B),
  //                       duration: Duration(milliseconds: 800),
  //                     ),
  //                   );
  //                   Future.delayed(const Duration(milliseconds: 1000), () {
  //                     if (!mounted) return;
  //                     Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
  //                   });
  //                 }

                  
  //               },
  //                 style: OutlinedButton.styleFrom(
  //                   foregroundColor: themeColor,
  //                   side: const BorderSide(color: themeColor, width: 1.5), 
  //                   padding: const EdgeInsets.symmetric(vertical: 14),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8), 
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   "Thêm vào đơn thuê",
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //                 ),
  //               ),
  //             ),
              
  //             const SizedBox(width: 12), 

  //             Expanded(
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   // Logic điều hướng trực tiếp qua trang Thanh toán đơn thuê
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: themeColor,
  //                   foregroundColor: Colors.white,
  //                   padding: const EdgeInsets.symmetric(vertical: 14),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   elevation: 0, 
  //                 ),
  //                 child: const Text(
  //                   "Thuê ngay",
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildBottomAction(ProductModel item) {
    const themeColor = Color(0xFF0056D2);
    Future<void> handleAddToCart(bool isCheckout) async {
      final newItem = RentalCartItem(
        productId: item.id,
        ownerId: item.ownerId,
        ownerAvatar: item.ownerAvatar,
        ownerName: item.ownerName,
        ownerPhone: item.shopInfo?.receiverPhone ?? '0789617936',
        pricePerDay: double.tryParse(item.pricePerDay) ?? 0.0,
        title: item.title,
        image: item.images.isNotEmpty ? item.images.first : '',
        quantity: 1,
        maxStock: item.quantity,
        depositAmount: double.tryParse(item.depositAmount) ?? 0.0,
        ownerAddress: item.location,
        tierPricings: item.tierPricings
      );

      final cartProvider = context.read<RentalCartProvider>();
      String result = await cartProvider.addToCart(newItem);

      if (result == 'DIFFERENT_SHOP') {
        if (!mounted) return;
        bool shouldClearCart = await DifferentShopDialog.show(
          context: context,
          title: "Thông báo khác Shop",
          content: "Bạn đang có sản phẩm từ Shop khác trong đơn thuê. Bạn có muốn xóa giỏ hiện tại và thuê sản phẩm mới này không?",
          actionButtonText: "Xóa giỏ và thêm",
        );
        if (shouldClearCart) {
          await cartProvider.clearAndAddNewProduct(newItem);
        } else {
          return; 
        }
      }
      if (!mounted) return;
        if (isCheckout) {
          await cartProvider.setCheckoutItem(newItem);
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => CheckoutPage(
                product: newItem, 
                shopAddress: newItem.ownerAddress 
              )
            )
          );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã thêm sản phẩm vào giỏ thuê thành công!"),
            backgroundColor: Color(0xff1B8A4B),
            duration: Duration(milliseconds: 800),
          ),
        );

        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const CartPage())
        );
      }
    }

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white, 
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))]
        ),
        child: SafeArea(
          bottom: true, top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => handleAddToCart(false), 
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColor,
                    side: const BorderSide(color: themeColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Thêm vào đơn thuê", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => handleAddToCart(true), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Thuê ngay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData i, VoidCallback t) => CircleAvatar(radius: 18, backgroundColor: Colors.white.withOpacity(0.9), child: IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: Icon(i, color: Colors.black, size: 18), onPressed: t));
  Widget _ratingBar(String l, double v) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [SizedBox(width: 38, child: Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey))), const SizedBox(width: 4), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: v, backgroundColor: Colors.grey[100], color: const Color(0xFF0056D2), minHeight: 5)))]));
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverAppBarDelegate(this.tabBar);
  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;
  @override Widget build(c, s, o) => Container(color: Colors.white, child: tabBar);
  @override bool shouldRebuild(_) => false;
}