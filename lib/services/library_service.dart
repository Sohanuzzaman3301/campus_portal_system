import 'package:campus_portal_system/database/database_helper.dart';
import 'package:campus_portal_system/models/book.dart';

class LibraryService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Get all books
  Future<List<Book>> getAllBooks() async {
    final List<Map<String, dynamic>> maps = await _db.getAllBooks();
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  // Get a single book by ID
  Future<Book?> getBookById(String bookId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  // Insert a single book
  Future<String> insertBook(Book book) async {
    return await _db.insertBook(book.toMap());
  }

  // Insert multiple books
  Future<void> insertBooks(List<Map<String, dynamic>> books) async {
    await _db.insertBooks(books);
  }

  // Update a book
  Future<int> updateBook(Book book) async {
    final db = await _db.database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'book_id = ?',
      whereArgs: [book.bookId],
    );
  }

  // Delete a book
  Future<int> deleteBook(String bookId) async {
    final db = await _db.database;
    return await db.delete(
      'books',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  // Search books by title or author
  Future<List<Book>> searchBooks(String query) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }
} 