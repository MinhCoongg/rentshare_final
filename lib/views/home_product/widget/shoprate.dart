import 'package:flutter/material.dart';
import 'package:rentshare_app/models/shop_model.dart'; 

class HorizontalShopList extends StatelessWidget {
  final List<ShopHomeModel> shopList;
  final Color themeColor;

  const HorizontalShopList({
    super.key,
    required this.shopList,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (shopList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Text(
          "Hiện tại chưa có cửa hàng nổi bật.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 145, 
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal, 
        itemCount: shopList.length,
        itemBuilder: (context, index) {
          final shop = shopList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildShopCard(shop),
          );
        },
      ),
    );
  }

  Widget _buildShopCard(ShopHomeModel shop) {
    return Container(
      width: 110, 
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: themeColor.withValues(alpha: 0.1),
            backgroundImage: shop.avatar.isNotEmpty ? NetworkImage(shop.avatar) : null,
            child: shop.avatar.isEmpty
                ? Text(
                    shop.name[0].toUpperCase(),
                    style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            shop.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.orange, size: 12),
              Text(
                " ${shop.shopRating} (${shop.totalReviews})",
                style: const TextStyle(color: Colors.grey, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "${shop.totalProducts} sản phẩm",
            style: TextStyle(color: Colors.grey[400], fontSize: 9),
          ),
        ],
      ),
    );
  }
}