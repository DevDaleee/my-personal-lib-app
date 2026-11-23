import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_lib_app/controllers/new_book_controller.dart';
import 'package:my_personal_lib_app/pages/components/profile_button.dart';
import 'package:my_personal_lib_app/pages/helpers/toast.dart';
import 'package:my_personal_lib_app/pages/helpers/validation_mixin.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';
import 'package:toastification/toastification.dart';

/// Campos validados no app (conforto do usuário; a validação que vale é a do back-end).
enum _Field { title, author, totalPages, coverUrl }

/// Novo livro: formulário do `POST /books` (Figma, seção 4.4 do `figma.md`).
/// Do Figma, fica de fora o botão 32×32 do topo, que não tem função definida.
class NewBookPage extends StatefulWidget {
  const NewBookPage({super.key});

  @override
  State<NewBookPage> createState() => _NewBookPageState();
}

class _NewBookPageState extends State<NewBookPage> with ValidationMixin {
  final NewBookController controller = GetIt.I.get<NewBookController>();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _isbnController = TextEditingController();
  final _notesController = TextEditingController();
  final _coverUrlController = TextEditingController();

  /// Campos com erro na última validação: pintam o rótulo e mostram "Inválido".
  final _invalid = <_Field>{};

  // Medidas do Figma (px).
  static const double _maxWidth = 600;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 8, 16, 40);
  static const double _headerToForm = 24;
  static const double _betweenFields = 24;
  static const double _formToActions = 32;
  static const double _saveToCancel = 8;
  static const double _actionsToQuote = 40;
  static const double _notesHeight = 156;

  @override
  void dispose() {
    for (final c in [_titleController, _authorController, _totalPagesController, _isbnController, _notesController, _coverUrlController]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate(_Field field) {
    return switch (field) {
      _Field.title => isNotEmpty(_titleController.text, 'Informe o título'),
      _Field.author => isNotEmpty(_authorController.text, 'Informe o autor'),
      _Field.totalPages => _validateTotalPages(_totalPagesController.text),
      _Field.coverUrl => _validateCoverUrl(_coverUrlController.text),
    };
  }

  String? _validateTotalPages(String value) {
    final pages = int.tryParse(value.trim());
    if (pages == null || pages <= 0) return 'O total de páginas deve ser maior que 0';
    return null;
  }

  // Opcional; se preenchida, precisa ser um endereço http(s).
  String? _validateCoverUrl(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final valid = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    return valid ? null : 'Informe um endereço que comece com http:// ou https://';
  }

  /// Ao digitar num campo com erro, tira o "Inválido" assim que ele fica certo.
  void _revalidate(_Field field) {
    if (!_invalid.contains(field)) return;
    if (_validate(field) == null) setState(() => _invalid.remove(field));
  }

  /// Volta para a tela anterior; aberta direto pela URL (web), vai para a Home.
  void _close() => context.canPop() ? context.pop() : context.go('/home');

  Future<void> _save() async {
    final isValid = _formKey.currentState!.validate();
    setState(() {
      _invalid
        ..clear()
        ..addAll(_Field.values.where((field) => _validate(field) != null));
    });
    if (!isValid) return;

    final book = await controller.save(
      title: _titleController.text,
      author: _authorController.text,
      totalPages: int.parse(_totalPagesController.text.trim()),
      isbn: _isbnController.text,
      notes: _notesController.text,
      coverUrl: _coverUrlController.text,
    );
    if (!mounted) return;

    if (book == null) {
      ToastService.show(
        key: 'new-book',
        title: const Text('Não foi possível salvar'),
        description: Text(controller.error ?? 'Algo deu errado. Tente novamente.'),
        type: ToastificationType.error,
      );
      return;
    }
    ToastService.show(
      key: 'new-book',
      title: const Text('Livro adicionado'),
      description: Text('“${book.title}” está na sua estante.'),
      type: ToastificationType.success,
    );
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro De Leitura'),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: colors.primary),
        actions: const [ProfileButton(), SizedBox(width: 16)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: _padding,
              children: [
                const _Header(),
                const SizedBox(height: _headerToForm),

                _FormSection(
                  label: 'Título *',
                  required: true,
                  invalid: _invalid.contains(_Field.title),
                  child: TextFormField(
                    controller: _titleController,
                    validator: (_) => _validate(_Field.title),
                    onChanged: (_) => _revalidate(_Field.title),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    style: textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onSurface),
                    decoration: _decoration(context, invalid: _invalid.contains(_Field.title)),
                  ),
                ),
                const SizedBox(height: _betweenFields),

                _FormSection(
                  label: 'Autor *',
                  required: true,
                  invalid: _invalid.contains(_Field.author),
                  child: TextFormField(
                    controller: _authorController,
                    validator: (_) => _validate(_Field.author),
                    onChanged: (_) => _revalidate(_Field.author),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    style: textTheme.bodyLarge,
                    decoration: _decoration(context, invalid: _invalid.contains(_Field.author)),
                  ),
                ),
                const SizedBox(height: _betweenFields),

                _FormSection(
                  label: 'Total de páginas *',
                  required: true,
                  invalid: _invalid.contains(_Field.totalPages),
                  child: TextFormField(
                    controller: _totalPagesController,
                    validator: (_) => _validate(_Field.totalPages),
                    onChanged: (_) => _revalidate(_Field.totalPages),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    style: textTheme.bodyLarge,
                    decoration: _decoration(context, invalid: _invalid.contains(_Field.totalPages), suffixText: 'PÁGS'),
                  ),
                ),
                const SizedBox(height: _betweenFields),

                _FormSection(
                  label: 'ISBN',
                  child: TextFormField(
                    controller: _isbnController,
                    keyboardType: TextInputType.visiblePassword, // teclado sem autocorreção, com números e hífen
                    textInputAction: TextInputAction.next,
                    style: textTheme.bodyLarge,
                    decoration: _decoration(context, hintText: '978-65-5921-000-0'),
                  ),
                ),
                const SizedBox(height: _betweenFields),

                _RatingField(controller: controller),
                const SizedBox(height: _betweenFields),

                _FormSection(
                  label: 'Notas',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: _notesHeight,
                        child: TextFormField(
                          controller: _notesController,
                          expands: true,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          style: textTheme.bodyLarge,
                          decoration: _decoration(
                            context,
                            hintText: 'Anotações pessoais e impressões de leitura...',
                            hintStyle: textTheme.titleLarge?.copyWith(fontSize: 18, fontStyle: FontStyle.italic, color: colors.outline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Trechos marcantes, reflexões ou memórias sobre a obra.', style: textTheme.bodyMedium?.copyWith(color: colors.secondary)),
                    ],
                  ),
                ),
                const SizedBox(height: _betweenFields),

                _FormSection(
                  label: 'URL da capa',
                  invalid: _invalid.contains(_Field.coverUrl),
                  child: TextFormField(
                    controller: _coverUrlController,
                    validator: (_) => _validate(_Field.coverUrl),
                    onChanged: (_) => _revalidate(_Field.coverUrl),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    style: textTheme.bodyLarge,
                    decoration: _decoration(context, invalid: _invalid.contains(_Field.coverUrl), hintText: 'https://exemplo.com/capa.jpg'),
                  ),
                ),
                const SizedBox(height: _betweenFields),

                _OwnedCard(controller: controller),
                const SizedBox(height: _formToActions),

                Observer(
                  builder: (_) => ElevatedButton.icon(
                    onPressed: controller.isSaving ? null : _save,
                    icon: controller.isSaving
                        ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: const Text('Salvar no Caderno'),
                  ),
                ),
                const SizedBox(height: _saveToCancel),
                TextButton(
                  onPressed: _close,
                  style: TextButton.styleFrom(foregroundColor: colors.secondary),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(height: _actionsToQuote),

                const _Quote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Campo do Novo livro: cantos 2 (os outros formulários usam 4) e, com erro,
  /// fundo `errorContainer`. As bordas vêm do tema, só muda o arredondamento.
  InputDecoration _decoration(BuildContext context, {bool invalid = false, String? hintText, TextStyle? hintStyle, String? suffixText}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final inputTheme = theme.inputDecorationTheme;
    InputBorder? rounded(InputBorder? border) => border is OutlineInputBorder ? border.copyWith(borderRadius: BorderRadius.circular(2)) : border;

    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      suffixText: suffixText,
      suffixStyle: theme.textTheme.labelSmall?.copyWith(color: invalid ? colors.onErrorContainer : colors.secondary),
      fillColor: invalid ? colors.errorContainer : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: rounded(inputTheme.border),
      enabledBorder: rounded(inputTheme.enabledBorder),
      focusedBorder: rounded(inputTheme.focusedBorder),
      errorBorder: rounded(inputTheme.errorBorder),
      focusedErrorBorder: rounded(inputTheme.focusedErrorBorder),
    );
  }
}

/// "REGISTRO LITERÁRIO / Caderno pessoal de leituras e memórias".
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REGISTRO LITERÁRIO', style: textTheme.labelSmall?.copyWith(letterSpacing: 0.55, color: colors.secondary)),
        const SizedBox(height: 5),
        Text('Caderno pessoal de leituras e memórias', style: textTheme.headlineMedium?.copyWith(fontSize: 26, color: colors.primary)),
      ],
    );
  }
}

/// Rótulo à esquerda e, à direita, "Obrigatório", "Opcional" ou "Inválido".
class _FormSection extends StatelessWidget {
  const _FormSection({required this.label, required this.child, this.required = false, this.invalid = false, this.trailing});

  static const double _labelToField = 4;

  final String label;
  final Widget child;
  final bool required;
  final bool invalid;

  /// Troca o "Obrigatório"/"Opcional" (ex.: a nota mostra "Não avaliado").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final tagColor = invalid ? colors.error : colors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: textTheme.labelMedium?.copyWith(color: invalid ? colors.error : null))),
            trailing ?? Text(invalid ? 'Inválido' : (required ? 'Obrigatório' : 'Opcional'), style: textTheme.labelSmall?.copyWith(color: tagColor)),
          ],
        ),
        const SizedBox(height: _labelToField),
        child,
      ],
    );
  }
}

/// "Nota de 1 a 5": cinco estrelas e "Limpar". Sem nota = "Não avaliado".
class _RatingField extends StatelessWidget {
  const _RatingField({required this.controller});

  final NewBookController controller;

  static const double _starSize = 28;
  static const double _betweenStars = 8;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Observer(
      builder: (_) {
        final rating = controller.rating;
        return _FormSection(
          label: 'Nota de 1 a 5',
          trailing: Text(rating == null ? 'Não avaliado' : '$rating de 5', style: textTheme.labelSmall?.copyWith(color: colors.secondary)),
          child: Row(
            children: [
              for (var value = 1; value <= 5; value++) ...[
                IconButton(
                  tooltip: '$value de 5',
                  onPressed: () => controller.setRating(value),
                  icon: Icon(rating != null && value <= rating ? Icons.star : Icons.star_border, size: _starSize),
                  color: colors.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: _starSize, minHeight: 34),
                ),
                if (value < 5) const SizedBox(width: _betweenStars),
              ],
              const Spacer(),
              TextButton(
                onPressed: rating == null ? null : controller.clearRating,
                style: TextButton.styleFrom(foregroundColor: colors.secondary),
                child: const Text('Limpar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card "Tenho este livro" com o `Switch` do `owned`.
class _OwnedCard extends StatelessWidget {
  const _OwnedCard({required this.controller});

  final NewBookController controller;

  static const double _iconBox = 36;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: _iconBox,
              height: _iconBox,
              decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(smallRadius)),
              child: Icon(Icons.menu_book_outlined, size: 18, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tenho este livro', style: textTheme.titleSmall),
                  Text('Exemplar físico em meu acervo', style: textTheme.bodyMedium?.copyWith(color: colors.secondary)),
                ],
              ),
            ),
            Observer(builder: (_) => Switch(value: controller.owned, onChanged: controller.setOwned)),
          ],
        ),
      ),
    );
  }
}

/// Citação fixa do fim da tela (Figma).
class _Quote extends StatelessWidget {
  const _Quote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          '“Ler é sonhar pela mão de outrem.”',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(fontSize: 18, fontStyle: FontStyle.italic, color: colors.secondary),
        ),
        const SizedBox(height: 8),
        Text('FERNANDO PESSOA', style: textTheme.labelSmall?.copyWith(letterSpacing: 0.55, color: colors.secondary)),
      ],
    );
  }
}
