import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/viewmodels/review_viewmodel.dart';

class WriteReviewScreen extends StatefulWidget {
   final OrderDetailItem item;
   final int idInvoiceDetail;
  const WriteReviewScreen({super.key, required this.item, required this.idInvoiceDetail});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File>? _images = [];
  

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chia sẻ suy nghĩ của bạn về sản phẩm")),
      );
      return;
    }

    debugPrint('idInvoiceDetail ${widget.idInvoiceDetail}');

    bool success = await context.read<ReviewProvider>().addReview(
      productId: widget.item.productId,
      rating:  _rating,
      comment:  _commentController.text,
      invoiceDetailId:  widget.idInvoiceDetail,
      images:  _images
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cảm ơn bạn đã đánh giá!"), backgroundColor: Colors.green),
      );
      context.read<RentalOrderViewModel>().loadMyOrders();
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại"), backgroundColor: Colors.red),
      );
    }
  }

  bool _isPicking = false;
  Future<void> _handlePickImage() async {
    if (_isPicking) return; 

    setState(() {
      _isPicking = true;
    });

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _images?.addAll(
            pickedFiles.map((e) => File(e.path)),
          );
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi chọn ảnh: $e");
    } finally {
      setState(() {
        _isPicking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text("Viết đánh giá", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          widget.item.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => Container(width: 48, height: 48, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
      
                          ],
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  Center(
                    child: Column(
                      children: [
                        RatingBar.builder(
                          initialRating: 5,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 40,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() => _rating = rating);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getRatingText(_rating),
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!)
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 5,
                      maxLength: 300,
                      decoration: const InputDecoration(
                        hintText: "Hãy chia sẻ cảm nhận, suy nghĩ của bạn về sản phẩm...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        counterText: "",
                      ),
                    ),
                  ),
                
                  const SizedBox(height: 20),
                  const Text("Thêm ảnh hoặc video", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _handlePickImage();
                    },
                    child: (_images != null && _images!.isNotEmpty)
                    ?Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _images!.map((file) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        file,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _images!.remove(file)),
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close, size: 15, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () => setState(() => _images = null),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 15, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      )
                     : DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(8),
                      dashPattern: const [6, 3],
                      color: Colors.amber,
                      child: Container(
                        width: double.infinity,
                        height: 80,
                        alignment: Alignment.center,
                        color: Colors.amber.withValues(alpha: 0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_outlined, color: Colors.amber),
                            SizedBox(height: 4),
                            Text("Thêm ảnh/video", style: TextStyle(color: Colors.amber, fontSize: 12))
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                ],
              ),
            ),
          ),

          // 7. Nút Gửi (Ghim ở dưới cùng)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))]
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Consumer<ReviewProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.loading ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107), 
                      foregroundColor: Colors.white, 
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: provider.loading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Gửi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                }
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return "Tuyệt vời";
    if (rating >= 4) return "Hài lòng";
    if (rating >= 3) return "Bình thường";
    if (rating >= 2) return "Không hài lòng";
    return "Tệ";
  }
}