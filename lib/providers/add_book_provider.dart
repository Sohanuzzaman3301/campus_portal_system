import 'package:campus_portal_system/providers/library_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/library_service.dart';

class AddBookState {
  final bool isLoading;
  final String? error;

  AddBookState({
    this.isLoading = false,
    this.error,
  });

  AddBookState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AddBookState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddBookNotifier extends StateNotifier<AddBookState> {
  final LibraryService _libraryService;

  AddBookNotifier(this._libraryService) : super(AddBookState());

  Future<bool> addBook(Map<String, dynamic> bookData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _libraryService.insertBooks([bookData]);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final addBookProvider = StateNotifierProvider<AddBookNotifier, AddBookState>((ref) {
  final libraryService = ref.watch(libraryServiceProvider);
  return AddBookNotifier(libraryService);
}); 