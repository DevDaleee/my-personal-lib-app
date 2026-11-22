// Validação de conforto: algo@dominio.tld. A validação que vale é a do back-end.
// Em Dart a regex vai sem as barras e flags do JavaScript (/.../gm).
final RegExp emailRegex = RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$');

mixin ValidationMixin {
  String? isNotEmpty(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) return message ?? "Por favor, preencha esse campo";
    return null;
  }

  String? isEmailValid(String? value, [String? message]) {
    if (!emailRegex.hasMatch((value ?? '').trim())) return message ?? "Informe um e-mail válido";
    return null;
  }

  String? isPasswordValid(String? value, [String? message]) {
    value ??= '';
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    } else if (value.length > 72) {
      // Limite do back-end (bcrypt): acima disso a API responde 400.
      return 'A senha deve ter no máximo 72 caracteres';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número';
    } else if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  String? combineValidations(List<String? Function()> validators) {
    for (final func in validators) {
      final validation = func();
      if (validation != null) return validation;
    }
    return null;
  }
}
