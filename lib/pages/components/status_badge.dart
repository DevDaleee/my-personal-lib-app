import 'package:flutter/material.dart';
import 'package:my_personal_lib_app/models/book.dart';

/// Selo pequeno com o status do livro ("Lendo", "Quero ler", "Lido").
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  // Medidas do Figma (px).
  static const double _radius = 2;
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);

  final BookStatus status;

  static String labelFor(BookStatus status) => switch (status) {
    BookStatus.reading => 'Lendo',
    BookStatus.wannaRead => 'Quero ler',
    BookStatus.read => 'Lido',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Lendo em destaque; os outros discretos.
    final (background, foreground) = switch (status) {
      BookStatus.reading => (colors.primaryContainer, colors.onPrimaryContainer),
      BookStatus.wannaRead => (colors.secondaryContainer, colors.onSecondaryContainer),
      BookStatus.read => (colors.surfaceContainerHigh, colors.secondary),
    };

    return Container(
      padding: _padding,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(_radius)),
      child: Text(labelFor(status), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: foreground)),
    );
  }
}
