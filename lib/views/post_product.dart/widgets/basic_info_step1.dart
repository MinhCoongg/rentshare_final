import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rentshare_app/models/category_model.dart';
import 'package:rentshare_app/models/subcategory_model.dart'; 
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/common_widget.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/product_criteria.dart';

class Step1BasicInfo extends StatefulWidget {
  final PostProductViewModel vm;
  const Step1BasicInfo({super.key, required this.vm});

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  int _descLength = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.vm.categoriesTreeData.isEmpty) {
      widget.vm.fetchCategories();
    }
    _descLength = widget.vm.model.description.length;
    _quantity = widget.vm.model.quantity > 0 ? widget.vm.model.quantity : 1;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    CategoryModel? currentMainCategory;
    if (vm.selectedMainCategoryId != null) {
      try {
        currentMainCategory = vm.categoriesTreeData.firstWhere(
          (e) => e.id == vm.selectedMainCategoryId,
        );
      } catch (_) {
        currentMainCategory = null;
      }
    }



    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: [
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text("Ảnh sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _buildImagePicker(vm), 
              const SizedBox(height: 24),
              CustomTextField(
                key: const ValueKey("title_field"),
                label: "Tên sản phẩm *", 
                hint: "Ví dụ: Máy ảnh Canon EOS R5", 
                initialValue: vm.model.title, 
                onChanged: (v) => vm.updateBasicInfo(title: v)
              ),
              const SizedBox(height: 20),

             
              const Row(
                children: [
                  Text("Số lượng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                   Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              _buildQuantityStepper(vm),
              const SizedBox(height: 24),

              const Text("Danh mục (nhóm lớn) *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: vm.selectedMainCategoryId, 
                decoration: InputDecoration(
                  filled: true, 
                  fillColor: Colors.grey[50], 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5)),
                ),
                items: vm.categoriesTreeData.map<DropdownMenuItem<int>>((CategoryModel mainCat) {
                  return DropdownMenuItem<int>(
                    value: mainCat.id, 
                    child: Text(mainCat.categoryName),
                  );
                }).toList(),
                hint: const Text("Chọn nhóm ngành hàng lớn"),
                onChanged: (int? newValue) => vm.selectMainCategoryId(newValue),
              ),
              const SizedBox(height: 20),

              const Text("Loại sản phẩm (nhóm nhỏ) *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: vm.selectedSubCategoryId, 
                disabledHint: const Text("Vui lòng chọn nhóm lớn trước"),
                decoration: InputDecoration(
                  filled: true, 
                  fillColor: currentMainCategory == null ? Colors.grey[100] : Colors.grey[50], 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5)),
                ),
                items: currentMainCategory?.subCategories.map<DropdownMenuItem<int>>((SubCategoryModel subCat) {
                        return DropdownMenuItem<int>(
                          value: subCat.id, 
                          child: Row(
                            children: [
                              const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(subCat.categoryName), 
                            ],
                          ),
                        );
                      }).toList(),
                hint: const Text("Chọn loại sản phẩm"),
                onChanged: currentMainCategory == null 
                    ? null 
                    : (int? newValue) => vm.selectSubCategoryId(newValue), 
              ),
              const SizedBox(height: 24),
              
      
              CustomTextField(
                key: const ValueKey("desc_field"),
                label: "Mô tả sản phẩm *", 
                hint: "Mô tả chi tiết về sản phẩm, tình trạng, công dụng...", 
                initialValue: vm.model.description, 
                maxLines: 5, 
                onChanged: (v) {
                  setState(() {
                    _descLength = v.length;
                  });
                  vm.updateBasicInfo(desc: v);
                }
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "$_descLength/1000",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),

              GestureDetector(
                onTap: () => showDialog(context: context, builder: (_) => CriteriaPopup()),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    SizedBox(width: 5),
                    Text("Xem tiêu chí kiểm duyệt sản phẩm", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildImagePicker(PostProductViewModel vm) {
    return GridView.count(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(), 
      crossAxisCount: 3, 
      crossAxisSpacing: 10, 
      mainAxisSpacing: 10,
      children: [
        GestureDetector(
          onTap: () => vm.pickImages(), 
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFFF1F8FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD0E7FF))), 
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Icon(Icons.add_a_photo_outlined, color: Color(0xFF1976D2), size: 24), 
                SizedBox(height: 6),
                Text("Thêm ảnh", style: TextStyle(color: Color(0xFF1976D2), fontSize: 12, fontWeight: FontWeight.bold)) 
              ],
            ),
          ),
        ),
        ...vm.model.images.map((path) => Stack( 
          children: [
            Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(path), fit: BoxFit.cover))), 
            Positioned(
              right: 4, top: 4,
              child: GestureDetector(
                onTap: () => setState(() => vm.model.images.remove(path)), 
                child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)), 
              ),
            )
          ],
        )),
      ],
    );
  }


  Widget _buildQuantityStepper(PostProductViewModel vm) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!), 
            borderRadius: BorderRadius.circular(8), 
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18, color: Colors.black54), 
                onPressed: _quantity > 1 ? () { 
                  setState(() {
                    _quantity--; 
                    vm.updateProductQuantity(_quantity); 
                  });
                } : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16), 
                child: Text("$_quantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18, color: Colors.black54), 
                onPressed: () {
                  setState(() {
                    _quantity++; 
                    vm.updateProductQuantity(_quantity); 
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12), 
        Text("món", style: TextStyle(color: Colors.grey[600], fontSize: 14)), 
      ],
    );
  }
}