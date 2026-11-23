// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_book_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NewBookController on NewBookControllerBase, Store {
  late final _$isSavingAtom = Atom(
    name: 'NewBookControllerBase.isSaving',
    context: context,
  );

  @override
  bool get isSaving {
    _$isSavingAtom.reportRead();
    return super.isSaving;
  }

  @override
  set isSaving(bool value) {
    _$isSavingAtom.reportWrite(value, super.isSaving, () {
      super.isSaving = value;
    });
  }

  late final _$errorAtom = Atom(
    name: 'NewBookControllerBase.error',
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

  late final _$ratingAtom = Atom(
    name: 'NewBookControllerBase.rating',
    context: context,
  );

  @override
  int? get rating {
    _$ratingAtom.reportRead();
    return super.rating;
  }

  @override
  set rating(int? value) {
    _$ratingAtom.reportWrite(value, super.rating, () {
      super.rating = value;
    });
  }

  late final _$ownedAtom = Atom(
    name: 'NewBookControllerBase.owned',
    context: context,
  );

  @override
  bool get owned {
    _$ownedAtom.reportRead();
    return super.owned;
  }

  @override
  set owned(bool value) {
    _$ownedAtom.reportWrite(value, super.owned, () {
      super.owned = value;
    });
  }

  late final _$saveAsyncAction = AsyncAction(
    'NewBookControllerBase.save',
    context: context,
  );

  @override
  Future<Book?> save({
    required String title,
    required String author,
    required int totalPages,
    String? isbn,
    String? notes,
    String? coverUrl,
  }) {
    return _$saveAsyncAction.run(
      () => super.save(
        title: title,
        author: author,
        totalPages: totalPages,
        isbn: isbn,
        notes: notes,
        coverUrl: coverUrl,
      ),
    );
  }

  late final _$NewBookControllerBaseActionController = ActionController(
    name: 'NewBookControllerBase',
    context: context,
  );

  @override
  void setRating(int value) {
    final _$actionInfo = _$NewBookControllerBaseActionController.startAction(
      name: 'NewBookControllerBase.setRating',
    );
    try {
      return super.setRating(value);
    } finally {
      _$NewBookControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearRating() {
    final _$actionInfo = _$NewBookControllerBaseActionController.startAction(
      name: 'NewBookControllerBase.clearRating',
    );
    try {
      return super.clearRating();
    } finally {
      _$NewBookControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOwned(bool value) {
    final _$actionInfo = _$NewBookControllerBaseActionController.startAction(
      name: 'NewBookControllerBase.setOwned',
    );
    try {
      return super.setOwned(value);
    } finally {
      _$NewBookControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isSaving: ${isSaving},
error: ${error},
rating: ${rating},
owned: ${owned}
    ''';
  }
}
