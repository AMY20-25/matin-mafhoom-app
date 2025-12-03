class User {
  final int id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  // Add other fields as needed

  User({required this.id, required this.phoneNumber, this.firstName, this.lastName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phone_number'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}

