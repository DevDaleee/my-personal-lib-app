import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/models/user.dart';

User _user(String name) => User(id: 'u-1', email: 'a@b.com', name: name, createdAt: DateTime(2024));

void main() {
  test('lê o JSON do GET /users/me', () {
    final user = User.fromJson({'id': '3d8be433-19f8-4963-b427-61e203353630', 'email': 'ana@example.com', 'name': 'Ana', 'created_at': '2024-05-10T12:00:00Z'});

    expect(user.id, '3d8be433-19f8-4963-b427-61e203353630');
    expect(user.email, 'ana@example.com');
    expect(user.name, 'Ana');
    expect(user.createdAt, DateTime.utc(2024, 5, 10, 12));
  });

  test('iniciais: primeira e última palavra do nome', () {
    expect(_user('Clarice Lispector').initials, 'CL');
    expect(_user('joão guimarães rosa').initials, 'JR');
    expect(_user('  Ana ').initials, 'A');
    expect(_user('').initials, '');
  });
}
