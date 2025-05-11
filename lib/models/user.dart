class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final bool isVerified;
  final String? studentId;
  final String? instructorId;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.isVerified = false,
    this.studentId,
    this.instructorId,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      isVerified: (map['is_verified'] as int?) == 1,
      studentId: map['student_id'] as String?,
      instructorId: map['instructor_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'is_verified': isVerified ? 1 : 0,
      'student_id': studentId,
      'instructor_id': instructorId,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? role,
    bool? isVerified,
    String? studentId,
    String? instructorId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      studentId: studentId ?? this.studentId,
      instructorId: instructorId ?? this.instructorId,
    );
  }
}
