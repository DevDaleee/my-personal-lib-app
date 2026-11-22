// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LibraryController on LibraryControllerBase, Store {
  Computed<List<Book>>? _$visibleBooksComputed;

  @override
  List<Book> get visibleBooks => (_$visibleBooksComputed ??= Computed<List<Book>>(() => super.visibleBooks, name: 'LibraryControllerBase.visibleBooks')).value;

  late final _$isLoadingAtom = Atom(name: 'LibraryControllerBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorAtom = Atom(name: 'LibraryControllerBase.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$booksAtom = Atom(name: 'LibraryControllerBase.books', context: context);

  @override
  ObservableList<Book> get books {
    _$booksAtom.reportRead();
    return super.books;
  }

  @override
  set books(ObservableList<Book> value) {
    _$booksAtom.reportWrite(value, super.books, () {
      super.books = value;
    });
  }

  late final _$filterAtom = Atom(name: 'LibraryControllerBase.filter', context: context);

  @override
  BookFilter get filter {
    _$filterAtom.reportRead();
    return super.filter;
  }

  @override
  set filter(BookFilter value) {
    _$filterAtom.reportWrite(value, super.filter, () {
      super.filter = value;
    });
  }

  late final _$fetchBooksAsyncAction = AsyncAction('LibraryControllerBase.fetchBooks', context: context);

  @override
  Future<void> fetchBooks() {
    return _$fetchBooksAsyncAction.run(() => super.fetchBooks());
  }

  late final _$LibraryControllerBaseActionController = ActionController(name: 'LibraryControllerBase', context: context);

  @override
  void selectFilter(BookFilter value) {
    final _$actionInfo = _$LibraryControllerBaseActionController.startAction(name: 'LibraryControllerBase.selectFilter');
    try {
      return super.selectFilter(value);
    } finally {
      _$LibraryControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBooks(List<Book> value) {
    final _$actionInfo = _$LibraryControllerBaseActionController.startAction(name: 'LibraryControllerBase.setBooks');
    try {
      return super.setBooks(value);
    } finally {
      _$LibraryControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
books: ${books},
filter: ${filter},
visibleBooks: ${visibleBooks}
    ''';
  }
}
