import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';
import 'package:my_personal_lib_app/controllers/profile_controller.dart';
import 'package:my_personal_lib_app/models/user.dart';
import 'package:my_personal_lib_app/pages/helpers/dates.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

/// Perfil do leitor: nome, e-mail, "membro desde", três números e "Sair".
/// Do Figma, ficam de fora os itens que a API não tem (bio, meta anual,
/// lembrete, exportar, organização da estante, dados pessoais e citação).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = GetIt.I.get<ProfileController>();
  late final ReactionDisposer _disposeSessionReaction;

  // Medidas do Figma (px).
  static const double _maxWidth = 600;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 8, 16, 40);
  static const double _sectionGap = 24;

  @override
  void initState() {
    super.initState();
    // Conta apagada (404 no /users/me): a sessão já foi apagada, volta para "Entrar".
    _disposeSessionReaction = reaction((_) => controller.sessionEnded, (ended) {
      if (ended && mounted) context.go('/');
    });
    controller.load();
  }

  @override
  void dispose() {
    _disposeSessionReaction();
    super.dispose();
  }

  Future<void> _logout() async {
    await controller.logout();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do leitor')),
      body: Observer(
        builder: (context) {
          final user = controller.user;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: _padding,
                  children: [
                    if (user == null && controller.error != null)
                      _ErrorState(message: controller.error!, onRetry: controller.load)
                    else if (user == null)
                      const _LoadingState()
                    else ...[
                      _Header(user: user),
                      const SizedBox(height: _sectionGap),
                      _Metrics(finishedThisYear: controller.finishedThisYear, pagesRead: controller.pagesRead, streak: controller.streak),
                      const SizedBox(height: _sectionGap),
                      const _AccountSection(),
                    ],
                    const SizedBox(height: 12),
                    // "Sair" aparece mesmo com erro: é a saída de quem não consegue carregar.
                    _LogoutButton(onPressed: _logout),
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

/// Avatar com as iniciais, nome e "e-mail • Membro desde mar/2024".
class _Header extends StatelessWidget {
  const _Header({required this.user});

  static const double _avatarSize = 96;

  final User user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final support = textTheme.bodyMedium?.copyWith(color: colors.secondary);

    return Column(
      children: [
        Container(
          width: _avatarSize,
          height: _avatarSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(pillRadius)),
          child: Text(user.initials, style: textTheme.headlineMedium?.copyWith(fontSize: 26, letterSpacing: 2.6, color: colors.onPrimaryContainer)),
        ),
        const SizedBox(height: 16),
        Text(user.name, textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontSize: 26, letterSpacing: -0.26)),
        const SizedBox(height: 4),
        // Quebra em duas linhas se o e-mail for longo.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            Text(user.email, style: support),
            Text('•', style: support),
            Text('Membro desde ${monthYear(user.createdAt)}', style: support),
          ],
        ),
      ],
    );
  }
}

/// Os três números: lidos no ano, páginas lidas e dias seguidos.
class _Metrics extends StatelessWidget {
  const _Metrics({required this.finishedThisYear, required this.pagesRead, required this.streak});

  final int? finishedThisYear;
  final int pagesRead;
  final int? streak;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MetricCard(value: _format(finishedThisYear), label: 'LIDOS EM ${DateTime.now().year}'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(value: _format(pagesRead), label: 'PÁGINAS LIDAS'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(value: _format(streak), label: 'DIAS SEGUIDOS', icon: Icons.local_fire_department),
          ),
        ],
      ),
    );
  }

  /// Nulo (a chamada falhou) vira "–"; milhar com ponto ("4.820").
  static String _format(int? value) {
    if (value == null) return '–';
    return value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(fontSize: 26, fontWeight: FontWeight.w500, letterSpacing: -0.26, color: colors.primary),
                ),
                if (icon != null) ...[const SizedBox(width: 2), Icon(icon, size: 12, color: colors.primary)],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(letterSpacing: 0.55, color: colors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seção "CONTA": por enquanto só o atalho para as Estatísticas.
class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text('CONTA', style: textTheme.labelMedium?.copyWith(letterSpacing: 0.6, color: colors.secondary)),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: _SettingsRow(
            icon: Icons.bar_chart,
            label: 'Estatísticas detalhadas de leitura',
            // Vai para a aba Estatísticas (com a barra inferior).
            onTap: () => context.go('/stats'),
          ),
        ),
      ],
    );
  }
}

/// Linha de um card de opções: ícone num quadrado, texto e seta.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.label, required this.onTap});

  static const double _iconBox = 32;

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: _iconBox,
              height: _iconBox,
              decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(smallRadius)),
              child: Icon(icon, size: 16, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: textTheme.bodyLarge)),
            Icon(Icons.chevron_right, size: 18, color: colors.secondary),
          ],
        ),
      ),
    );
  }
}

/// "Sair da conta": card discreto com texto e ícone em vermelho.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  static const double _height = 44;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: _height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 14, color: colors.error),
              const SizedBox(width: 8),
              Text('Sair da conta', style: textTheme.titleSmall?.copyWith(color: colors.error)),
            ],
          ),
        ),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 32, color: colors.error),
          const SizedBox(height: 12),
          Text('Não foi possível carregar seu perfil', style: textTheme.titleLarge, textAlign: TextAlign.center),
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
