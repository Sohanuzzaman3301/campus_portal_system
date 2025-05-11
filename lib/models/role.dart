enum UserRole {
  admin,
  student,
  instructor,
  librarian;

  String get displayName => name[0].toUpperCase() + name.substring(1);
} 