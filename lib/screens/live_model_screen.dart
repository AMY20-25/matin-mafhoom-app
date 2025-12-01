import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async'; // اضافه برای TimeoutException
import 'package:http/http.dart' as http;

class LiveModelScreen extends StatefulWidget {
  const LiveModelScreen({super.key});

  @override
  State<LiveModelScreen> createState() => _LiveModelScreenState();
}

class _LiveModelScreenState extends State<LiveModelScreen> {
  File? _image;
  String? _processedImageBase64;
  String? _selectedStyle;

  // آدرس سرور
  static const String baseUrl = "http://192.168.1.7:8000";

  bool _loading = false; // وضعیت پردازش برای جلوگیری از دوباره زدن دکمه

  // انتخاب عکس از گالری یا دوربین
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _processedImageBase64 = null; // پاک کردن نتیجه قبلی
      });
    }
  }

  // تبدیل عکس به Base64 (حفظ می‌شود؛ در صورت نیاز می‌توان استفاده کرد)
  String _imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // فراخوانی API — ارسال فایل به صورت multipart مطابق Swagger (file: binary)
  Future<void> _applyModel() async {
    if (_image == null || _selectedStyle == null) {
      _showError("ابتدا عکس را انتخاب و یک مدل را تعیین کنید.");
      return;
    }

    setState(() => _loading = true);
    try {
      final uri = Uri.parse("$baseUrl/gallery/preview");
      final request = http.MultipartRequest("POST", uri);

      // فایل تصویر با کلید 'file' — مطابق تعریف Swagger
      request.files.add(
        await http.MultipartFile.fromPath("file", _image!.path),
      );

      // اگر بک‌اند فیلد style را قبول کند، ارسال می‌کنیم
      request.fields["style"] = _selectedStyle!;

      // ارسال با timeout
      final streamed = await request.send().timeout(const Duration(seconds: 120));
      final bytes = await streamed.stream.toBytes();
      final bodyStr = utf8.decode(bytes);

      // لاگ برای دیباگ
      print("HTTP ${streamed.statusCode} bodyStr: ${bodyStr.substring(0, bodyStr.length > 500 ? 500 : bodyStr.length)}");
      print("Response bytes length: ${bytes.length}");

      if (streamed.statusCode == 200) {
        // تلاش برای تفسیر پاسخ:
        // 1) اگر JSON باشد و فیلد processed_image یا کلیدهای مشابه داشته باشد
        // 2) اگر تصویر باینری برگردد، به Base64 تبدیل و نمایش می‌دهیم
        bool displayed = false;
        try {
          final decoded = jsonDecode(bodyStr);

          if (decoded is Map) {
            // حالت 1: تصویر Base64 در کلیدهای رایج
            final imgKeyCandidates = [
              "processed_image",
              "image",
              "data",
              "result",
              "output",
            ];
            for (final k in imgKeyCandidates) {
              if (decoded[k] is String && (decoded[k] as String).isNotEmpty) {
                setState(() {
                  _processedImageBase64 = decoded[k] as String;
                });
                displayed = true;
                break;
              }
            }

            // حالت 2: لینک یا مسیر فایل
            if (!displayed) {
              final urlKeyCandidates = ["url", "path", "file", "output_path"];
              for (final k in urlKeyCandidates) {
                if (decoded[k] is String && (decoded[k] as String).isNotEmpty) {
                  final msg = "پاسخ JSON مسیر/لینک فایل را داد: ${decoded[k]}";
                  _showError(msg);
                  displayed = true;
                  break;
                }
              }
            }

            if (!displayed) {
              final msg = decoded["message"] ?? decoded["detail"] ?? "پاسخ JSON بدون تصویر پردازش‌شده دریافت شد.";
              _showError("$msg");
            }
          } else {
            _showError("پاسخ JSON نامعتبر دریافت شد.");
          }
        } catch (_) {
          // اگر JSON نبود، احتمالاً تصویر باینری برگشته است
          setState(() {
            _processedImageBase64 = base64Encode(bytes);
          });
          displayed = true;
        }
      } else if (streamed.statusCode == 422) {
        _showError("ورودی نامعتبر (422). کلیدها و فرمت را بررسی کنید.");
      } else {
        _showError("خطای سرور: ${streamed.statusCode}");
      }
    } on TimeoutException {
      _showError("مهلت اتصال تمام شد. سرور زمان‌بر است یا پاسخ دیر می‌رسد.");
    } catch (e) {
      _showError("خطا در اتصال: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color header = Color(0xFF6D60F8); // بنفش هدر
    const Color btnColor = Color(0xFF70CFFC); // رنگ دکمه‌ها

    return Scaffold(
      appBar: AppBar(
        backgroundColor: header,
        title: const Text("مدل زنده"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // نمایش عکس انتخاب‌شده یا نتیجه پردازش
              if (_processedImageBase64 != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(_processedImageBase64!),
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                )
              else if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("لطفاً عکس خود را انتخاب کنید"),
                  ),
                ),

              const SizedBox(height: 20),

              // دکمه‌های انتخاب عکس
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                      ),
                      label: const Text("انتخاب از گالری"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                      ),
                      label: const Text("گرفتن با دوربین"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "انتخاب مدل ریش و مو",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // دکمه‌های مدل‌ها
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ModelButton(
                    label: "ریش کوتاه",
                    color: btnColor,
                    onTap: () => setState(() => _selectedStyle = "beard_short"),
                  ),
                  _ModelButton(
                    label: "ریش بلند",
                    color: btnColor,
                    onTap: () => setState(() => _selectedStyle = "beard_long"),
                  ),
                  _ModelButton(
                    label: "بدون ریش",
                    color: btnColor,
                    onTap: () => setState(() => _selectedStyle = "beard_none"),
                  ),
                  _ModelButton(
                    label: "مو کوتاه",
                    color: btnColor,
                    onTap: () => setState(() => _selectedStyle = "hair_short"),
                  ),
                  _ModelButton(
                    label: "مو بلند",
                    color: btnColor,
                    onTap: () => setState(() => _selectedStyle = "hair_long"),
                  ),
                  _ModelButton(
                    label: "رنگ بلوند",
                    color: btnColor,
                    onTap: () => setState(() => _selectedStyle = "hair_blonde"),
                  ),
                  _ModelButton(
                    label: "رنگ مشکی",
                    color: btnColor,
                    onTap: () => setState(() => _selectedStyle = "hair_black"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // دکمه اعمال مدل
              ElevatedButton(
                onPressed: (_image == null || _selectedStyle == null || _loading)
                    ? null
                    : _applyModel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: header,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("اعمال مدل و پردازش"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// کامپوننت دکمه مدل‌ها
class _ModelButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModelButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(label),
      ),
    );
  }
}

