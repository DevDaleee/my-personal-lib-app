// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProfileController on ProfileControllerBase, Store {
  Computed<int>? _$pagesReadComputed;

  @override
  int get pagesRead => (_$pagesReadComputed ??= Computed<int>(() => super.pagesRead, name: 'ProfileControllerBase.pagesRead')).value;

  late final _$isLoadingAtom = Atom(name: 'ProfileControllerBase.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: 'ProfileControllerBase.error', context: context);

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

  late final _$userAtom = Atom(name: 'ProfileControllerBase.user', context: context);

  @override
  User? get user {
    _$userAtom.reportRead();
    return super.user;
  }

  @override
  set user(User? value) {
    _$userAtom.reportWrite(value, super.user, () {
      super.user = value;
    });
  }

  late final _$finishedThisYearAtom = Atom(name: 'ProfileControllerBase.finishedThisYear', context: context);

  @override
  int? get finishedThisYear {
    _$finishedThisYearAtom.reportRead();
    return super.finishedThisYear;
  }

  @override
  set finishedThisYear(int? value) {
    _$finishedThisYearAtom.reportWrite(value, super.finishedThisYear, () {
      super.finishedThisYear = value;
    });
  }

  late final _$streakAtom = Atom(name: 'ProfileControllerBase.streak', context: context);

  @override
  int? get streak {
    _$streakAtom.reportRead();
    return super.streak;
  }

  @override
  set streak(int? value) {
    _$streakAtom.reportWrite(value, super.streak, () {
      super.streak = value;
    });
  }

  late final _$sessionEndedAtom = Atom(name: 'ProfileControllerBase.sessionEnded', context: context);

  @override
  bool get sessionEnded {
    _$sessionEndedAtom.reportRead();
    return super.sessionEnded;
  }

  @override
  set sessionEnded(bool value) {
    _$sessionEndedAtom.reportWrite(value, super.sessionEnded, () {
      super.sessionEnded = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction('ProfileControllerBase.load', context: context);

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
user: ${user},
finishedThisYear: ${finishedThisYear},
streak: ${streak},
sessionEnded: ${sessionEnded},
pagesRead: ${pagesRead}
    ''';
  }
}
