import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/library_provider.dart';
import '../providers/add_book_provider.dart';
import 'package:ionicons/ionicons.dart';

class AddBooksPage extends ConsumerWidget {
  AddBooksPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  Future<void> _submitForm(BuildContext context, WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final bookData = {
      'book_id': 'BOOK${DateTime.now().millisecondsSinceEpoch}',
      'title': _titleController.text,
      'author': _authorController.text,
      'isbn': _isbnController.text.isNotEmpty ? _isbnController.text : null,
      'cover_url': _coverUrlController.text.isNotEmpty ? _coverUrlController.text : null,
      'category': _categoryController.text.isNotEmpty ? _categoryController.text : null,
    };

    final success = await ref.read(addBookProvider.notifier).addBook(bookData);
    
    if (success && context.mounted) {
      ref.refresh(libraryBooksProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book added successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addBookProvider);

    // Show error if any
    ref.listen<AddBookState>(addBookProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Ionicons.book_outline),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  prefixIcon: Icon(Ionicons.person_outline),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Ionicons.document_text_outline),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  prefixIcon: Icon(Ionicons.barcode_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coverUrlController,
                decoration: const InputDecoration(
                  labelText: 'Cover URL',
                  prefixIcon: Icon(Ionicons.image_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Ionicons.list_outline),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: state.isLoading ? null : () => _submitForm(context, ref),
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Ionicons.save_outline),
                  label: const Text('Save Book'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
