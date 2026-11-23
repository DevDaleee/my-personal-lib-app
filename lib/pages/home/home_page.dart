import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/pages/components/app_navigation_bar.dart';
import 'package:my_personal_lib_app/pages/components/book_tile.dart';
import 'package:my_personal_lib_app/pages/components/profile_button.dart';

/// Minha biblioteca: a Home do app.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LibraryController controller = GetIt.I.get<LibraryController>();

  // Medidas do Figma (px).
  static const double _maxWidth = 600;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 8, 16, 32);
  static const double _headerToFilters = 24;
  static const double _filtersToList = 20;

  @override
  void initState() {
    super.initState();
    // Busca ao abrir a tela (os dados podem ter mudado em outra tela ou aparelho).
    controller.fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca'), actions: [const ProfileButton(), const SizedBox(width: 16)]),
      bottomNavigationBar: const AppNavigationBar(current: AppTab.library),
      body: Observer(
        builder: (context) {
          final books = controller.visibleBooks;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              // "Puxar para atualizar".
              child: RefreshIndicator(
                onRefresh: controller.fetchBooks,
                child: ListView(
                  // Permite puxar mesmo com a lista curta ou vazia.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: _padding,
                  children: [
                    const _Header(),
                    const SizedBox(height: _headerToFilters),
                    _Filters(selected: controller.filter, count: books.length, onSelected: controller.selectFilter),
                    const SizedBox(height: _filtersToList),
                    // Falhou: avisa e mantém na tela os livros que já estavam carregados.
                    if (controller.error != null) _ErrorState(message: controller.error!, onRetry: controller.fetchBooks),
                    if (books.isEmpty && controller.isLoading && controller.error == null) const _LoadingState(),
                    if (books.isEmpty && !controller.isLoading && controller.error == null) _EmptyState(filter: controller.filter),
                    for (final (index, book) in books.indexed) ...[
                      // TODO: abrir o Detalhe do livro quando a tela existir.
                      BookTile(book: book),
                      if (index < books.length - 1) const Divider(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "CADERNO DE LEITURAS / Minha biblioteca" e o botão "+ Novo livro".
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CADERNO DE LEITURAS', style: textTheme.labelSmall?.copyWith(letterSpacing: 0.55, color: colors.secondary)),
              const SizedBox(height: 5),
              Text('Minha biblioteca', style: textTheme.headlineMedium?.copyWith(fontSize: 26, color: colors.primary)),
            ],
          ),
        ),
        ElevatedButton.icon(
          // A lista é recarregada pelo NewBookController depois de salvar.
          onPressed: () => context.push('/books/new'),
          icon: const Icon(Icons.add, size: 12),
          label: const Text('Novo livro'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: textTheme.labelMedium),
        ),
      ],
    );
  }
}

/// Filtro por status; o selecionado mostra quantos livros tem.
class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.count, required this.onSelected});

  static const double _height = 36;

  final BookFilter selected;
  final int count;
  final ValueChanged<BookFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: SegmentedButton<BookFilter>(
        showSelectedIcon: false,
        selected: {selected},
        onSelectionChanged: (value) => onSelected(value.first),
        segments: [
          for (final filter in BookFilter.values)
            ButtonSegment(
              value: filter,
              label: Text.rich(
                TextSpan(
                  text: filter.label,
                  children: [
                    if (filter == selected)
                      TextSpan(
                        text: ' $count',
                        style: TextStyle(color: colors.primary.withValues(alpha: 0.7)),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final BookFilter filter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final (title, text) = switch (filter.status) {
      null => ('Sua estante está vazia', 'Toque em "Novo livro" para registrar sua primeira leitura.'),
      BookStatus.reading => ('Nenhuma leitura em andamento', 'Os livros aparecem aqui quando você atualiza a página atual.'),
      BookStatus.wannaRead => ('Nada na fila', 'Livros que você ainda não começou aparecem aqui.'),
      BookStatus.read => ('Nenhum livro concluído', 'Quando chegar à última página, o livro aparece aqui.'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.auto_stories_outlined, size: 32, color: colors.secondary),
          const SizedBox(height: 12),
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(color: colors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Erro ao buscar os livros, com a mensagem da API e "Tentar novamente".
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 32, color: colors.error),
          const SizedBox(height: 12),
          Text('Não foi possível carregar seus livros', style: textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(color: colors.secondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
