class Reservation {
  final int id;
  final DateTime date;
  // Add other fields from your API response here
  // final String status;

  Reservation({required this.id, required this.date});

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      date: DateTime.parse(json['date']),
      // status: json['status'],
    );
  }
}
