// Add this method to your UserDatabaseHelper class
import 'package:campus_portal_system/database/database_helper.dart';
import 'package:campus_portal_system/models/user.dart';

Future<void> updateUser(User user) async {
  final db = await DatabaseHelper.instance.database;
  
  await db.update(
    'users',
    user.toMap(),
    where: 'id = ?',
    whereArgs: [user.id],
  );
} 