import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/auth_viewmodel.dart';

class ChangePasswordProfile extends StatefulWidget {
  const ChangePasswordProfile({super.key});

  @override
  State<ChangePasswordProfile> createState() => _ChangePasswordProfileState();
}

class _ChangePasswordProfileState extends State<ChangePasswordProfile> {
  static const bgColor = Colors.white;
  static const primaryColor = Color(0xFF4DD0B0);

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;


  bool get hasMinLength => _newPassController.text.length >= 8;

  bool get hasUpperLowerNumber {
    final pass = _newPassController.text;
    bool hasUpper = pass.contains(RegExp(r'[A-Z]'));
    bool hasLower = pass.contains(RegExp(r'[a-z]'));
    bool hasNumber = pass.contains(RegExp(r'[0-9]'));
    return hasUpper && hasLower && hasNumber;
  }

  bool get hasSpecialChar => 
      _newPassController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Thay đổi mật khẩu', 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: bgColor,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mật khẩu mới của bạn phải khác với mật khẩu đã sử dụng trước đó.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),

            _buildPasswordField(
              controller: _oldPassController,
              label: "Mật khẩu hiện tại",
              isObscure: _isObscureOld,
              onToggle: () => setState(() => _isObscureOld = !_isObscureOld),
            ),
            const SizedBox(height: 15),

            _buildPasswordField(
              controller: _newPassController,
              label: "Mật khẩu mới",
              isObscure: _isObscureNew,
              onToggle: () => setState(() => _isObscureNew = !_isObscureNew),
              onChanged: (val) => setState(() {}), // Cập nhật dấu tích xanh khi gõ
            ),
            const SizedBox(height: 15),

  
            _buildPasswordField(
              controller: _confirmPassController,
              label: "Xác nhận mật khẩu mới",
              isObscure: _isObscureConfirm,
              onToggle: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
            ),

            const SizedBox(height: 25),
            
            _buildRequirementRow("Mật khẩu cần có ít nhất 8 ký tự.", hasMinLength),
            _buildRequirementRow("Bao gồm chữ hoa, thường và số.", hasUpperLowerNumber),
            _buildRequirementRow("Có ít nhất 1 ký tự đặc biệt.", hasSpecialChar),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                onPressed: _handleSubmit,
                child: const Text("LƯU MẬT KHẨU MỚI", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.check_circle_outline,
            size: 20,
            color: isMet ? primaryColor : Colors.grey[300],
          ),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: isMet ? Colors.black : Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: primaryColor),
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showLoi("Vui lòng điền đầy đủ tất cả các trường!");
      return;
    }

    if (newPass != confirmPass) {
      _showLoi("Xác nhận mật khẩu mới không khớp!");
      return;
    }

    if (oldPass == newPass) {
      _showLoi("Mật khẩu mới không được trùng mật khẩu cũ!");
      return;
    }

    if (!hasMinLength || !hasUpperLowerNumber || !hasSpecialChar) {
      _showLoi("Mật khẩu mới chưa đạt yêu cầu bảo mật!");
      return;
    }

    try{
      final auth = context.read<AuthProvider>();
      bool success = await auth.changePassword(
        oldPassword: oldPass,
        newPassword: newPass,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Chúc mừng! Bạn đã đổi mật khẩu thành công."),
            backgroundColor: Colors.green,
          ),
        );
      }else{
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thay đổi mật khẩu thất bại."),
            backgroundColor: Colors.red,
          ),
        );
      }

    }catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        _showLoi(e.toString().replaceAll("Exception: ", ""));
    }
  }
  

  void _showLoi(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}