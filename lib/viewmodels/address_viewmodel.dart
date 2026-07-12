import 'package:flutter/material.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/services/address_services.dart';

class AddressSelectionViewModel extends ChangeNotifier {
  List<AddressModel> addresses = [];
  AddressModel? selectedAddress;
  bool isLoading = false;

  Future<void> loadAddresses() async {
    isLoading = true;
    notifyListeners();
    try {
      addresses = await AddressService.fetchUserAddresses();
      
      if (addresses.isNotEmpty && selectedAddress == null) {
        selectedAddress = addresses.firstWhere(
          (addr) => addr.isDefault == true,
          orElse: () => addresses.first,    
        );
      }
    } catch (e) {
      debugPrint("Lỗi load địa chỉ: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectAddress(AddressModel addr) {
    selectedAddress = addr;
    notifyListeners();
  }

  Future<bool> addNewAddress({
    required String name,
    required String phone,
    required String address,
    required bool isDefault
  }) async {
    isLoading = true;
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
        addresses = addresses.map((addr) {
          return addr.copyWith(isDefault: false);
        }).toList();
      }

      addresses.add(createdAddress);
      selectedAddress = createdAddress;
      
      return true;
    } catch (error) {
      debugPrint("Lỗi thêm địa chỉ: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(AddressModel updatedAddr) async {
    isLoading = true;
    notifyListeners();
    try {
      bool success = await AddressService.updateAddress(updatedAddr);
      if (success) {
        int index = addresses.indexWhere((a) => a.id == updatedAddr.id);
        if (index != -1) {
          addresses[index] = updatedAddr;
          if (updatedAddr.isDefault) {
            addresses = addresses.map((a) => 
              a.id == updatedAddr.id ? a : a.copyWith(isDefault: false)
            ).toList();
          }
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi cập nhật địa chỉ: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      bool success = await AddressService.deleteAddress(id);
      if (success) {
        addresses.removeWhere((a) => a.id == id);
        if (selectedAddress?.id == id) {
          selectedAddress = addresses.isNotEmpty ? addresses.first : null;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi xóa địa chỉ: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}