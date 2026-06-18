import 'package:flutter/material.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/services/address_services.dart';

class AddressViewModel extends ChangeNotifier {
  List<AddressModel> _userAddressBook = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get userAddressBook => _userAddressBook;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  Future<void> loadUserAddressBook() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userAddressBook = await AddressService.fetchUserAddresses();
    } catch (error) {
      _errorMessage = error.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AddressModel?> addNewAddress({
    required String name,
    required String phone,
    required String address,
    required bool isDefault,
  }) async {
    _isLoading = true;
    _errorMessage = null;
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
        _userAddressBook = _userAddressBook.map((addr) {
          return AddressModel(
            id: addr.id,
            receiverName: addr.receiverName,
            receiverPhone: addr.receiverPhone,
            fullAddress: addr.fullAddress,
            isDefault: false, 
          );
        }).toList();
      }
      _userAddressBook.add(createdAddress);
      return createdAddress;
    } catch (error) {
      _errorMessage = error.toString().replaceAll("Exception: ", "");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}