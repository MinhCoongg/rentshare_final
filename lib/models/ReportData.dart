import 'dart:io';
import 'package:rentshare_app/models/policy_model.dart';

class ReportData {
  int productId;
  double deposit;
  int lateDays;
  PolicyModel latePolicy;
  
  // Dùng 3 cái bool này thôi, dứt khoát không dùng status hay enum
  bool isGood = false; 
  bool isLate = false;
  bool isBroken = false;
  
  double damagePercent = 0; 
  String note = "";
  File? image;

  ReportData({
    required this.productId,
    required this.deposit,
    this.lateDays = 0,
    required this.latePolicy,
  });

  double calculateFee() {
    double totalFine = 0;
    if (isLate) {
      totalFine += lateDays * latePolicy.fineValue;
    }
    if (isBroken) {
      totalFine += (deposit * (damagePercent / 100));
    }
    return totalFine;
  }
}