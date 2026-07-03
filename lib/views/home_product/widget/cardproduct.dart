import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/wishlist_viewmodel.dart'; 

class ProductHomeCard extends StatelessWidget {
  final ProductHomeModel product;
  final Color themeColor;
  final VoidCallback onTap; 

  const ProductHomeCard({
    super.key,
    required this.product,
    required this.themeColor,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, 
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              width: 175, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images, 
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(color: Colors.grey[100], child: const Icon(Icons.image, color: Colors.grey)),
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 26),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.orange, size: 13),
                            Text(" ${product.rating} (${product.reviewCount})", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${FormatUtils.formatMoney(product.minPrice)}đ / ngày",
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.grey[400], size: 11),
                            Expanded(
                              child: Text(
                                " ${product.location}", 
                                style: const TextStyle(color: Colors.grey, fontSize: 9.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  Provider.of<WishlistProvider>(context, listen: false).toggleWishlist(product.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white70, 
                    shape: BoxShape.circle
                  ),
                  child: Consumer<WishlistProvider>(
                    builder: (context, provider, _) {
                      bool isFav = provider.isFavorite(product.id);
                      return Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}