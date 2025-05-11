# Campus Portal System

## Overview
A multiplatform application (Android, iOS, Web, Desktop) designed to manage and streamline campus operations for administrators, teachers, and students.

## Technical Stack
- **Framework**: Flutter
- **Database**: SQLite3 (via sqflite)
- **State Management**: Flutter Riverpod
- **Navigation**: Go Router
- **UI Components**: Material Design 3
- **Icons**: Ionicons
- **Animations**: Lottie

## Features

### Authentication & Authorization
- User registration with role selection (Admin/Teacher/Student)
- Secure login system
- Persistent login state
- Role-based access control
- User verification system for new registrations

### Admin Dashboard
- Verify new user registrations
- Manage teachers and students
- Assign courses to teachers
- View and manage library resources
- Monitor system activities
- Group students by major
- Group teachers by department

### Teacher Features
- View assigned courses
- Access student information
- Manage course materials
- Track student attendance
- Update course information
- View department-specific information

### Student Features
- View enrolled courses
- Access course materials
- Check grades
- Borrow library books
- View academic schedule
- Track academic progress

### Library Management
- Book catalog
- Borrowing system
- Book search functionality
- Track borrowed books
- Manage returns

### User Management
- Profile management
- Password updates
- Role-specific settings
- Theme customization
- Language preferences (planned)

## Database Structure
- Users table (authentication)
- Students table (academic info)
- Teachers table (department info)
- Courses table (academic courses)
- Books table (library resources)
- Enrollments table (course registrations)
- Transactions table (library activities)

## UI/UX Goals
- Clean, modern interface
- Responsive design for all platforms
- Dark/Light theme support
- Intuitive navigation
- Loading animations
- Error handling with user feedback
- Consistent styling across platforms

## Development Features
- Development mode for testing
- Mock data generation
- Debug logging
- Database verification tools
- Error tracking

## Future Enhancements
- Notifications system
- Advanced reporting
- File upload/download
- Chat system
- Calendar integration
- Mobile-specific features

## Security Considerations
- Password hashing
- Role-based permissions
- Session management
- Data validation
- Error handling

## Platform Support
- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Entity Relationship Diagram

This application aims to provide a comprehensive solution for managing campus activities while maintaining a user-friendly interface and robust functionality across all supported platforms. 