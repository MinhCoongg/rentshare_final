import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/auth_viewmodel.dart';
import 'package:rentshare_app/views/changePassword/passwordupdate.dart'; 

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  String userAddress = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        setState(() {
          userName = auth.user!.name;
          userEmail = auth.user!.email;
          userPhone = auth.user!.phoneNumber ?? "";
          userAddress = auth.user!.address ?? "";
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thông tin cá nhân", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user.avatar),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        _buildInputField(
                        label: "Tên",
                        value: userName,
                        icon: Icons.person_outline,
                        onTap: () {
                          _showEditModal(
                            title: "Tên",
                            currentValue: userName,
                            onSave: (value) {
                              setState(() {
                                userName = value;
                              });
                            },
                          );
                        },
                      ),
                        const Divider(),
                       _buildInputField(
                        label: "Email",
                        value: userEmail,
                        icon: Icons.email_outlined,
                        onTap: () {
                          _showEditModal(
                            title: "Email",
                            currentValue: userEmail,
                            keyboardType: TextInputType.emailAddress,
                            onSave: (value) {
                              setState(() {
                                userEmail = value;
                              });
                            },
                          );
                        },
                      ),
                        const Divider(),
                        _buildInputField(
                        label: "Số điện thoại",
                        value: userPhone.isEmpty
                            ? "Chưa cập nhật"
                            : userPhone,
                        icon: Icons.phone_android_outlined,
                        onTap: () {
                          _showEditModal(
                            title: "Số điện thoại",
                            currentValue: userPhone,
                            keyboardType: TextInputType.phone,
                            onSave: (value) {
                              setState(() {
                                userPhone = value;
                              });
                            },
                          );
                        },
                      ),
                      const Divider(),
                      _buildChangePasswordTile(),
                      const Divider()
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                     onPressed: () async {
                      final auth = context.read<AuthProvider>();
                      final updatedUser = auth.user!.copyWith(
                        name: userName,
                        email: userEmail,
                        phoneNumber: userPhone,
                      );
                      try {
                        await auth.updateProfile(updatedUser);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cập nhật thành công"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }

                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }

                      }
                    },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4DD0B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("CẬP NHẬT THÔNG TIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader(String avatarUrl) {
    return Center(
      child: InkWell(
        onTap: _pickerImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4DD0B0),
                  width: 3,
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    avatarUrl.isNotEmpty
                        ? 'http://192.168.1.17:3001$avatarUrl'
                        : 'http://192.168.1.17:3001/uploads/rentshare.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Color(0xFF4DD0B0),
                radius: 18,
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit),
      onTap: onTap,
    );
  }

  Future<void> _pickerImage() async {
    final XFile? pickerFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickerFile != null) {
      try {
        await context.read<AuthProvider>().uploadAvatar(File(pickerFile.path));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã cập nhật ảnh!")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }


  void _showEditModal({
    required String title,
    required String currentValue,
    required Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: currentValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                "Sửa $title",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                keyboardType: keyboardType,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Nhập $title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onSave(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Lưu"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildChangePasswordTile() {
    return ListTile(
      leading: const Icon(Icons.lock_outline),
      title: const Text(
        "Đổi mật khẩu",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text(
        "Thay đổi mật khẩu để bảo vệ tài khoản",
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ChangePasswordProfile(),
          ),
        );
      },
    );
  }
}