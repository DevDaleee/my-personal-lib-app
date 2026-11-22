import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/models/monthly_stat.dart';

void main() {
  test('lê o JSON do GET /stats/monthly', () {
    final stat = MonthlyStat.fromJson({'month': '2026-11-01', 'finished_count': 2});

    expect(stat.month, DateTime(2026, 11, 1));
    expect(stat.finishedCount, 2);
  });
}
