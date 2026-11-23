import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

part 'new_book_controller.g.dart';

/// Estado da tela Novo livro. Os textos ficam nos `TextEditingController` da
/// tela; aqui ficam a nota, o "Tenho este livro" e o envio.
/// Registrado como factory: cada abertura da tela começa com o formulário limpo.
class NewBookController = NewBookControllerBase with _$NewBookController;

abstract class NewBookControllerBase with Store {
  final BookServices services = GetIt.I.get<BookServices>();
  final LibraryController library = GetIt.I.get<LibraryController>();

  @observable
  bool isSaving = false;

  /// Mensagem do último erro ao salvar (nula se deu certo).
  @observable
  String? error;

  /// Nota de 1 a 5; nula = "Não avaliado".
  @observable
  int? rating;

  @observable
  bool owned = false;

  @action
  void setRating(int value) => rating = value.clamp(1, 5);

  @action
  void clearRating() => rating = null;

  @action
  void setOwned(bool value) => owned = value;

  /// `POST /books`. Devolve o livro criado, ou `null` se falhar (com a
  /// mensagem em [error]). Depois de salvar, recarrega a lista da biblioteca
  /// sem esperar, para a tela poder voltar na hora.
  @action
  Future<Book?> save({
    required String title,
    required String author,
    required int totalPages,
    String? isbn,
    String? notes,
    String? coverUrl,
  }) async {
    if (isSaving) return null;
    isSaving = true;
    error = null;
    try {
      final response = await services.createBook(
        title: title,
        author: author,
        totalPages: totalPages,
        owned: owned,
        isbn: isbn,
        rating: rating,
        notes: notes,
        coverUrl: coverUrl,
      );
      if (response["status_code"] != 201) {
        // 401 já é tratado no interceptor (apaga a sessão e volta para "Entrar").
        error = response["error"] as String? ?? ApiErrors.unexpectedError;
        return null;
      }
      final book = Book.fromJson(response["data"] as Map<String, dynamic>);
      unawaited(library.fetchBooks());
      return book;
    } catch (e) {
      // JSON fora do contrato: detalhe só no log.
      debugPrint('NewBookController.save: $e');
      error = ApiErrors.unexpectedError;
      return null;
    } finally {
      isSaving = false;
    }
  }
}
