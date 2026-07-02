import 'package:flutter/material.dart';

class CampingProductListScreen extends StatelessWidget {
  const CampingProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data giả lập dựa theo hình ảnh của bạn
    final List<Map<String, dynamic>> products = [
      {
        'title': 'Lều cắm trại 4 người chống nước',
        'image':
            'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=500',
        'rating': 4.8,
        'reviews': 128,
        'price': '200.000đ',
        'location': 'Q. 2, TP. HCM',
      },
      {
        'title': 'Đèn măng xông LED Vintage',
        'image':
            'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=500',
        'rating': 4.9,
        'reviews': 64,
        'price': '100.000đ',
        'location': 'Q. 7, TP. HCM',
      },
      {
        'title': 'Bộ bàn ghế xếp gọn dã ngoại',
        'image':
            'https://images.unsplash.com/photo-1617083239121-6d8ec5a467e2?w=500',
        'rating': 4.7,
        'reviews': 43,
        'price': '150.000đ',
        'location': 'Q. Phú Nhuận',
      },
      {
        'title': 'Bếp gas mini du lịch',
        'image':
            'https://images.unsplash.com/photo-1594498653385-d5172b532c00?w=500',
        'rating': 4.8,
        'reviews': 87,
        'price': '80.000đ',
        'location': 'Q. Bình Thạnh',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () {},
        ),
        title: const Text(
          'Dã ngoại cắm trại',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Nút Lọc góc phải trên cùng
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.tune, size: 16, color: Colors.black87),
                SizedBox(width: 4),
                Text(
                  'Lọc',
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thanh tìm kiếm (Search Bar)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                fillColor: Colors.grey[50],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Thanh bộ lọc nhanh (Sắp xếp, Giá, Danh mục...)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterDropdown('Sắp xếp'),
                _buildFilterDropdown('Giá'),
                _buildFilterDropdown('Danh mục'),
                _buildFilterDropdown('Khu vực'),
              ],
            ),
          ),

          // 3. Số lượng sản phẩm
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              '128 sản phẩm',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),

          // 4. Danh sách sản phẩm (ListView)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return _buildProductItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget bổ trợ tạo các nút Filter Dropdown nhanh
  Widget _buildFilterDropdown(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  // Widget tạo từng dòng sản phẩm (Product Card Row)
  Widget _buildProductItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Tạo đổ bóng nhẹ xung quanh card như hình mẫu
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hình ảnh sản phẩm (bên trái)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.network(
              item['image'],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback nếu ảnh lỗi
                return Container(
                  width: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),

          // Thông tin chi tiết sản phẩm (bên phải)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tiêu đề và nút thả tim
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ],
                  ),

                  // Đánh giá sao
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${item['rating']} (${item['reviews']})',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),

                  // Giá tiền và địa điểm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: item['price'],
                              style: const TextStyle(
                                color: Colors
                                    .indigo, // Màu xanh tím đậm giống hình
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: ' / ngày',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item['location'],
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
