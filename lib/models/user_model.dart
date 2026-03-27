class UserModel {
  final String id;
  final String name;   // <-- added
  final String email;
  final String phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',       // <-- read from Supabase table
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,                 // <-- save name
        'email': email,
        'phone': phone,
      };
}
