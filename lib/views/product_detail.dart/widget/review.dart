import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentshare_app/models/reviews_model.dart'; 

class ReviewTab extends StatelessWidget {
  final List<ReviewModel> reviews; 

  const ReviewTab({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text("Sản phẩm chưa có lượt đánh giá nào.", style: TextStyle(color: Colors.grey)));
    }

    int total = reviews.length;
    double average = reviews.map((r) => r.rating).reduce((a, b) => a + b) / total;
    
    int getCount(int star) => reviews.where((r) => r.rating == star).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSummary(average, total, getCount),
          const Divider(height: 40, thickness: 0.5),
          ...reviews.map((r) => ReviewItem(review: r)),
        ],
      ),
    );
  }

  Widget _buildSummary(double average, int total, int Function(int) getCount) {
    return Row(
      children: [
        Column(
          children: [
            Text(average.toStringAsFixed(1), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
            const Text("/5", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < average.floor() ? Colors.orange : Colors.grey[300], size: 14))),
          ],
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Column(
            children: List.generate(5, (i) => 5 - i).map((star) => 
              _ratingBar("$star sao", total > 0 ? getCount(star) / total : 0)
            ).toList(),
          ),
        )
      ],
    );
  }

  Widget _ratingBar(String label, double percent) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(child: LinearProgressIndicator(value: percent, color: Colors.orange, backgroundColor: Colors.grey[200])),
      ],
    );
  }
}


class ReviewItem extends StatelessWidget {
  final ReviewModel review;
  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: review.userAvatar.isNotEmpty ? NetworkImage(review.userAvatar) : null,
              child: review.userAvatar.isEmpty ? const Icon(Icons.person, size: 16) : null,
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < review.rating ? Colors.orange : Colors.grey[300], size: 12))),
            ]),
            const Spacer(),
            Text(
            _formatDate(review.createdAt), 
            style: const TextStyle(color: Colors.grey, fontSize: 11)
          ),
          ],
        ),
        const SizedBox(height: 8),
        Text(review.comment),
        if (review.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network( review.images[index], width: 80, height: 80, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        const Divider(height: 30, thickness: 0.3),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateStr; 
    }
  }
}