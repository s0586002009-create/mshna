import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'app_state.dart';

class ExportSnapshot {
  final String dedication;
  final int completed, total, percent, currentStreak, bestStreak;
  final double average;
  final List<int> weekdays, seders;
  final List<String> sederNames, badges;
  const ExportSnapshot({required this.dedication, required this.completed, required this.total,
    required this.percent, required this.currentStreak, required this.bestStreak, required this.average,
    required this.weekdays, required this.seders, required this.sederNames, required this.badges});
}

class ExportService {
  ExportSnapshot snapshot(AppState s) => ExportSnapshot(
    dedication: s.dedication, completed: s.completedCount, total: s.totalSelected,
    percent: s.totalSelected == 0 ? 0 : (s.completedCount * 100 / s.totalSelected).round(),
    currentStreak: s.streak(), bestStreak: s.bestStreak(), average: s.averageForRange(StatsRange.all),
    weekdays: s.weekdayCounts(StatsRange.all), seders: s.sederProgress(),
    sederNames: s.data!.sedarim.map((x) => x.name).toList(), badges: s.badges.map(_badgeName(s)).toList());

  String Function(String) _badgeName(AppState s) => (id) {
    if (id == 'streak7') return '7 ימי רצף';
    if (id == 'weekly_goal') return 'יעד שבועי';
    if (id.startsWith('tractate_')) return 'סיום ${s.data!.tractate(id.substring(10)).name}';
    return id;
  };

  Future<File> exportPdf(ExportSnapshot d) async {
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
    final doc = pw.Document();
    final colors = [0xFF4C8B5A,0xFF4B78A8,0xFF7C5AA6,0xFFC27B32,0xFFB84B4B,0xFF3B8E8E];
    doc.addPage(pw.MultiPage(
      theme: pw.ThemeData.withFont(base: font),
      pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(24)),
      build: (_) => [
        pw.Container(padding: const pw.EdgeInsets.all(18),
          decoration: pw.BoxDecoration(color: const pw.PdfColor.fromInt(0xFFF2E1C7), borderRadius: pw.BorderRadius.circular(16)),
          child: pw.Column(children: [
            pw.Text('משניות', style: pw.TextStyle(font: font, fontSize: 28, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text(d.dedication, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font, fontSize: 11)),
          ])),
        pw.SizedBox(height: 12),
        pw.Wrap(spacing: 6, runSpacing: 6, children: [
          _metric(font,'נלמדו','${d.completed}'), _metric(font,'התקדמות','${d.percent}%'),
          _metric(font,'רצף','${d.currentStreak}'), _metric(font,'שיא','${d.bestStreak}'),
          _metric(font,'ממוצע',d.average.toStringAsFixed(1)),
        ]),
        pw.SizedBox(height: 14),
        pw.Text('לימוד לפי ימי השבוע', style: pw.TextStyle(font: font, fontSize: 15, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        _weekday(font,d.weekdays),
        pw.SizedBox(height: 12),
        pw.Text('התקדמות לפי סדר', style: pw.TextStyle(font: font, fontSize: 15, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        for (var i=0;i<d.seders.length;i++) pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(children: [
            pw.SizedBox(width: 55, child: pw.Text(d.sederNames[i], style: pw.TextStyle(font: font, fontSize: 9))),
            pw.Expanded(child: pw.Container(height: 14, color: const pw.PdfColor.fromInt(0xFFE5DDD2),
              child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Container(
                width: d.seders.isEmpty || d.seders.reduce((a,b)=>a>b?a:b)==0 ? 0 : 300*d.seders[i]/d.seders.reduce((a,b)=>a>b?a:b),
                height: 14, color: pw.PdfColor.fromInt(colors[i]))))),
            pw.SizedBox(width: 5), pw.Text('${d.seders[i]}', style: pw.TextStyle(font: font, fontSize: 9)),
          ])),
        pw.SizedBox(height: 12),
        pw.Text('תגים שנפתחו', style: pw.TextStyle(font: font, fontSize: 15, fontWeight: pw.FontWeight.bold)),
        pw.Wrap(spacing: 5, runSpacing: 5, children: [
          for (final b in d.badges) pw.Container(padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(color: const pw.PdfColor.fromInt(0xFFE7C77D), borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Text(b, style: pw.TextStyle(font: font, fontSize: 9))),
        ]),
      ],
    ));
    final file = File('${(await getTemporaryDirectory()).path}/mishnah_summary.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  pw.Widget _metric(pw.Font f,String t,String v)=>pw.Container(width:90,padding:const pw.EdgeInsets.all(8),
    decoration:pw.BoxDecoration(color:const pw.PdfColor.fromInt(0xFFF8EEDC),borderRadius:pw.BorderRadius.circular(9)),
    child:pw.Column(children:[pw.Text(v,style:pw.TextStyle(font:f,fontSize:16,fontWeight:pw.FontWeight.bold)),
      pw.Text(t,style:pw.TextStyle(font:f,fontSize:8))]));

  pw.Widget _weekday(pw.Font f,List<int> v){
    final max=v.fold<int>(0,(a,b)=>a>b?a:b);
    const labels=['א','ב','ג','ד','ה','ו','ש'];
    return pw.SizedBox(height:125,child:pw.Row(
      crossAxisAlignment:pw.CrossAxisAlignment.end,mainAxisAlignment:pw.MainAxisAlignment.spaceEvenly,
      children:[for(var i=0;i<7;i++) pw.Column(mainAxisAlignment:pw.MainAxisAlignment.end,children:[
        pw.Text('${v[i]}',style:pw.TextStyle(font:f,fontSize:8)),
        pw.Container(width:24,height:max==0?2:75*v[i]/max,color:const pw.PdfColor.fromInt(0xFF7A5637)),
        pw.Text(labels[i],style:pw.TextStyle(font:f,fontSize:8)),
      ])],
    ));
  }

  Future<File> exportWidget(GlobalKey key) async {
    final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await b.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('${(await getTemporaryDirectory()).path}/mishnah_summary.png');
    await file.writeAsBytes(Uint8List.view(bytes!.buffer));
    return file;
  }

  Future<void> share(File file) => SharePlus.instance.share(
    ShareParams(files:[XFile(file.path)],text:'סיכום התקדמות בלימוד משנה'));
}
