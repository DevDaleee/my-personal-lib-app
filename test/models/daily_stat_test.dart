import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/models/daily_stat.dart';

void main() {
  test('lê o JSON do GET /stats/daily', () {
    final stat = DailyStat.fromJson({'day': '2026-11-21', 'pages_read': 41, 'updates': 1});

    expect(stat.day, DateTime(2026, 11, 21));
    expect(stat.pagesRead, 41);
    expect(stat.updates, 1);
  });
}
