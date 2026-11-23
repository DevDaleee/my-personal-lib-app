// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthController on AuthControllerBase, Store {
  late final _$isLoadingAtom = Atom(
    name: 'AuthControllerBase.isLoading',
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

  late final _$submitLoginAsyncAction = AsyncAction(
    'AuthControllerBase.submitLogin',
    context: context,
  );

  @override
  Future<void> submitLogin(GlobalKey<FormState> formKey, BuildContext context) {
    return _$submitLoginAsyncAction.run(
      () => super.submitLogin(formKey, context),
    );
  }

  late final _$submitRegisterAsyncAction = AsyncAction(
    'AuthControllerBase.submitRegister',
    context: context,
  );

  @override
  Future<void> submitRegister(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    return _$submitRegisterAsyncAction.run(
      () => super.submitRegister(formKey, context),
    );
  }

  late final _$_submissionSuccessAsyncAction = AsyncAction(
    'AuthControllerBase._submissionSuccess',
    context: context,
  );

  @override
  Future<void> _submissionSuccess({
    required String accessToken,
    String? userId,
    required BuildContext context,
  }) {
    return _$_submissionSuccessAsyncAction.run(
      () => super._submissionSuccess(
        accessToken: accessToken,
        userId: userId,
        context: context,
      ),
    );
  }

  late final _$AuthControllerBaseActionController = ActionController(
    name: 'AuthControllerBase',
    context: context,
  );

  @override
  void dispose() {
    final _$actionInfo = _$AuthControllerBaseActionController.startAction(
      name: 'AuthControllerBase.dispose',
    );
    try {
      return super.dispose();
    } finally {
      _$AuthControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _submissionFailure(String title, String? message) {
    final _$actionInfo = _$AuthControllerBaseActionController.startAction(
      name: 'AuthControllerBase._submissionFailure',
    );
    try {
      return super._submissionFailure(title, message);
    } finally {
      _$AuthControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading}
    ''';
  }
}
