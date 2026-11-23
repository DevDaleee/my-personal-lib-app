import 'package:material_ui/material_ui.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

/// Capa pequena da lista (48×72). Usa a `cover_url` quando existe; sem imagem
/// (ou se ela falhar), mostra as iniciais do título, um traço na cor do status
/// e o sobrenome do autor.
class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.book});

  // Medidas do Figma (px).
  static const double width = 48;
  static const double height = 72;
  static const double _padding = 6;

  final Book book;

  /// Iniciais das duas primeiras palavras do título ("Torto Arado" → "TA").
  static String initials(String title) {
    final words = title.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
    return words.map((w) => w[0].toUpperCase()).join();
  }

  /// Última palavra do nome do autor ("Itamar Vieira Junior" → "Junior").
  static String lastName(String author) => author.trim().split(RegExp(r'\s+')).last;

  @override
  Widget build(BuildContext context) {
    final url = book.coverUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(smallRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url.isEmpty
            ? _Placeholder(book: book)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Placeholder(book: book),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stripe = switch (book.status) {
      BookStatus.reading => colors.primaryContainer,
      BookStatus.wannaRead => colors.secondary,
      BookStatus.read => colors.outline,
    };

    return Container(
      color: colors.surfaceContainerHigh,
      padding: const EdgeInsets.all(BookCover._padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BookCover.initials(book.title),
            style: TextStyle(fontFamily: headlineFont, fontSize: 10, fontWeight: FontWeight.w500, color: colors.primary),
          ),
          const SizedBox(height: 4),
          Container(width: 8, height: 2, color: stripe),
          const Spacer(),
          Text(
            BookCover.lastName(book.author),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: bodyFont, fontSize: 8, color: colors.secondary),
          ),
        ],
      ),
    );
  }
}
