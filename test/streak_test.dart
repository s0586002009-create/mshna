import 'package:flutter_test/flutter_test.dart';
import 'package:mishnah_tracker/services/calculations.dart';
void main(){test('streak uses local calendar days',(){final now=DateTime(2026,1,10,23);final dates=[DateTime(2026,1,8,8),DateTime(2026,1,9,22),DateTime(2026,1,10,7)];expect(streakFromDays(dates,now:now),3);});}