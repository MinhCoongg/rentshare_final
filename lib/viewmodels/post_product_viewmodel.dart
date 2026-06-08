import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentshare_app/models/attribute_model.dart';
import 'package:rentshare_app/models/category_model.dart';
import 'package:rentshare_app/models/policy_model.dart';
import '../models/post_product_model.dart';
import '../services/api_services.dart';

class PostProductViewModel extends ChangeNotifier {
  List<File> get selectedFiles => model.images.map((path) => File(path)).toList();
  
  int _currentStep = 0;
  int get currentStep => _currentStep;
  set currentStep(int v) {
    _currentStep = v;
    notifyListeners();
  }

  final model = PostProductModel();
  List<AttributeModel> categoryAttributes = [];
  List<CategoryModel> categoriesTreeData = []; 

  int? _selectedMainCategoryId;
  int? get selectedMainCategoryId => _selectedMainCategoryId;
  int? get selectedSubCategoryId => model.categoryId; 

  List<Map<String, dynamic>> tierPrices = [
    {"minDays": 1, "pricePerDay": 0.0} 
  ];

  bool isLoading = false;
  String? errorMessage;
  final ImagePicker _picker = ImagePicker();


  Future<void> fetchCategories() async {
    try {
      categoriesTreeData = await ApiService.getAllCategories();
    
      if (model.categoryId != null && categoriesTreeData.isNotEmpty) {
        for (var mainCat in categoriesTreeData) {
          bool hasSub = mainCat.subCategories.any((sub) => sub.id == model.categoryId);
          if (hasSub) {
            _selectedMainCategoryId = mainCat.id;
            break;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi đồng bộ cây danh mục tại ViewModel: $e");
      errorMessage = "Không thể tải danh mục hệ thống!";
      notifyListeners();
    }
  }

  void updateProductQuantity(int qty) {
    model.quantity = qty > 0 ? qty : 1;
    errorMessage = null;
    notifyListeners();
  }

  void updateAttribute(int id, String value) {
    model.dynamicAttributes[id] = value;
    errorMessage = null; 
    notifyListeners();
  }

  void selectMainCategoryId(int? mainCatId) {
    _selectedMainCategoryId = mainCatId;
    model.categoryId = null; // Xóa mã con ngay lập tức
    model.dynamicAttributes.clear(); // Xóa thuộc tính động tránh rác đè nhau
    categoryAttributes.clear();
    notifyListeners();
  }

  void selectSubCategoryId(int? subCatId) {
    model.categoryId = subCatId; 
    notifyListeners();
  }


  void updateDepositAmount(String deposit) {
    model.depositAmount = double.tryParse(deposit) ?? 0.0;
    errorMessage = null;
    notifyListeners();
  }

  void addTierPrice() {
    int nextMinDays = 1;
    if (tierPrices.isNotEmpty) {
      nextMinDays = (tierPrices.last["minDays"] as int) + 2; 
    }
    tierPrices.add({"minDays": nextMinDays, "pricePerDay": 0.0});
    notifyListeners();
  }

  void removeTierPrice(int index) {
    if (tierPrices.length > 1) {
      tierPrices.removeAt(index);
      notifyListeners();
    }
  }

  void updateTierPriceValue(int index, {int? minDays, double? pricePerDay}) {
    if (index >= 0 && index < tierPrices.length) {
      if (minDays != null) tierPrices[index]["minDays"] = minDays;
      if (pricePerDay != null) tierPrices[index]["pricePerDay"] = pricePerDay;
      errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> nextStep() async {
    errorMessage = null;
    final String? validationError = _validateCurrentStep();
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return;
    }
    
    if (_currentStep == 0) {
      isLoading = true;
      notifyListeners();
      try {
        if (model.categoryId != null) {
          categoryAttributes = await ApiService.getCategoryFields(model.categoryId!);
        } else {
          categoryAttributes = [];
        }
        currentStep = 1; 
      } catch (e) {
        categoryAttributes = []; 
        currentStep = 1; 
      } finally {
        isLoading = false;
        notifyListeners();
      }
      return;
    }
    
    if (_currentStep < 6) currentStep++;
  }

  String? _validateCurrentStep() {
    switch (_currentStep) {
      case 0: return _validateStep1();
      case 1: return _validateStep2();
      case 2: return _validateStep3(); 
      case 3: return _validateStep4();
      case 4: return _validateStep5();
      default: return null;
    }
  }

  String? _validateStep1() {
    if (model.images.isEmpty) return "Vui lòng tải lên ít nhất 1 ảnh sản phẩm.";
    if (model.title.trim().isEmpty) return "Tiêu đề Tên sản phẩm bắt buộc phải nhập!";
    if (model.quantity <= 0) return "Số lượng món đồ sẵn có phải lớn hơn 0!";
    if (model.categoryId == null) return "Vui lòng chọn loại sản phẩm nhóm nhỏ!";
    if (model.description.trim().isEmpty) return "Mô tả chi tiết sản phẩm không được bỏ trống.";
    return null;
  }

  String? _validateStep2() {
    if (categoryAttributes.isEmpty) return null;
    for (final attr in categoryAttributes) {
      if (attr.id == 2) continue; 
      final value = model.dynamicAttributes[attr.id];
      if (value == null || value.toString().trim().isEmpty) {
        return "Trường thông tin thông số '${attr.attributeName}' bắt buộc không được bỏ trống!";
      }
    }
    return null;
  }

  String? _validateStep3() {
    if (model.depositAmount <= 0) return "Vui lòng thiết lập khoản tiền đặt cọc bảo đảm.";
    for (int i = 0; i < tierPrices.length; i++) {
      final price = tierPrices[i]["pricePerDay"] as double;
      final days = tierPrices[i]["minDays"] as int;
      if (price <= 0) {
        return "Giá thuê của mức cấu hình số ${i + 1} (Mốc $days ngày) phải lớn hơn 0đ!";
      }
    }
    return null;
  }

  String? _validateStep4() {
  if (model.location.trim().isEmpty) return "Địa chỉ kho bãi không được để trống!";
  if (model.features.isEmpty || model.features.any((f) => f.trim().isEmpty)) {
    return "Vui lòng nhập đầy đủ các nội dung đặc điểm nổi bật!";
  }
  return null;
}

  String? _validateStep5() {
    if (activePolicies.isEmpty) {
      return "Vui lòng thiết lập ít nhất 1 chính sách thuê.";
    }

    final Set<String> checkedTypes = {};
    for (var policy in activePolicies) {
      if (policy.content.trim().isEmpty) {
        return "Nội dung chi tiết của chính sách '${policy.type}' bắt buộc không được bỏ trống!";
      }

      if (policy.type == "Khác") continue; 
      
      if (checkedTypes.contains(policy.type)) {
        return "Chính sách '${policy.type}' đã tồn tại! Vui lòng không tạo trùng lặp mốc quy định này.";
      }
      checkedTypes.add(policy.type);
    }
    
    return null;
  }

  void prevStep() {
    if (_currentStep > 0) currentStep--;
  }

  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isNotEmpty) {
      model.images.addAll(pickedFiles.map((file) => file.path).toList());
      notifyListeners();
    }
  }

  void updateBasicInfo({String? title, String? desc, String? location, int? qty}) {
    if (title != null) model.title = title;
    if (desc != null) model.description = desc;
    if (location != null) model.location = location; 
    if (qty != null) model.quantity = qty;
    errorMessage = null; 
    notifyListeners(); 
  }

  Future<void> handlePublish() async {
    setLoading(true); 
    try {
      model.tierPrices = tierPrices;
      model.quantity = model.quantity > 0 ? model.quantity : 1;
      final success = await ApiService.submitProduct(
        product: model, 
        imageFiles: selectedFiles, 
      );

      if (success) {
        currentStep = 7; 
      } else {
        errorMessage = "Đăng bài thất bại! Hệ thống kết nối API gặp sự cố kỹ thuật.";
      }
    } catch (e) {
      errorMessage = "Lỗi kết nối đồng bộ Backend: ${e.toString()}";
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  
  void addFeatureField() {
    if (model.features.length < 8) { 
      model.features.add("");
      notifyListeners();
    }
  }

  void removeFeatureField(int index) {
    if (index >= 0 && index < model.features.length) {
      model.features.removeAt(index);
      notifyListeners();
    }
  }


  void updateFeatureValue(int index, String value) {
    if (index >= 0 && index < model.features.length) {
      model.features[index] = value;
      errorMessage = null; 
      notifyListeners();
    }
  }

  List<PolicyModel> activePolicies = [];


  void addNewPolicyField() {
    activePolicies.add(PolicyModel(type: "Khác", content: "")); 
    notifyListeners();
  }

  void removePolicyField(int index) {
    if (index >= 0 && index < activePolicies.length) {
      activePolicies.removeAt(index);
      notifyListeners();
    }
  }
  void updatePolicyType(int index, String newType) {
    if (index >= 0 && index < activePolicies.length) {
      String currentContent = activePolicies[index].content;
      activePolicies[index] = PolicyModel(type: newType, content: currentContent);
      notifyListeners(); 
    }
  }
  void updatePolicyContent(int index, String newContent) {
    if (index >= 0 && index < activePolicies.length) {
      String currentType = activePolicies[index].type;
      activePolicies[index] = PolicyModel(type: currentType, content: newContent);
      errorMessage = null;
      notifyListeners(); 
    }
  }
  void setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }
}