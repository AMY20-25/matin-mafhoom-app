import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:matin_mafhoom/api/api_service.dart';
import 'package:matin_mafhoom/models/user_model.dart';
import 'package:matin_mafhoom/models/referral_model.dart';

const Color profilePageBg = Color(0xFF6d60f8);
const Color profileItemBg = Color(0xFFf1effe);
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
  DateTime? _selectedDate;
  
  bool _isLoading = false;
  Future<List<dynamic>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchInitialData();
  }

  Future<List<dynamic>> _fetchInitialData() async {
    // Fetch user profile and referral info in parallel
    final results = await Future.wait([
      ApiService().getMyProfile(),
      ApiService().getMyReferralInfo(),
    ]);
    final user = User.fromJson(results[0]);
    final referral = Referral.fromJson(results[1]);

    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _selectedDate = user.birthDate;

    return [user, referral];
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await ApiService().updateMyProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      birthDate: _selectedDate,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "پروفایل با موفقیت به‌روز شد." : "خطا در به‌روزرسانی.")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() { _selectedDate = picked; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: profilePageBg,
      appBar: AppBar(title: const Text("پروفایل من"), backgroundColor: Colors.transparent, elevation: 0),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("خطا در دریافت اطلاعات", style: TextStyle(color: Colors.white)));
          }
          final User user = snapshot.data![0];
          final Referral referral = snapshot.data![1];
          return RefreshIndicator(
            onRefresh: () async {
              setState(() { _dataFuture = _fetchInitialData(); });
            },
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 30),
                _buildProfileForm(context),
                const SizedBox(height: 20),
                _buildReferralCard(context, referral),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    final birthDateText = _selectedDate == null ? 'انتخاب کنید' : DateFormat('yyyy/MM/dd').format(_selectedDate!);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: profileItemBg, borderRadius: BorderRadius.circular(16)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: "نام")),
            const SizedBox(height: 16),
            TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: "نام خانوادگی")),
            const SizedBox(height: 24),
            const Text("تاریخ تولد", style: TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text(birthDateText, style: const TextStyle(fontSize: 16, color: profilePageBg)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading ? const CircularProgressIndicator() : const Text("ذخیره تغییرات"),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReferralCard(BuildContext context, Referral referral) {
    return Card(
      color: profileItemBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("کد معرف شما", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: profilePageBg)),
            const SizedBox(height: 10),
            SelectableText(
              referral.referralCode,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Text("تعداد دعوت‌های موفق: ${referral.invitedCount}"),
            IconButton(
              icon: const Icon(Icons.copy, color: profilePageBg),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: referral.referralCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("کد معرف کپی شد!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) { /* Same as before */ 
    return Column(
      children: [
        const CircleAvatar(radius: 50, backgroundColor: profileItemBg, child: Icon(Icons.person, size: 60, color: profilePageBg)),
        const SizedBox(height: 16),
        Text(user.phoneNumber, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

