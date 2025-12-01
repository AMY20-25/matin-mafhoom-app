import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:matin_mafhoom/api/api_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Jalali? selectedDate;
  String? selectedSlot;
  String phoneNumber = "";

  final List<String> allSlots = List.generate(15, (i) {
    final hour = i + 9;
    return "${hour.toString().padLeft(2, '0')}:00";
  });

  List<String> reservedSlots = [];

  Future<void> submitReservation() async {
    if (selectedDate == null || selectedSlot == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً همه فیلدها را کامل کنید")),
      );
      return;
    }

    final dateKey =
        "${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}";

    try {
      final ok = await ApiService.reserve(
        date: dateKey,
        slot: selectedSlot!,
        phone: phoneNumber.trim(),
      );

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("رزرو شما با موفقیت ثبت شد ✅")),
        );
        setState(() {
          reservedSlots.add(selectedSlot!);
          selectedSlot = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("خطا در ثبت رزرو ❌")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ارتباط با سرور برقرار نشد ❌")),
      );
    }
  }

  Future<void> fetchReservations() async {
    if (selectedDate == null) return;

    final dateKey =
        "${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}";

    try {
      final slots = await ApiService.getReservations(dateKey);
      setState(() {
        reservedSlots = slots;
      });
    } catch (e) {
      debugPrint("خطا در دریافت رزروها: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDate != null
        ? "${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}"
        : "تاریخ را انتخاب کنید";

    return Scaffold(
      appBar: AppBar(
        title: const Text("رزرو وقت"),
        backgroundColor: const Color(0xFF444444),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("انتخاب تاریخ:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: DateTime.now(),
              onDaySelected: (day, _) async {
                final g = Gregorian(day.year, day.month, day.day);
                final j = g.toJalali();
                setState(() {
                  selectedDate = j;
                  selectedSlot = null;
                });
                await fetchReservations(); // صبر کن تا رزروها از سرور بیاد
              },
            ),
            const SizedBox(height: 20),
            Text("تاریخ انتخابی: $formattedDate", style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 30),
            const Text("ساعت‌های قابل رزرو:", style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: allSlots.map((slot) {
                final isReserved = reservedSlots.contains(slot);
                final isSelected = selectedSlot == slot;

                return ElevatedButton(
                  onPressed: isReserved
                      ? null
                      : () {
                          setState(() {
                            selectedSlot = slot;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isReserved
                        ? Colors.grey.shade400
                        : isSelected
                            ? Colors.green
                            : const Color(0xFFD4AF37),
                  ),
                  child: Text(
                    isReserved ? "$slot (رزرو شده)" : slot,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "شماره موبایل",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                phoneNumber = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitReservation,
              child: const Text("ثبت رزرو"),
            ),
          ],
        ),
      ),
    );
  }
}

