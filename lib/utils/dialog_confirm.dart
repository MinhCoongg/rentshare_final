import 'package:flutter/material.dart';

class DifferentShopDialog extends StatelessWidget {
  final String title;
  final String content;
  final String actionButtonText; // 🎯 BƠM THÊM BIẾN CHỮ CHO NÚT BẤM ĐỘNG NÀY NÍ!

  const DifferentShopDialog({
    super.key, 
    required this.title, 
    required this.content,
    required this.actionButtonText, 
  });

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    required String actionButtonText, 
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, 
      builder: (dialogContext) => DifferentShopDialog(
        title: title,
        content: content,
        actionButtonText: actionButtonText,
      ),
    );
    return result ?? false; 
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            "Hủy",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0056D2), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            actionButtonText,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}