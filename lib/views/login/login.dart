import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/login_viewmodel.dart';
import 'package:rentshare_app/views/login/widget_login/bottomConner.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xffF4FBF7), 
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.42,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Color(0xffE2F5EC),
                    ),
                    child: Image.asset(
                      'assets/images/rentshare.jpg', 
                      fit: BoxFit.cover,
                    ),
                  ),

                  ClipPath(
                    clipper: BottomSheetClipper(), 
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 45, bottom: 30),
                      decoration: const BoxDecoration(
                        color: Colors.white, 
                      ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đăng nhập',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Chào mừng bạn quay trở lại!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),

                          // Ô NHẬP EMAIL
                          TextFormField(
                            onChanged: viewModel.updateEmail,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập Email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Email không đúng định dạng';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Email hoặc số điện thoại',
                              prefixIcon: const Icon(Icons.person_outline, color: Color(0xff1B8A4B)),
                              filled: true,
                              fillColor: const Color(0xffF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE9ECEF)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE9ECEF)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Ô NHẬP MẬT KHẨU
                          TextFormField(
                            obscureText: viewModel.isPasswordObscured,
                            onChanged: viewModel.updatePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu phải dài từ 6 ký tự trở lên';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock_open_outlined, color: Color(0xff1B8A4B)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  viewModel.isPasswordObscured 
                                      ? Icons.visibility_off_outlined 
                                      : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: viewModel.togglePasswordVisibility,
                              ),
                              filled: true,
                              fillColor: const Color(0xffF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE9ECEF)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE9ECEF)),
                              ),
                            ),
                          ),
                          
                          // QUÊN MẬT KHẨU
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Quên mật khẩu?',
                                style: TextStyle(color: Color(0xff1B8A4B), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🚀 NÚT ĐĂNG NHẬP XANH LÁ (KẾT NỐI API VỚI PHÁT BACKEND)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1B8A4B),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        String? errorMessage = await viewModel.loginWithApi();
                                        if (context.mounted) {
                                          if (errorMessage == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Đăng nhập thành công!'),
                                                backgroundColor: Color(0xff1B8A4B),
                                              ),
                                            );
                                            
                                            // Huy dùng Navigator điều hướng sang màn hình HomePage chính thức tại đây nha:
                                            // Navigator.pushReplacementNamed(context, '/home');
                                            
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(' $errorMessage'),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Text(
                                      'Đăng nhập',
                                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: Color(0xffE9ECEF))),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Hoặc đăng nhập với', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ),
                              Expanded(child: Divider(color: Color(0xffE9ECEF))),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    //height: 48,
                                    side: const BorderSide(color: Color(0xffE9ECEF)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 30),
                                  label: const Text('Google', style: TextStyle(color: Colors.black)),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    //height: 48,
                                    side: const BorderSide(color: Color(0xffE9ECEF)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.facebook, color: Colors.blue),
                                  label: const Text('Facebook', style: TextStyle(color: Colors.black)),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Chưa có tài khoản? ', style: TextStyle(color: Colors.grey)),
                              GestureDetector(
                                onTap: () {}, // Nối sang trang Đăng Ký tiếp theo
                                child: const Text(
                                  'Đăng ký ngay',
                                  style: TextStyle(color: Color(0xff1B8A4B), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}