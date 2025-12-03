import 'package:flutter/material.dart';
import 'package:matin_mafhoom/api/api_service.dart';
import 'package:matin_mafhoom/models/reservation_model.dart'; // We will create this model
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; // For Farsi locale

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedSlot;
  Future<List<Reservation>>? _reservationsFuture;

  final List<String> _timeSlots = List.generate(15, (i) => "${(i + 9).toString().padLeft(2, '0')}:00");

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  void _fetchReservations() {
    setState(() {
      _reservationsFuture = ApiService().getMyReservations();
    });
  }

  Future<void> _submitReservation() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لطفاً یک ساعت را انتخاب کنید")));
      return;
    }
    
    // Combine date and time
    final selectedDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      int.parse(_selectedSlot!.split(':')[0]),
    );

    final success = await ApiService().createReservation(selectedDateTime, "haircut"); // Example service type

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "رزرو شما با موفقیت ثبت شد ✅" : "خطا در ثبت رزرو ❌")),
      );
      if (success) {
        _fetchReservations(); // Refresh the list after booking
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("رزرو وقت")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCalendar(),
            const SizedBox(height: 20),
            const Text("ساعت‌های قابل رزرو:", style: TextStyle(fontSize: 18)),
            _buildTimeSlots(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitReservation,
              child: const Text("ثبت نهایی رزرو"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      locale: 'fa_IR',
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2026, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedSlot = null;
        });
      },
    );
  }

  Widget _buildTimeSlots() {
    return FutureBuilder<List<Reservation>>(
      future: _reservationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("خطا در دریافت اطلاعات: ${snapshot.error}"));
        }
        
        final reservedSlotsForSelectedDay = snapshot.data
            ?.where((res) => isSameDay(res.date, _selectedDay))
            .map((res) => "${res.date.hour.toString().padLeft(2, '0')}:00")
            .toList() ?? [];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _timeSlots.map((slot) {
            final isReserved = reservedSlotsForSelectedDay.contains(slot);
            final isSelected = _selectedSlot == slot;
            return ElevatedButton(
              onPressed: isReserved ? null : () => setState(() => _selectedSlot = slot),
              style: ElevatedButton.styleFrom(
                backgroundColor: isReserved ? Colors.grey : (isSelected ? Colors.green : Theme.of(context).primaryColor),
              ),
              child: Text(slot),
            );
          }).toList(),
        );
      },
    );
  }
}

