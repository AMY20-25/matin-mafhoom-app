class User {
  final int id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate; // Added for profile editing

  User({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.birthDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phone_number'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      // Safely parse the birth_date
      birthDate: json['birth_date'] != null ? DateTime.tryParse(json['birth_date']) : null,
    );
  }
}

