import 'package:flutter/material.dart';
import 'package:matin_mafhoom/api/api_service.dart';
import 'package:matin_mafhoom/models/user_model.dart';

// --- Color Palette for this screen ---
const Color profilePageBg = Color(0xFF6d60f8);
const Color profileItemBg = Color(0xFFf1effe);
const Color profileItemText = Color(0xFF333333);
const Color buttonTextColor = Color(0xFFFFFFFF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  bool _isLoading = false;
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserProfile();
  }

  Future<User?> _fetchUserProfile() async {
    final userData = await ApiService().getMyProfile();
    if (userData != null) {
      final user = User.fromJson(userData);
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      return user;
    }
    return null;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ApiService().updateMyProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "پروفایل با موفقیت به‌روز شد." : "خطا در به‌روزرسانی."),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: profilePageBg,
      appBar: AppBar(
        title: const Text("پروفایل من"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: buttonTextColor,
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("خطا در دریافت اطلاعات پروفایل", style: TextStyle(color: Colors.white)));
          }
          
          final user = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 30),
              _buildProfileForm(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: profileItemBg,
          child: Icon(Icons.person, size: 60, color: profilePageBg),
        ),
        const SizedBox(height: 16),
        Text(
          user.phoneNumber,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: profileItemBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: "نام"),
              validator: (value) => (value ?? '').isEmpty ? "نام نمی‌تواند خالی باشد" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: "نام خانوادگی"),
              validator: (value) => (value ?? '').isEmpty ? "نام خانوادگی نمی‌تواند خالی باشد" : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: profilePageBg,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ذخیره تغییرات"),
            ),
          ],
        ),
      ),
    );
  }
}

