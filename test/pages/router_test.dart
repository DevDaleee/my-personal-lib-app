import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/pages/router.dart';
import 'package:my_personal_lib_app/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('authGuard', () {
    test('sem nada salvo: rota protegida volta para o login', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await authGuard('/home'), '/');
    });

    test('só com o token (sem entityId): volta para o login', () async {
      SharedPreferences.setMockInitialValues({tokenKey: 'jwt.abc'});
      expect(await authGuard('/home'), '/');
    });

    test('só com o entityId (sem token): volta para o login', () async {
      SharedPreferences.setMockInitialValues({entityId: 'u-1'});
      expect(await authGuard('/home'), '/');
    });

    test('valores vazios contam como sem sessão', () async {
      SharedPreferences.setMockInitialValues({tokenKey: '', entityId: ''});
      expect(await authGuard('/home'), '/');
    });

    test('com token e entityId: segue para a rota', () async {
      SharedPreferences.setMockInitialValues({tokenKey: 'jwt.abc', entityId: 'u-1'});
      expect(await authGuard('/home'), isNull);
    });

    test('login e cadastro abrem sem sessão', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await authGuard('/'), isNull);
      expect(await authGuard('/register'), isNull);
    });
  });
}
