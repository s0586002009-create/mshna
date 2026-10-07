import 'dart:convert';
import 'package:flutter/services.dart';
class Tractate {
  final String id; final String name; final int chapters;
  const Tractate({required this.id,required this.name,required this.chapters});
  factory Tractate.fromJson(Map<String,dynamic> j)=>Tractate(id:j['id'],name:j['name'],chapters:j['chapters']);
}
class Seder {
  final String id; final String name; final List<Tractate> tractates;
  const Seder({required this.id,required this.name,required this.tractates});
  factory Seder.fromJson(Map<String,dynamic> j)=>Seder(id:j['id'],name:j['name'],tractates:(j['tractates'] as List).map((e)=>Tractate.fromJson(e)).toList());
}
class MishnahData {
  final List<Seder> sedarim;
  const MishnahData(this.sedarim);
  int get totalChapters=>sedarim.fold(0,(a,s)=>a+s.tractates.fold(0,(b,t)=>b+t.chapters));
  Tractate tractate(String id)=>sedarim.expand((s)=>s.tractates).firstWhere((t)=>t.id==id);
  static Future<MishnahData> load() async {
    final raw=await rootBundle.loadString('assets/data/mishnah.json');
    final map=jsonDecode(raw) as Map<String,dynamic>;
    return MishnahData((map['sedarim'] as List).map((e)=>Seder.fromJson(e)).toList());
  }
}