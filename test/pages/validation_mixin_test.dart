import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/pages/helpers/validation_mixin.dart';

class _Validator with ValidationMixin {}

void main() {
  final validator = _Validator();

  group('isEmailValid', () {
    for (final email in ['leitor@caderno.com.br', 'a.b-c+tag@x.io', '  leitor@caderno.com  ']) {
      test('aceita "$email"', () => expect(validator.isEmailValid(email), isNull));
    }
    for (final email in ['', 'leitor', 'leitor@', '@caderno.com', 'leitor@caderno', 'leitor caderno@x.com', 'leitor@caderno.c']) {
      test('recusa "$email"', () => expect(validator.isEmailValid(email), 'Informe um e-mail válido'));
    }
    test('recusa null', () => expect(validator.isEmailValid(null), isNotNull));
  });

  group('isPasswordValid', () {
    test('aceita senha forte entre 8 e 72', () => expect(validator.isPasswordValid('Leitura#2026'), isNull));
    test('recusa menos de 8', () => expect(validator.isPasswordValid('Ab#1'), 'A senha deve ter pelo menos 8 caracteres'));
    test('recusa mais de 72', () {
      final longa = 'Aa#1${'x' * 69}'; // 73 caracteres
      expect(validator.isPasswordValid(longa), 'A senha deve ter no máximo 72 caracteres');
    });
    test('aceita exatamente 72', () => expect(validator.isPasswordValid('Aa#1${'x' * 68}'), isNull));
    test('recusa null sem quebrar', () => expect(validator.isPasswordValid(null), isNotNull));
  });

  group('isNotEmpty', () {
    test('recusa vazio, só espaços e null', () {
      expect(validator.isNotEmpty(''), isNotNull);
      expect(validator.isNotEmpty('   '), isNotNull);
      expect(validator.isNotEmpty(null), isNotNull);
    });
    test('usa a mensagem passada', () => expect(validator.isNotEmpty('', 'Informe sua senha'), 'Informe sua senha'));
    test('aceita texto', () => expect(validator.isNotEmpty('abc'), isNull));
  });
}
