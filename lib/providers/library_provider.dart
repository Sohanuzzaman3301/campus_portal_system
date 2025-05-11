import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/library_service.dart';

// Provider for LibraryService
final libraryServiceProvider = Provider((ref) => LibraryService());

// Provider for all books
final libraryBooksProvider = FutureProvider<List<Book>>((ref) async {
  final libraryService = ref.read(libraryServiceProvider);
  return await libraryService.getAllBooks();
});

// Provider for searching books
final bookSearchProvider = FutureProvider.family<List<Book>, String>((ref, query) async {
  final libraryService = ref.read(libraryServiceProvider);
  if (query.isEmpty) {
    return await libraryService.getAllBooks();
  }
  return await libraryService.searchBooks(query);
});

// Provider for a single book
final bookProvider = FutureProvider.family<Book?, String>((ref, bookId) async {
  final libraryService = ref.read(libraryServiceProvider);
  return await libraryService.getBookById(bookId);
}); 