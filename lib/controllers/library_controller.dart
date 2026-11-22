import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

part 'library_controller.g.dart';

/// Filtros da tela Minha biblioteca. `status` nulo = todos.
enum BookFilter {
  all('Todos', null),
  reading('Lendo', BookStatus.reading),
  wannaRead('Quero ler', BookStatus.wannaRead),
  read('Lidos', BookStatus.read);

  const BookFilter(this.label, this.status);

  final String label;
  final BookStatus? status;
}

class LibraryController = LibraryControllerBase with _$LibraryController;

abstract class LibraryControllerBase with Store {
  final BookServices services = GetIt.I.get<BookServices>();

  @observable
  bool isLoading = false;

  /// Mensagem do último erro ao buscar os livros (nula se deu certo).
  @observable
  String? error;

  @observable
  ObservableList<Book> books = ObservableList<Book>();

  @observable
  BookFilter filter = BookFilter.all;

  /// Livros do filtro selecionado.
  @computed
  List<Book> get visibleBooks => filter.status == null ? books.toList() : books.where((book) => book.status == filter.status).toList();

  @action
  void selectFilter(BookFilter value) => filter = value;

  @action
  void setBooks(List<Book> value) => books = ObservableList.of(value);

  /// Busca todos os livros (`GET /books`); o filtro por status é feito aqui no
  /// app, para o contador do filtro não depender de outra chamada.
  /// Se falhar, mantém a lista que já estava na tela.
  @action
  Future<void> fetchBooks() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    try {
      final response = await services.getBooks();
      if (response["status_code"] != 200) {
        // 401 já é tratado no interceptor (apaga a sessão e volta para "Entrar").
        error = response["error"] as String? ?? ApiErrors.unexpectedError;
        return;
      }
      final data = response["data"] as List<dynamic>;
      setBooks(data.map((json) => Book.fromJson(json as Map<String, dynamic>)).toList());
    } catch (e) {
      // JSON fora do contrato: detalhe só no log.
      debugPrint('LibraryController.fetchBooks: $e');
      error = ApiErrors.unexpectedError;
    } finally {
      isLoading = false;
    }
  }
}
