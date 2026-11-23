import 'package:material_ui/material_ui.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

/// Capa do livro: 48×72 na lista e 128×192 no Detalhe. Usa a `cover_url`
/// quando existe; sem imagem (ou se ela falhar), mostra as iniciais do título,
/// um traço na cor do status e o sobrenome do autor.
class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.book, this.width = defaultWidth, this.height = defaultHeight});

  // Medidas do Figma (px), na capa da lista.
  static const double defaultWidth = 48;
  static const double defaultHeight = 72;
  static const double _padding = 6;

  final Book book;
  final double width;
  final double height;

  /// Quanto a capa é maior que a da lista: escala os textos da capa sem imagem.
  double get _scale => width / defaultWidth;

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
            ? _Placeholder(book: book, scale: _scale)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Placeholder(book: book, scale: _scale),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.book, required this.scale});

  final Book book;
  final double scale;

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
      padding: EdgeInsets.all(BookCover._padding * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BookCover.initials(book.title),
            style: TextStyle(fontFamily: headlineFont, fontSize: 10 * scale, fontWeight: FontWeight.w500, color: colors.primary),
          ),
          SizedBox(height: 4 * scale),
          Container(width: 8 * scale, height: 2 * scale, color: stripe),
          const Spacer(),
          Text(
            BookCover.lastName(book.author),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: bodyFont, fontSize: 8 * scale, color: colors.secondary),
          ),
        ],
      ),
    );
  }
}
