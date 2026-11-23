// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_detail_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BookDetailController on BookDetailControllerBase, Store {
  late final _$bookAtom = Atom(
    name: 'BookDetailControllerBase.book',
    context: context,
  );

  @override
  Book? get book {
    _$bookAtom.reportRead();
    return super.book;
  }

  @override
  set book(Book? value) {
    _$bookAtom.reportWrite(value, super.book, () {
      super.book = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'BookDetailControllerBase.isLoading',
    context: context,
  );

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

  late final _$errorAtom = Atom(
    name: 'BookDetailControllerBase.error',
    context: context,
  );

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

  late final _$notFoundAtom = Atom(
    name: 'BookDetailControllerBase.notFound',
    context: context,
  );

  @override
  bool get notFound {
    _$notFoundAtom.reportRead();
    return super.notFound;
  }

  @override
  set notFound(bool value) {
    _$notFoundAtom.reportWrite(value, super.notFound, () {
      super.notFound = value;
    });
  }

  late final _$isUpdatingAtom = Atom(
    name: 'BookDetailControllerBase.isUpdating',
    context: context,
  );

  @override
  bool get isUpdating {
    _$isUpdatingAtom.reportRead();
    return super.isUpdating;
  }

  @override
  set isUpdating(bool value) {
    _$isUpdatingAtom.reportWrite(value, super.isUpdating, () {
      super.isUpdating = value;
    });
  }

  late final _$updateErrorAtom = Atom(
    name: 'BookDetailControllerBase.updateError',
    context: context,
  );

  @override
  String? get updateError {
    _$updateErrorAtom.reportRead();
    return super.updateError;
  }

  @override
  set updateError(String? value) {
    _$updateErrorAtom.reportWrite(value, super.updateError, () {
      super.updateError = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    'BookDetailControllerBase.load',
    context: context,
  );

  @override
  Future<void> load(String id) {
    return _$loadAsyncAction.run(() => super.load(id));
  }

  late final _$updateProgressAsyncAction = AsyncAction(
    'BookDetailControllerBase.updateProgress',
    context: context,
  );

  @override
  Future<bool> updateProgress(int currentPage) {
    return _$updateProgressAsyncAction.run(
      () => super.updateProgress(currentPage),
    );
  }

  @override
  String toString() {
    return '''
book: ${book},
isLoading: ${isLoading},
error: ${error},
notFound: ${notFound},
isUpdating: ${isUpdating},
updateError: ${updateError}
    ''';
  }
}
