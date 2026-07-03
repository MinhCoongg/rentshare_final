import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/basic_info_step1.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/location_info_step4.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/policies_info_step5.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/pricing_info_step3.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/product_details_step2.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/product_review_steps6.dart';


class PostProductScreen extends StatelessWidget {
  const PostProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PostProductViewModel>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: _buildAppBar(vm, context),
      body: Column(
        children: [
          if (vm.errorMessage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red))),
                ],
              ),
            ),
          
          Expanded(
            child: vm.isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _buildBody(vm, context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(vm),
    );
  }

  PreferredSizeWidget _buildAppBar(PostProductViewModel vm, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: vm.currentStep > 0 
        ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => vm.prevStep())
        : IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
      title: const Text("Đăng sản phẩm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (vm.currentStep + 1) / 7,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("${vm.currentStep + 1}. ${_getStepTitle(vm.currentStep)}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    const titles = ["Thông tin cơ bản", "Chi tiết sản phẩm", "Giá thuê", "Địa điểm", "Chính sách", "Xem trước", "Thành công"];
    if (step >= titles.length) {
    return "Hoàn thành đăng bài";
  }
    return titles[step];
  }

  Widget _buildBody(PostProductViewModel vm, BuildContext context) {
    switch (vm.currentStep) {
      case 0: 
        return Step1BasicInfo(vm: vm); 
      case 1: 
        return Step2ProductDetail(vm: vm);
      case 2: 
        return Step3PricingInfo(vm: vm); 
      case 3: 
        return Step4LocationInfo(vm: vm); 
      case 4: 
        return Step5PoliciesInfo(vm: vm); 
      case 5: 
        return ProductPreviewWidget(vm: vm); 
      case 6: 
        return  _buildStep7(context); 
      default: 
        return const SizedBox();
    }
  }

  Widget _buildBottomNav(PostProductViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2), 
          minimumSize: const Size(double.infinity, 54), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
        ),
        onPressed: vm.isLoading 
            ? null 
            : () {
                if (vm.currentStep == 5) {
                  vm.handlePublish(); 
                } else {
                  vm.nextStep(); 
                }
              },
        child: vm.isLoading 
            ? const SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : Text(
                vm.currentStep == 5 ? "Đăng sản phẩm" : "Tiếp tục", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
              ),
      ),
    );
  }

 
  Widget _buildStep7(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),

            const Text(
              "Đăng sản phẩm thành công!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            const Text(
              "Sản phẩm của bạn đang được duyệt bởi đội ngũ RentShare. Bạn sẽ nhận được thông báo khi sản phẩm được hiển thị.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            TextButton(
              onPressed: () { 
                  Navigator.pushNamedAndRemoveUntil(context, '/mainscreen', (route) => false);
               },
              child: const Text("Về trang chủ", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }


}