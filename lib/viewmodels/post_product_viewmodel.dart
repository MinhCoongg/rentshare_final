import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/models/attribute_model.dart';
import 'package:rentshare_app/models/category_model.dart';
import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/services/address_services.dart';
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

  List<AddressModel> userAddressBook = []; 
  bool isLoadingAddress = false;           
  String? addressErrorMessage;     
  String selectedCategoryName = "Chưa phân loại";

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
    model.categoryId = null; 
    model.dynamicAttributes.clear(); 
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
    if (model.depositAmount <= 0) {
      return "Vui lòng thiết lập khoản tiền đặt cọc bảo đảm lớn hơn 0đ.";
    }
    if (tierPrices.isEmpty) {
      return "Vui lòng cấu hình ít nhất một mốc giá thuê.";
    }
    int previousDays = 0;
    double previousPrice = double.infinity; 
    for (int i = 0; i < tierPrices.length; i++) {
      final int days = int.tryParse(tierPrices[i]["minDays"].toString()) ?? 0;
      final double price = double.tryParse(tierPrices[i]["pricePerDay"].toString()) ?? 0.0;
      if (days < 1) {
        return "Mốc số ${i + 1}: Số ngày thuê tối thiểu phải là số nguyên và lớn hơn hoặc bằng 1 ngày!";
      }
      if (price <= 0) {
        return "Mốc số ${i + 1} ($days ngày): Giá thuê theo ngày bắt buộc phải lớn hơn 0đ!";
      }
      if (days <= previousDays) {
        return "Lỗi cấu hình mốc số ${i + 1}: Số ngày ($days ngày) phải lớn hơn số ngày của mốc trước đó ($previousDays ngày)!";
      }
      if (price > previousPrice) {
        return "Lỗi cấu hình mốc số ${i + 1}: Giá thuê ($price đ) không được lớn hơn giá thuê của mốc trước đó ($previousPrice đ) để đảm bảo logic thuê càng lâu càng rẻ!";
      }
      previousDays = days;
      previousPrice = price;
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
    final treHan = activePolicies.firstWhere((p) => p.type == "Trễ hạn");
    if (treHan.fineValue <= 0) {
      return "Vui lòng thiết lập mức phí cho chính sách Trễ hạn!";
    }

    final huHong = activePolicies.firstWhere((p) => p.type == "Hư hỏng");
    if (huHong.unit == "PERCENT") {
      if ((huHong.lightDamage ?? 0) <= 0 || 
          (huHong.mediumDamage ?? 0) <= 0 || 
          (huHong.heavyDamage ?? 0) <= 0) {
        return "Vui lòng kiểm tra lại các mức bồi thường hư hỏng!";
      }
    }
    
    return null; 
  }

  void prevStep() {
    if (_currentStep > 0) currentStep--;
  }

  bool _isPicking = false; 
  Future<void> pickImages() async {
    if (_isPicking) return; 

    _isPicking = true; 

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      
      if (pickedFiles.isNotEmpty) {
        model.images.addAll(pickedFiles.map((file) => file.path).toList());
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Lỗi chọn nhiều ảnh: $e");
    } finally {
      _isPicking = false; 
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
      model.policies = activePolicies;
      model.quantity = model.quantity > 0 ? model.quantity : 1;
      
      final success = await ApiService.submitProduct(
        product: model, 
        imageFiles: selectedFiles, 
      );

      if (success) {
        currentStep = 6; 
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


  double lightValue = 20.0;
  double mediumValue = 50.0;
  double heavyValue = 100.0;
  List<PolicyModel> activePolicies = [
    PolicyModel(type: "Trễ hạn"),
    PolicyModel(type: "Hư hỏng"),
    PolicyModel(type: "Hủy đơn"),
    PolicyModel(type: "Mất sản phẩm"),
  ];

  void updatePolicyFineValue(int index, double newValue) {
    if (activePolicies[index].type == "Hủy đơn" || activePolicies[index].type == "Mất sản phẩm") return;
    activePolicies[index].fineValue = newValue;
    notifyListeners();
  }

  void updatePolicyUnit(int index, String newUnit) {
    activePolicies[index].unit = newUnit;
    notifyListeners();
  }

  void updateDamageValues(double l, double m, double h) {
    debugPrint("UPDATE DAMAGE");
    debugPrint("$l - $m - $h");

    lightValue = l;
    mediumValue = m;
    heavyValue = h;

    final policy = activePolicies.firstWhere((p) => p.type == "Hư hỏng");
    policy.lightDamage = l;
    policy.mediumDamage = m;
    policy.heavyDamage = h;
    notifyListeners();
  }

  

  void setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }


         

  Future<void> loadUserAddressBook() async {
    isLoadingAddress = true;
    addressErrorMessage = null;
    notifyListeners(); 

    try {
     
      final List<AddressModel> addresses = await AddressService.fetchUserAddresses();
      userAddressBook = addresses;
      if (userAddressBook.isNotEmpty && (model.addressId == 0 || model.addressId == null)) {
        final defaultAddress = userAddressBook.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => userAddressBook.first, 
        );
        model.addressId = defaultAddress.id ?? 0;
        model.location = defaultAddress.fullAddress;
      }
    } catch (error) {
      addressErrorMessage = error.toString().replaceAll("Exception: ", "");
      debugPrint("Lỗi load sổ địa chỉ trong ViewModel: $error");
    } finally {
      isLoadingAddress = false;
      notifyListeners(); 
    }
  }


  void selectAddressFromBook(int addressId, String fullAddr) {
    model.addressId = addressId; 
    model.location = fullAddr;   
    notifyListeners();           
  }

  Future<bool> addNewAddressToBook({
    required String name,
    required String phone,
    required String address,
    required bool isDefault
  }) async {
    isLoadingAddress = true;
    addressErrorMessage = null;
    notifyListeners();

    try {
      AddressModel newAddrData = AddressModel(
        receiverName: name,
        receiverPhone: phone,
        fullAddress: address,
        isDefault: isDefault, 
      );

   
      AddressModel createdAddress = await AddressService.createNewAddress(newAddrData);
      if (isDefault) {
        userAddressBook = userAddressBook.map((addr) {
          return AddressModel(
            id: addr.id,
            receiverName: addr.receiverName,
            receiverPhone: addr.receiverPhone,
            fullAddress: addr.fullAddress,
            isDefault: false,
          );
        }).toList();
      }
      userAddressBook.add(createdAddress);
    
      model.addressId = createdAddress.id ?? 0;
      model.location = createdAddress.fullAddress;
      
      return true;
    } catch (error) {
      addressErrorMessage = error.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      isLoadingAddress = false;
      notifyListeners();
    }
  }

  String get categoryName {
    if (model.categoryId == null || categoriesTreeData.isEmpty) {
      return "Chưa phân loại";
    }

    try {
      for (var mainCat in categoriesTreeData) {
        for (var sub in mainCat.subCategories) {
          if (sub.id == model.categoryId) {
            return "${mainCat.categoryName} - ${sub.categoryName}"; 
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi phân rã dịch danh mục: $e");
    }

    return "Danh mục (#${model.categoryId})";
  }

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

  
}