import 'package:flutter_test/flutter_test.dart';
import 'package:mishnah_tracker/services/calculations.dart';

void main() {
  test('streak uses local calendar days', () {
    expect(streakFromDays([DateTime(2026,10,8),DateTime(2026,10,7),DateTime(2026,10,6)],now:DateTime(2026,10,8)),3);
  });
  test('pace formulas', () {
    final r=calculatePace(total:100,completed:10,today:DateTime(2026,10,1),target:DateTime(2026,10,10),plannedPerDay:3);
    expect(r.remaining,90); expect(r.requiredPerDay,9); expect(r.finishDays,30);
  });
  test('past target has zero days', () {
    final r=calculatePace(total:10,completed:2,today:DateTime(2026,10,8),target:DateTime(2026,10,1),plannedPerDay:2);
    expect(r.daysLeft,0); expect(r.requiredPerDay,8);
  });
  test('weekday index is Sunday first', () {
    expect(DateTime(2026,10,4).weekday%7,0); expect(DateTime(2026,10,5).weekday%7,1);
  });
  test('seven consecutive days produce seven-day streak', () {
    expect(streakFromDays([DateTime(2026,10,8),DateTime(2026,10,7),DateTime(2026,10,6),DateTime(2026,10,5),DateTime(2026,10,4),DateTime(2026,10,3),DateTime(2026,10,2)],now:DateTime(2026,10,8)),7);
  });
}
