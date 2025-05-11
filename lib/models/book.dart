class Book {
  final String bookId;
  final String title;
  final String author;
  final String? description;
  final String? coverUrl;
  final String? isbn;
  final String? category;

  Book({
    required this.bookId,
    required this.title,
    required this.author,
    this.description,
    this.coverUrl,
    this.isbn,
    this.category,
  });

  // Create a Book from a Map (database row)
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      bookId: map['book_id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      description: map['description'] as String?,
      coverUrl: map['cover_url'] as String?,
      isbn: map['isbn'] as String?,
      category: map['category'] as String?,
    );
  }

  // Convert Book to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'book_id': bookId,
      'title': title,
      'author': author,
      'description': description,
      'cover_url': coverUrl,
      'isbn': isbn,
      'category': category,
    };
  }

  // Create a copy of Book with some fields updated
  Book copyWith({
    String? bookId,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? isbn,
    String? category,
    DateTime? createdAt,
  }) {
    return Book(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Book(bookId: $bookId, title: $title, author: $author, category: $category)';
  }
}
