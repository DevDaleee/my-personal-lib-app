import 'package:material_ui/material_ui.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/pages/components/book_cover.dart';
import 'package:my_personal_lib_app/pages/components/status_badge.dart';

/// Linha de um livro na Minha biblioteca: capa, título com o selo de status,
/// autor e, se estiver lendo, o progresso; senão, o total de páginas.
class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book, this.onTap});

  // Medidas do Figma (px).
  static const double _verticalPadding = 16;
  static const double _coverGap = 14;

  final Book book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(book: book),
            const SizedBox(width: _coverGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.titleLarge),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: book.status),
                    ],
                  ),
                  Text(book.author, style: textTheme.bodyMedium?.copyWith(color: colors.secondary)),
                  if (book.status == BookStatus.reading) ...[
                    const SizedBox(height: 10),
                    _ReadingProgress(book: book),
                  ] else ...[
                    const SizedBox(height: 6),
                    Text('${book.totalPages} páginas', style: textTheme.bodyMedium?.copyWith(color: colors.secondary.withValues(alpha: 0.8))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingProgress extends StatelessWidget {
  const _ReadingProgress({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final small = textTheme.labelSmall?.copyWith(letterSpacing: 0.44);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('${book.currentPage} de ${book.totalPages} páginas', style: small?.copyWith(color: colors.secondary)),
            ),
            Text('${(book.progress * 100).round()}%', style: small?.copyWith(color: colors.primary)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: book.progress),
      ],
    );
  }
}
