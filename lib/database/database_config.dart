import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseConfig {
  static Future<void> initializeDatabase() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use default factory for mobile platforms
      // No need to initialize anything special
      return;
    } else {
      // For desktop/web platforms, use FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<String> getDatabasePath(String dbName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      return join(documentsDirectory.path, dbName);
    } else {
      return join(await getDatabasesPath(), dbName);
    }
  }

  static Future<Database> openDatabase(
    String path, {
    required int version,
    required OnDatabaseCreateFn onCreate,
    OnDatabaseVersionChangeFn? onUpgrade,
  }) async {
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      ),
    );
  }
}
