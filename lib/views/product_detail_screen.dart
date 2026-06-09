// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rentshare_app/models/product_model.dart';
// import 'package:rentshare_app/models/reviews_model.dart';
// import 'package:rentshare_app/views/post_product.dart/widgets/prolicies_detail_tab.dart';
// import '../viewmodels/product_detail_viewmodel.dart';

// class ProductDetailPage extends StatefulWidget {
//   final int productId;
//   const ProductDetailPage({super.key, required this.productId});

//   @override
//   State<ProductDetailPage> createState() => _ProductDetailPageState();
// }

// class _ProductDetailPageState extends State<ProductDetailPage> with TickerProviderStateMixin {
//   late TabController _tabController;
//   final PageController _pageController = PageController();
//   Timer? _timer;
//   int _currentImageIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
//       if (_pageController.hasClients) {
//         int nextPage = _currentImageIndex + 1;
//         _pageController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 3000),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ProductDetailViewModel()..fetchProductDetail(widget.productId),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Consumer<ProductDetailViewModel>(
//           builder: (context, vm, child) {
//             if (vm.isLoading) return const Center(child: CircularProgressIndicator());
//             if (vm.product == null) return const Center(child: Text("Không có dữ liệu"));
//             final item = vm.product!;
//             return Stack(
//               children: [
//                 NestedScrollView(
//                   headerSliverBuilder: (context, innerBoxIsScrolled) => [
//                     _buildAppBar(item),
//                     _buildTabBar(item),
//                   ],
//                   body: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildDetailTab(item), 
//                       _buildReviewTab(item),     
//                       PolicyTab(item: item),
//                     ],
//                   ),
//                 ),
//                 _buildBottomAction(item),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//   Widget _buildAppBar(item) {
//     return SliverAppBar(
//       expandedHeight: 350,
//       pinned: true,
//       elevation: 0,
//       backgroundColor: Colors.white,
//       leading: _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
//       actions: [
//         _circleBtn(Icons.favorite_border, () {}),
//         const SizedBox(width: 10),
//         _circleBtn(Icons.share_outlined, () {}),
//         const SizedBox(width: 15),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             PageView.builder(
//               controller: _pageController,
//               itemCount: item.images.length,
//               onPageChanged: (i) => setState(() => _currentImageIndex = (i % item.images.length).toInt()),
//               itemBuilder: (c, i) {
//                 final index = i % item.images.length;
//                 return Image.network(item.images[index], fit: BoxFit.cover);
//               },
//             ),
//             Positioned(
//               bottom: 20, right: 20,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
//                 child: Text("${_currentImageIndex + 1}/${item.images.length}", 
//                   style: const TextStyle(color: Colors.white, fontSize: 12)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }


//   Widget _buildTabBar(item) {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: _SliverAppBarDelegate(
//         TabBar(
//           controller: _tabController,
//           labelColor: const Color(0xFF0056D2),
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: const Color(0xFF0056D2),
//           indicatorWeight: 3,
//           tabs: [const Tab(text: "Chi tiết"),Tab(text: "Đánh giá (${item.reviews.length})"), const Tab(text: "Chính sách")],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailTab(item) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//           Row(children: const [Icon(Icons.star, color: Colors.orange, size: 18), Text(" 4.8 (128 đánh giá)")]),
//           const SizedBox(height: 20),
          
//           ListTile(
//             contentPadding: EdgeInsets.zero,
//             leading: CircleAvatar(backgroundImage: NetworkImage(item.ownerAvatar)),
//             title: Row(children: [
//               Text(item.ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(width: 6),
//               const Icon(Icons.verified, color: Colors.blue, size: 14),
//             ]),
//             subtitle: const Text("Chủ sở hữu", style: TextStyle(color: Colors.blue, fontSize: 12)),
//             trailing: OutlinedButton.icon(
//               onPressed: () {}, icon: const Icon(Icons.chat_outlined, size: 16), label: const Text("Nhắn tin"),
//               style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
//             ),
//           ),

//           // Thanh tóm tắt nhanh
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _summary(Icons.category_outlined, item.categoryName ?? ""),
//                 _summary(Icons.location_on_outlined, item.location.split(',').first),
//                 _summary(Icons.monitor_weight_outlined, item.specifications['Trọng lượng'] ?? ""),
//               ],
//             ),
//           ),
//           const Divider(height: 40),

//           const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Text(item.description, style: const TextStyle(color: Colors.grey, height: 1.5)),
          
//           const Divider(height: 40),
//           const Text("Thông tin chi tiết", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 15),
//           ...item.specifications.entries.map((e) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start, 
//               children: [
//                 SizedBox(
//                   width: 100, 
//                   child: Text(e.key, style: const TextStyle(color: Colors.grey)),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded( 
//                   child: Text(
//                     e.value, 
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                     textAlign: TextAlign.right, 
//                   ),
//                 ),
//               ],
//             ),
//           )).toList(),
//           const Divider(height: 40),

//           const Text("Đặc điểm nổi bật", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ...(item.features.toString().split('|')).map((f) {
//             final cleanFeature = f.trim(); 
//             if (cleanFeature.isEmpty) return const SizedBox.shrink();

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start, // Icon thẳng hàng với dòng chữ đầu tiên
//                 children: [
//                   const Icon(Icons.check_circle, color: Colors.green, size: 18), 
//                   const SizedBox(width: 10), 
//                   Expanded(
//                     child: Text(
//                       cleanFeature, // Giờ nó in ra từng chữ "chống nước", "khung sợi..." riêng biệt nè ní
//                       style: const TextStyle(fontSize: 14, height: 1.4),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//           const SizedBox(height: 100),
//         ],
//       ),
//     );
//   }


//   Widget _buildReviewTab(ProductModel item) {
//     if (item.reviews.isEmpty) return const Center(child: Text("Chưa có đánh giá"));

//     // 1. Tính toán số lượng cho từng mức sao
//     int total = item.reviews.length;
//     int star5 = item.reviews.where((r) => r.rating == 5).length;
//     int star4 = item.reviews.where((r) => r.rating == 4).length;
//     int star3 = item.reviews.where((r) => r.rating == 3).length;
//     int star2 = item.reviews.where((r) => r.rating == 2).length;
//     int star1 = item.reviews.where((r) => r.rating == 1).length;

//     // 2. Tính điểm trung bình (Ví dụ: 4.8)
//     double average = item.reviews.isEmpty ? 0.0 : 
//       item.reviews.map((r) => r.rating).reduce((a, b) => a + b) / total;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Column(children: [
//                 Text(average.toStringAsFixed(1), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
//                 const Text("/5", style: TextStyle(color: Colors.grey)),
//                 Row(children: List.generate(5, (i) => Icon(Icons.star, color: i < average.floor() ? Colors.orange : Colors.grey[300], size: 14))),
//               ]),
//               const SizedBox(width: 30),
//               Expanded(
//                 child: Column(
//                   children: [
//                     // Tự động tính phần trăm: (số sao / tổng số review)
//                     _ratingBar("5 sao", total > 0 ? star5 / total : 0),
//                     _ratingBar("4 sao", total > 0 ? star4 / total : 0),
//                     _ratingBar("3 sao", total > 0 ? star3 / total : 0),
//                     _ratingBar("2 sao", total > 0 ? star2 / total : 0),
//                     _ratingBar("1 sao", total > 0 ? star1 / total : 0),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           const Divider(height: 40),
//           ...item.reviews.map((r) => _reviewItem(r)).toList(),
//         ],
//       ),
//     );
//   }

// // Widget Item Review đã được "nâng cấp" để nhận ReviewModel
//   Widget _reviewItem(ReviewModel review) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start, 
//       children: [
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 18, 
//               backgroundImage: NetworkImage(review.userAvatar.isNotEmpty 
//                   ? review.userAvatar 
//                   : "https://i.pravatar.cc/150"), // Link dự phòng
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 Row(
//                   children: List.generate(5, (i) => Icon(
//                     Icons.star, 
//                     color: i < review.rating ? Colors.orange : Colors.grey[300], 
//                     size: 12
//                   )),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Text("Vừa xong", style: const TextStyle(color: Colors.grey, fontSize: 11)), // Hoặc format review.createdAt
//           ],
//         ),
//         const SizedBox(height: 10),
//         Text(review.comment, style: const TextStyle(height: 1.4)),
//         const SizedBox(height: 25),
//       ],
//     );
//   }

//   // --- THANH THANH TOÁN (DỮ LIỆU THẬT) ---
//   Widget _buildBottomAction(item) {
//     return Positioned(
//       bottom: 0, left: 0, right: 0,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
//               Text("${double.parse(item.pricePerDay).toInt()}đ / ngày", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0056D2))),
//               Text("Đặt cọc: ${double.parse(item.depositAmount).toInt()}đ", style: const TextStyle(color: Colors.grey)),
//             ]),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//               child: const Text("Thuê ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _circleBtn(IconData i, VoidCallback t) => CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9), child: IconButton(icon: Icon(i, color: Colors.black, size: 20), onPressed: t));
//   Widget _summary(IconData i, String t) => Row(children: [Icon(i, size: 16, color: Colors.black54), const SizedBox(width: 5), Text(t, style: const TextStyle(fontSize: 12))]);
//   Widget _ratingBar(String l, double v) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Text(l, style: const TextStyle(fontSize: 12)), const SizedBox(width: 8), Expanded(child: LinearProgressIndicator(value: v, backgroundColor: Colors.grey[200], color: Colors.blue, minHeight: 6))]));
  
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   _SliverAppBarDelegate(this.tabBar);
//   @override double get minExtent => tabBar.preferredSize.height;
//   @override double get maxExtent => tabBar.preferredSize.height;
//   @override Widget build(c, s, o) => Container(color: Colors.white, child: tabBar);
//   @override bool shouldRebuild(_) => false;
// }