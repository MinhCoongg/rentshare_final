import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/home_viewmodel.dart';
import 'package:rentshare_app/viewmodels/productFilter.dart';
import 'package:rentshare_app/views/filterProduct/widget/priceFilter.dart';
import 'package:rentshare_app/views/product_detail.dart/product_detail_screen.dart';
class ProductListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String? keyword; 

  const ProductListScreen({
    super.key, 
    required this.categoryId, 
    required this.categoryName,
    this.keyword
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late TextEditingController _searchController;
  late String _currentTitle;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.keyword ?? "");
    _currentTitle = widget.categoryName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductListViewModel>().loadProducts(
        categoryId: widget.categoryId != 0 ? widget.categoryId : null,
        keyword: widget.keyword,
        clearFilters: true
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_currentTitle ,style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (value) {
                final vm = context.read<ProductListViewModel>();
                final trimmedValue = value.trim();
                vm.resetFilters();
                vm.loadProducts(
                  keyword: trimmedValue.isNotEmpty ? trimmedValue : null,
                  categoryId: trimmedValue.isNotEmpty ? null : (widget.categoryId != 0 ? widget.categoryId : null),
                );
                _updateTitle(trimmedValue.isNotEmpty ? "Kết quả: $trimmedValue" : null);
              },
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterTag("Sắp xếp", Icons.sort, () => _showSortOptions()),
                      _buildFilterTag("Giá", Icons.attach_money, () => _showPriceFilter()),
                      _buildFilterTag("Danh mục", Icons.category_outlined, () => _showCategoryFilter()),
                      _buildFilterTag("Khu vực", Icons.location_on_outlined, () => _showLocationFilter()),
                    ],
                  ),
                ),
          ),
          
          // 3. Đếm sản phẩm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer<ProductListViewModel>(
              builder: (context, vm, _) => Align(
                alignment: Alignment.centerLeft, 
                child: Text("${vm.products.length} sản phẩm", style: const TextStyle(color: Colors.grey))
              ),
            ),
          ),

          // 4. Danh sách
          Expanded(
            child: Consumer<ProductListViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) return const Center(child: CircularProgressIndicator());
                if (vm.products.isEmpty) return const Center(child: Text("Không có sản phẩm nào"));
                
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vm.products.length,
                  itemBuilder: (context, index) => _buildProductCard(vm.products[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProductCard(ProductHomeModel item) { 
    return GestureDetector(
      onTap: (){
         Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(productId: item.id)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.images, 
                width: 110, height: 110, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], width: 110, height: 110),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text("${item.rating} (${item.reviewCount})", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ]),
                      
                      const SizedBox(height: 10),
                      
                      Text("${FormatUtils.formatMoney(item.minPrice)}đ / ngày", 
                          style: const TextStyle(color: Color(0xFF5A31F4), fontWeight: FontWeight.bold, fontSize: 14)),
                      
                      const SizedBox(height: 6),
      
                      Row(children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(item.location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ]),
                    ],
                  ),
                  // Nút Favorite
                  Positioned(top: -8, right: -4, child: IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, size: 20))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildFilterTag(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return PriceRangeFilter(
          min: 0, max: 500000,
          onApply: (min, max) {
            context.read<ProductListViewModel>().loadProducts(
              categoryId: widget.categoryId, 
              priceMin: min, 
              priceMax: max
            );
            Navigator.pop(context);
          },
        );
      },
    );
  }

   void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Consumer<ProductListViewModel>(
          builder: (context, vm, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Sắp xếp theo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _buildSortOption("Mới nhất", "newest", vm),
                _buildSortOption("Giá thấp đến cao", "price_asc", vm),
                _buildSortOption("Giá cao xuống thấp", "price_desc", vm),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value, ProductListViewModel vm) {
    bool isSelected = (vm.currentSortBy ?? "newest") == value; 
    return ListTile(
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected ? const Color(0xFF0056D2) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        )
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF0056D2)) : null,
      onTap: () {
        _applySort(value); 
      },
    );
  }

  void _applySort(String sortBy) {
    context.read<ProductListViewModel>().loadProducts(categoryId: widget.categoryId, sortBy: sortBy);
    Navigator.pop(context);
  }
  void _showLocationFilter() {
    final List<String> locations = ["TP. Hồ Chí Minh", "Hà Nội", "Đà Nẵng", "Cần Thơ", "Hải Phòng", "Tây Ninh", "Tiền Giang"];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text("Chọn khu vực", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: locations.map((loc) {

                  final isSelected = (context.watch<ProductListViewModel>().currentLocation == loc);
                  
                  return ChoiceChip(
                    label: Text(loc),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0056D2).withOpacity(0.1),
                    checkmarkColor: const Color(0xFF0056D2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF0056D2) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      final vm = context.read<ProductListViewModel>();
                      vm.resetFilters(); 
                      vm.loadProducts(
                        categoryId: widget.categoryId != 0 ? widget.categoryId : null,
                        location: loc,
                      );
                      _updateTitle(widget.categoryName);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

    void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final homeVm = Provider.of<HomeViewModel>(context);
        final currentCategory = homeVm.categories.firstWhere(
          (cat) => cat.id == widget.categoryId, 
          orElse: () => homeVm.categories.first
        );

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text("Chọn danh mục con", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: currentCategory.subCategories.map((sub) {
                      final isSelected = context.watch<ProductListViewModel>().selectedCategoryId == sub.id;
                      
                      return ChoiceChip(
                        label: Text(sub.categoryName),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0056D2).withOpacity(0.1),
                        checkmarkColor: const Color(0xFF0056D2),
                        showCheckmark: true, 
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF0056D2) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          final vm = context.read<ProductListViewModel>();
                          vm.loadProducts(categoryId: sub.id, clearFilters: true);
                          _updateTitle(sub.categoryName);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateTitle(String? newTitle) {
    setState(() {
      _currentTitle = newTitle ?? widget.categoryName;
    });
  }
}