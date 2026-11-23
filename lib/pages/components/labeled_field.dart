import 'package:material_ui/material_ui.dart';

/// Rótulo acima de um campo ("E-mail", "Senha"...), como no Figma:
/// o rótulo fica fora do campo, e não dentro dele como no padrão do Material.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  // Espaço entre o rótulo e o campo no Figma (px).
  static const double _labelToField = 6;

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: _labelToField),
        child,
      ],
    );
  }
}
