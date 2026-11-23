import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

/// Botão redondo 32×32 da AppBar que abre o Perfil
/// (Figma: `primary`, cantos 12, ícone claro).
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  static const double _size = 32;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: 'Perfil',
      onPressed: () => context.push('/profile'),
      icon: const Icon(Icons.person_outline, size: 14),
      style: IconButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        fixedSize: const Size(_size, _size),
        minimumSize: const Size(_size, _size),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(pillRadius)),
      ),
    );
  }
}
