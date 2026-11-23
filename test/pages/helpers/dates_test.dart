import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/pages/helpers/dates.dart';

void main() {
  test('monthYear: mês abreviado em pt-BR, sem ponto', () {
    expect(monthYear(DateTime(2024, 3, 10)), 'mar/2024');
    expect(monthYear(DateTime(2026, 1, 1)), 'jan/2026');
    expect(monthYear(DateTime(2026, 12, 31)), 'dez/2026');
  });

  test('monthShortYear: "jun/26"', () {
    expect(monthShortYear(DateTime(2026, 6)), 'jun/26');
    expect(monthShortYear(DateTime(2025, 12)), 'dez/25');
  });

  test('dayMonth: "13/11" com dois dígitos', () {
    expect(dayMonth(DateTime(2026, 11, 13)), '13/11');
    expect(dayMonth(DateTime(2026, 3, 5)), '05/03');
  });

  test('dayMonthLong: "19 de novembro"', () {
    expect(dayMonthLong(DateTime(2026, 11, 19)), '19 de novembro');
    expect(dayMonthLong(DateTime(2026, 3, 1)), '1 de março');
  });

  test('fullDate: "03/11/2026" com dois dígitos', () {
    expect(fullDate(DateTime(2026, 11, 3)), '03/11/2026');
    expect(fullDate(DateTime(2026, 1, 25)), '25/01/2026');
  });
}
