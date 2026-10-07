import 'dart:math';
class PaceResult {
  final int remaining, daysLeft, requiredPerDay, finishDays;
  final DateTime? finishDate;
  const PaceResult({required this.remaining,required this.daysLeft,required this.requiredPerDay,required this.finishDays,required this.finishDate});
}
PaceResult calculatePace({required int total,required int completed,required DateTime today,required DateTime target,required int plannedPerDay}) {
  final remaining=max(0,total-completed);
  final t=DateTime(target.year,target.month,target.day);
  final d=DateTime(today.year,today.month,today.day);
  final daysLeft=max(0,t.difference(d).inDays+1);
  final requiredPerDay=remaining==0?0:(daysLeft<=0?remaining:((remaining+daysLeft-1)~/daysLeft));
  final safePlan=max(1,plannedPerDay);
  final finishDays=remaining==0?0:((remaining+safePlan-1)~/safePlan);
  final finishDate=remaining==0?DateTime(today.year,today.month,today.day):DateTime(today.year,today.month,today.day).add(Duration(days:finishDays-1));
  return PaceResult(remaining:remaining,daysLeft:daysLeft,requiredPerDay:requiredPerDay,finishDays:finishDays,finishDate:finishDate);
}
int expectedByToday({required int total,required DateTime start,required DateTime today,required DateTime target}) {
  final allDays=max(1,DateTime(target.year,target.month,target.day).difference(DateTime(start.year,start.month,start.day)).inDays+1);
  final elapsed=(DateTime(today.year,today.month,today.day).difference(DateTime(start.year,start.month,start.day)).inDays+1).clamp(0,allDays);
  return (total*elapsed/allDays).floor();
}
int streakFromDays(Iterable<DateTime> timestamps,{DateTime? now}) {
  final base=now??DateTime.now();
  final days=timestamps.map((d)=>DateTime(d.year,d.month,d.day)).toSet();
  var cursor=DateTime(base.year,base.month,base.day); var count=0;
  while(days.contains(cursor)){count++; cursor=cursor.subtract(const Duration(days:1));}
  return count;
}