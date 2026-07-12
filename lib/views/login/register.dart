import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/login_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isAccepted = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Đăng ký tài khoản", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B8A4B))),
              const Text("Tạo tài khoản để bắt đầu với RentShare", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              // Form Input
              _buildTextField(_nameController, "Họ và tên", Icons.person_outline),
              _buildTextField(_emailController, "Email", Icons.email_outlined),
              _buildTextField(_phoneController, "Số điện thoại", Icons.phone_outlined),
              _buildTextField(_passController, "Mật khẩu", Icons.lock_outline, isPass: true),
              _buildTextField(_confirmPassController, "Xác nhận mật khẩu", Icons.lock_outline, isPass: true, isConfirm: true,),

              Row(
                children: [
                  Checkbox(value: _isAccepted, onChanged: (v) => setState(() => _isAccepted = v!)),
                  const Text("Tôi đồng ý với Điều khoản sử dụng"),
                ],
              ),

              const SizedBox(height: 20),
              
              Consumer<LoginViewModel>(
                builder: (context, vm, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B8A4B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: vm.isLoading ? null : () async {
                        if (_formKey.currentState!.validate() && _isAccepted) {
                          bool success = await vm.register(
                            name: _nameController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            password: _passController.text,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!"),backgroundColor: Color(0xff1B8A4B)));
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage ?? "Lỗi"), backgroundColor: Colors.redAccent));
                          }
                        }
                      },
                      child: vm.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Đăng ký", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPass = false, bool isConfirm = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPass ? (isConfirm ? !_isConfirmPasswordVisible : !_isPasswordVisible) : false,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: const Color(0xFF1B8A4B)),
          hintText: hint,
          suffixIcon: isPass ? IconButton(
          icon: Icon(
            (isConfirm ? _isConfirmPasswordVisible : _isPasswordVisible) 
                ? Icons.visibility 
                : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () => setState(() {
            if (isConfirm) {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            } else {
              _isPasswordVisible = !_isPasswordVisible;
            }
          }),
        ) : null,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1B8A4B), width: 2)),
        ),
        validator: (val) {
        if (val == null || val.isEmpty) return "Không được để trống";
        if (hint == "Email") {
          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(val)) return "Email không hợp lệ (ví dụ: abc@gmail.com)";
        }

        if (hint == "Số điện thoại") {
          final phoneRegex = RegExp(r'^0[0-9]{9,10}$');
          if (!phoneRegex.hasMatch(val)) return "SĐT phải bắt đầu bằng số 0 và có 10-11 số";
        }

        if (isConfirm && val != _passController.text) return "Mật khẩu không khớp";
        
        return null;
      },
      ),
    );
  }
}