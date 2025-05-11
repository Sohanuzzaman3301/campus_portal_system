class Course {
  final String courseId;
  final String name;
  final String department;
  final String? instructorId;
  final String? timeSlot;
  final String? enrollmentDate;
  final String? status;
  final String? grade;

  Course({
    required this.courseId,
    required this.name,
    required this.department,
    this.instructorId,
    this.timeSlot,
    this.enrollmentDate,
    this.status,
    this.grade,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['course_id'],
      name: map['name'],
      department: map['department'],
      instructorId: map['instructor_id'],
      timeSlot: map['time_slot'],
      enrollmentDate: map['enrollment_date'],
      status: map['status'],
      grade: map['grade'],
    );
  }
} 