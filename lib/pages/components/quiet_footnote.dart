import 'package:material_ui/material_ui.dart';

/// Card discreto de rodapé com ícone, título em caixa alta e um texto.
/// Ex.: "SEM DISTRAÇÕES" nas telas de entrada.
class QuietFootnote extends StatelessWidget {
  const QuietFootnote({super.key, required this.icon, required this.title, required this.text});

  // Medidas do Figma (px).
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 24, 16, 16);
  static const double _radius = 4;
  static const double _iconSize = 15;
  static const double _iconGap = 8;
  static const double _titleToText = 8;

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(_radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: _iconSize, color: colors.secondary),
              const SizedBox(width: _iconGap),
              Text(title.toUpperCase(), style: textTheme.labelSmall?.copyWith(color: colors.secondary, letterSpacing: 0.275)),
            ],
          ),
          const SizedBox(height: _titleToText),
          Text(text, style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
