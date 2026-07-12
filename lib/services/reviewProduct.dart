import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/reviews_model.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';

class ReviewApi {
  static Future<List<ReviewModel>> getReviews({
    required int productId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ConstantURL.baseUrl}/review/product/$productId?page=$page&limit=$limit",
        ),
        headers: {
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return (data["data"] as List)
            .map((e) => ReviewModel.fromJson(e))
            .toList();
      }

      throw Exception(data["message"]);
    } catch (e) {
      throw Exception("Không thể tải đánh giá: $e");
    }
  }

  ///=========================
  /// Thêm đánh giá
  ///=========================
  static Future<bool> addReview({
    required int productId,
    required int invoiceDetailId,
    required double rating,
    required String comment,
    List<File>? images = const [],
  }) async {
    try {
      final token = await SharedPrefsUtils.getToken();
      final List<File> listImages = images ?? [];
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ConstantURL.baseUrl}/review/add"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["productId"] = productId.toString();
      request.fields["invoiceDetailId"] = invoiceDetailId.toString();
      request.fields["rating"] = rating.toString();
      request.fields["comment"] = comment;

      /// upload nhiều ảnh
      for (final image in listImages) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "images",
            image.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("========== REVIEW RESPONSE ==========");
      debugPrint(response.body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data["success"] == true;
      }

      throw Exception(data["message"]);
    } catch (e) {
      debugPrint("Review Error: $e");
      rethrow;
    }
  }

  ///=========================
  /// Xóa đánh giá
  ///=========================
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final token = await SharedPrefsUtils.getToken();

      final response = await http.delete(
        Uri.parse("${ConstantURL.baseUrl}/review/$reviewId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data["success"] == true;
      }

      throw Exception(data["message"]);
    } catch (e) {
      rethrow;
    }
  }
}