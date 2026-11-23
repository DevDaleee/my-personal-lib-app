import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

part 'book_detail_controller.g.dart';

/// Estado da tela Detalhe do livro: o livro aberto e a atualização da página atual.
/// Registrado como factory: cada abertura da tela tem o seu.
class BookDetailController = BookDetailControllerBase with _$BookDetailController;

abstract class BookDetailControllerBase with Store {
  final BookServices services = GetIt.I.get<BookServices>();
  final LibraryController library = GetIt.I.get<LibraryController>();

  @observable
  Book? book;

  @observable
  bool isLoading = false;

  /// Erro ao buscar o livro (nulo se deu certo).
  @observable
  String? error;

  /// `GET /books/{id}` respondeu 404: o livro não existe ou é de outra pessoa.
  @observable
  bool notFound = false;

  @observable
  bool isUpdating = false;

  /// Erro da última atualização de página (nulo se deu certo).
  @observable
  String? updateError;

  /// Busca o livro (`GET /books/{id}`). Se falhar, mantém o livro que já estava na tela.
  @action
  Future<void> load(String id) async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notFound = false;
    try {
      final response = await services.getBook(id);
      if (response["status_code"] == 404) {
        notFound = true;
        return;
      }
      if (response["status_code"] != 200) {
        // 401 já é tratado no interceptor (apaga a sessão e volta para "Entrar").
        error = response["error"] as String? ?? ApiErrors.unexpectedError;
        return;
      }
      book = Book.fromJson(response["data"] as Map<String, dynamic>);
    } catch (e) {
      // JSON fora do contrato: detalhe só no log.
      debugPrint('BookDetailController.load: $e');
      error = ApiErrors.unexpectedError;
    } finally {
      isLoading = false;
    }
  }

  /// `PATCH /books/{id}/progress`. Troca o livro pelo que a API devolve (com o
  /// status novo) e recarrega a biblioteca sem esperar. Devolve `true` se deu certo;
  /// se falhar, a mensagem fica em [updateError].
  @action
  Future<bool> updateProgress(int currentPage) async {
    final current = book;
    if (current == null || isUpdating) return false;
    isUpdating = true;
    updateError = null;
    try {
      final response = await services.updateProgress(current.id, currentPage);
      if (response["status_code"] != 200) {
        updateError = response["error"] as String? ?? ApiErrors.unexpectedError;
        return false;
      }
      book = Book.fromJson(response["data"] as Map<String, dynamic>);
      unawaited(library.fetchBooks());
      return true;
    } catch (e) {
      debugPrint('BookDetailController.updateProgress: $e');
      updateError = ApiErrors.unexpectedError;
      return false;
    } finally {
      isUpdating = false;
    }
  }
}
