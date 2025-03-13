/// PasswordModel manages a collection of passwords
class PasswordModel {
  List<Password> passwords;

  PasswordModel({
    this.passwords = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'passwords': passwords.map((p) => p.toJson()).toList(),
    };
  }

  factory PasswordModel.fromJson(Map<String, dynamic> json) {
    return PasswordModel(
      passwords: (json['passwords'] as List<dynamic>?)
              ?.map((p) => Password.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Password represents an individual password entry
class Password {
  String? id;
  final String username;
  String password;
  final String website;
  final String notes;
  final String email;
  final String? label;
  String? iv;

  Password({
    this.id,
    required this.username,
    required this.password,
    required this.website,
    required this.notes,
    required this.email,
    this.label,
    this.iv,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'email': email,
      'label': label,
      'iv': iv,
    };
  }

  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      id: json['id'],
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      website: json['website'] ?? '',
      notes: json['notes'] ?? '',
      email: json['email'] ?? '',
      label: json['label'],
      iv: json['iv'],
    );
  }

  Password copyWith({
    String? id,
    String? username,
    String? password,
    String? website,
    String? notes,
    String? email,
    String? label,
    String? iv,
  }) {
    return Password(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      email: email ?? this.email,
      label: label ?? this.label,
      iv: iv ?? this.iv,
    );
  }
}
