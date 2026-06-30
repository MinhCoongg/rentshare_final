import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rentshare_app/models/reviews_model.dart';
import 'package:rentshare_app/services/reviewProduct.dart';


class ReviewProvider extends ChangeNotifier {
  List<ReviewModel> _reviews = [];

  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;

  bool get loading => _isLoading;

  Future<void> fetchReviews(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reviews = await ReviewApi.getReviews(
        productId: productId,
      );
    } catch (e) {
      debugPrint("Lỗi load review: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview({
    required int productId,
    required int invoiceDetailId,
    required double rating,
    required String comment,
    List<File>? images = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await ReviewApi.addReview(
        productId: productId,
        invoiceDetailId: invoiceDetailId,
        rating: rating,
        comment: comment,
        images: images,
      );

      if (success) {
        await fetchReviews(productId);
      }

      return success;
    } catch (e) {
      debugPrint("Lỗi thêm review: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview(int reviewId, int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await ReviewApi.deleteReview(reviewId);

      if (success) {
        await fetchReviews(productId);
      }

      return success;
    } catch (e) {
      debugPrint("Lỗi xóa review: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _reviews.clear();
    notifyListeners();
  }
}