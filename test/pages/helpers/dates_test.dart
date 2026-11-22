import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/pages/helpers/dates.dart';

void main() {
  test('monthYear: mês abreviado em pt-BR, sem ponto', () {
    expect(monthYear(DateTime(2024, 3, 10)), 'mar/2024');
    expect(monthYear(DateTime(2026, 1, 1)), 'jan/2026');
    expect(monthYear(DateTime(2026, 12, 31)), 'dez/2026');
  });
}
