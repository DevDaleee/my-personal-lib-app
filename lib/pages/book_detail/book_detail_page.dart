import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_lib_app/controllers/book_detail_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/pages/components/book_cover.dart';
import 'package:my_personal_lib_app/pages/components/profile_button.dart';
import 'package:my_personal_lib_app/pages/helpers/dates.dart';
import 'package:my_personal_lib_app/pages/helpers/toast.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';
import 'package:toastification/toastification.dart';

/// Detalhe do livro: dados, progresso e atualização da página atual
/// (Figma, seção 4.5 do `figma.md`). Do Figma, ficam de fora o que a API não
/// tem: "Editar informações", "Remover da biblioteca", "Edição" e o "tempo estimado".
class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final BookDetailController controller = GetIt.I.get<BookDetailController>();

  // Medidas do Figma (px).
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 8, 16, 40);
  static const double _sectionGap = 24;

  @override
  void initState() {
    super.initState();
    controller.load(widget.bookId);
  }

  /// Volta para a tela anterior; aberta direto pela URL (web), vai para a Home.
  void _close() => context.canPop() ? context.pop() : context.go('/home');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes Do Livro'),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: colors.primary),
        actions: const [ProfileButton(), SizedBox(width: 16)],
      ),
      body: Observer(
        builder: (context) {
          final book = controller.book;
          if (controller.notFound) return _NotFound(onBack: _close);
          if (book == null) {
            if (controller.error != null) return _LoadError(message: controller.error!, onRetry: () => controller.load(widget.bookId));
            return const Center(child: CircularProgressIndicator());
          }
          // "Puxar para atualizar".
          return RefreshIndicator(
            onRefresh: () => controller.load(widget.bookId),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: _padding,
              children: [
                _Header(book: book),
                const SizedBox(height: _sectionGap),
                _ProgressCard(book: book),
                const SizedBox(height: _sectionGap),
                _UpdateCard(controller: controller),
                const SizedBox(height: _sectionGap),
                _InfoCard(book: book),
                if (book.notes != null) ...[
                  const SizedBox(height: _sectionGap),
                  _NotesCard(notes: book.notes!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Capa 128×192 com a fita marcadora, título, autor e o selo de status.
class _Header extends StatelessWidget {
  const _Header({required this.book});

  final Book book;

  static const double _coverWidth = 128;
  static const double _coverHeight = 192;
  static const double _ribbonWidth = 12;
  static const double _ribbonHeight = 24;
  static const double _coverToText = 16;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            BookCover(book: book, width: _coverWidth, height: _coverHeight),
            // Fita marcadora no canto superior direito.
            Positioned(
              top: 0,
              right: 12,
              child: Container(width: _ribbonWidth, height: _ribbonHeight, color: colors.primaryContainer),
            ),
          ],
        ),
        const SizedBox(width: _coverToText),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: textTheme.headlineMedium?.copyWith(fontSize: 26, color: colors.primary)),
              const SizedBox(height: 4),
              Text(book.author, style: textTheme.bodyLarge?.copyWith(color: colors.secondary)),
              const SizedBox(height: 12),
              _StatusPill(status: book.status),
            ],
          ),
        ),
      ],
    );
  }
}

/// Selo do Detalhe: cantos 12, ponto + texto em maiúsculas ("LENDO").
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final BookStatus status;

  static String labelFor(BookStatus status) => switch (status) {
    BookStatus.reading => 'LENDO',
    BookStatus.wannaRead => 'QUERO LER',
    BookStatus.read => 'LIDO',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors.primaryFixed, borderRadius: BorderRadius.circular(pillRadius)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(labelFor(status), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onPrimaryFixed, letterSpacing: 0.55)),
        ],
      ),
    );
  }
}

/// "Progresso atual": porcentagem, "Página X de Y páginas", restantes e a barra.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final percent = (book.progress * 100).round();
    final remaining = book.totalPages - book.currentPage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text('Progresso atual', style: textTheme.titleSmall)),
                Text('$percent%', style: textTheme.titleSmall?.copyWith(color: colors.primary)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text('Página ${book.currentPage} de ${book.totalPages} páginas', style: textTheme.bodyMedium)),
                Text('$remaining restantes', style: textTheme.labelSmall?.copyWith(color: colors.secondary)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: book.progress, minHeight: 6),
          ],
        ),
      ),
    );
  }
}

/// "Atualizar leitura": campo da página atual + botão "Atualizar".
class _UpdateCard extends StatefulWidget {
  const _UpdateCard({required this.controller});

  final BookDetailController controller;

  @override
  State<_UpdateCard> createState() => _UpdateCardState();
}

class _UpdateCardState extends State<_UpdateCard> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = TextEditingController();

  static const double _buttonHeight = 44;

  /// Depois da primeira tentativa, o campo se valida a cada digitação
  /// (a mensagem de erro some assim que a página fica certa).
  bool _submitted = false;

  BookDetailController get controller => widget.controller;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Conforto do usuário: a validação que vale é a do back-end (0..total_pages).
  String? _validatePage(String? value) {
    final total = controller.book?.totalPages ?? 0;
    final page = int.tryParse((value ?? '').trim());
    if (page == null) return 'Informe a página atual';
    if (page > total) return 'O livro tem $total páginas';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await controller.updateProgress(int.parse(_pageController.text.trim()));
    if (!mounted) return;

    if (!ok) {
      ToastService.show(
        key: 'book-progress',
        title: const Text('Não foi possível atualizar'),
        description: Text(controller.updateError ?? 'Algo deu errado. Tente novamente.'),
        type: ToastificationType.error,
      );
      return;
    }
    final book = controller.book!;
    // Limpa o campo sem mostrar "Informe a página atual".
    setState(() => _submitted = false);
    _pageController.clear();
    _formKey.currentState?.reset();
    ToastService.show(
      key: 'book-progress',
      title: Text(book.status == BookStatus.read ? 'Livro concluído!' : 'Leitura atualizada'),
      description: Text('Página ${book.currentPage} de ${book.totalPages}.'),
      type: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Atualizar leitura', style: textTheme.titleSmall)),
                  Text('Marca-páginas diário', style: textTheme.labelSmall?.copyWith(color: colors.secondary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pageController,
                      validator: _validatePage,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Página atual',
                        suffixText: 'pág.',
                        suffixStyle: textTheme.labelSmall?.copyWith(color: colors.secondary),
                        fillColor: colors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Observer(
                    builder: (_) => SizedBox(
                      height: _buttonHeight,
                      child: ElevatedButton(
                        onPressed: controller.isUpdating ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryContainer,
                          foregroundColor: colors.onPrimaryContainer,
                          minimumSize: const Size(0, _buttonHeight),
                        ),
                        child: controller.isUpdating
                            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Atualizar'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: colors.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'As estatísticas podem levar alguns segundos para atualizar.',
                      style: textTheme.bodyMedium?.copyWith(color: colors.secondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Ficha do caderno": status, avaliação, exemplar, data e ISBN.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.book});

  final Book book;

  static String statusText(Book book) => switch (book.status) {
    BookStatus.reading => 'Lendo atualmente',
    BookStatus.wannaRead => 'Quero ler',
    BookStatus.read => book.finishedAt == null ? 'Lido' : 'Lido em ${fullDate(book.finishedAt!)}',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final valueStyle = textTheme.labelMedium?.copyWith(color: colors.primary);

    final rows = <(String, Widget)>[
      ('Status', Text(statusText(book), style: valueStyle)),
      ('Minha avaliação', _Rating(rating: book.rating)),
      ('Tenho o exemplar', Text(book.owned ? 'Sim' : 'Não', style: valueStyle)),
      ('Adicionado em', Text(fullDate(book.createdAt), style: textTheme.labelMedium?.copyWith(color: colors.secondary))),
      if (book.isbn != null) ('ISBN', Text(book.isbn!, style: textTheme.labelMedium?.copyWith(color: colors.secondary))),
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: colors.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Ficha do caderno', style: textTheme.titleSmall),
          ),
          for (final (index, (label, value)) in rows.indexed) ...[
            if (index > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: textTheme.bodyLarge)),
                  value,
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Estrelas da nota + "(4 de 5)"; sem nota, "Não avaliado".
class _Rating extends StatelessWidget {
  const _Rating({required this.rating});

  final int? rating;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final value = rating;
    if (value == null) return Text('Não avaliado', style: textTheme.labelMedium?.copyWith(color: colors.secondary));

    return Semantics(
      label: '$value de 5 estrelas',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var star = 1; star <= 5; star++) Icon(star <= value ? Icons.star : Icons.star_border, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text('($value de 5)', style: textTheme.labelMedium?.copyWith(color: colors.primary)),
        ],
      ),
    );
  }
}

/// Notas do livro, com a barra lateral do Figma.
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: colors.primaryContainer),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MINHAS NOTAS', style: textTheme.labelSmall?.copyWith(letterSpacing: 0.55, color: colors.secondary)),
                    const SizedBox(height: 8),
                    Text(notes, style: textTheme.titleLarge?.copyWith(fontSize: 18, fontStyle: FontStyle.italic, color: colors.onSurface)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404: o livro não existe ou é de outra pessoa.
class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 32, color: colors.secondary),
            const SizedBox(height: 12),
            Text('Livro não encontrado', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Ele pode ter sido removido ou o link está errado.', textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colors.secondary)),
            const SizedBox(height: 16),
            TextButton(onPressed: onBack, child: const Text('Voltar para a biblioteca')),
          ],
        ),
      ),
    );
  }
}

/// Erro ao buscar o livro (sem nada para mostrar ainda).
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 32, color: colors.secondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
