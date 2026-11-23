import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';

/// Cabeçalho das telas de entrada: logo, "CADERNO DE LEITURA",
/// "Biblioteca Pessoal" e um subtítulo, seguido do título da seção
/// (ex.: "Acessar estante") com a sua linha de apoio.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle, required this.sectionTitle, required this.sectionSubtitle});

  // Medidas do Figma (px).
  static const double _logo = 56;
  static const double _logoToOverline = 16;
  static const double _overlineToTitle = 8;
  static const double _titleToSubtitle = 6;
  static const double _headerToSection = 32;
  static const double _sectionTitleToSubtitle = 4;

  final String subtitle;
  final String sectionTitle;
  final String sectionSubtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final supportStyle = textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset("assets/logo/logo.svg", height: _logo, width: _logo),
        const SizedBox(height: _logoToOverline),
        Text("CADERNO DE LEITURA", style: textTheme.labelSmall?.copyWith(color: colors.secondary)),
        const SizedBox(height: _overlineToTitle),
        Text("Biblioteca Pessoal", style: textTheme.headlineMedium),
        const SizedBox(height: _titleToSubtitle),
        Text(subtitle, style: supportStyle),
        const SizedBox(height: _headerToSection),
        Text(sectionTitle, style: textTheme.titleLarge),
        const SizedBox(height: _sectionTitleToSubtitle),
        Text(sectionSubtitle, style: supportStyle),
      ],
    );
  }
}
