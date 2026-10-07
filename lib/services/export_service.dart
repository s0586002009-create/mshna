import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
class ExportService{
 Future<File> exportPdf({required String dedication,required String title,required String summary}) async{
   final data=await rootBundle.load('assets/fonts/DejaVuSans.ttf');
   final font=pw.Font.ttf(data);final doc=pw.Document();
   doc.addPage(pw.Page(theme:pw.ThemeData.withFont(base:font),build:(_)=>pw.Directionality(
     textDirection:pw.TextDirection.rtl,
     child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.stretch,children:[
       pw.Text(dedication,textAlign:pw.TextAlign.center,style:pw.TextStyle(font:font,fontSize:16)),
       pw.SizedBox(height:24),
       pw.Text(title,textAlign:pw.TextAlign.center,style:pw.TextStyle(font:font,fontSize:22)),
       pw.SizedBox(height:18),
       pw.Text(summary,style:pw.TextStyle(font:font,fontSize:15)),
     ])));
   final dir=await getTemporaryDirectory();final file=File('${dir.path}/mishnah_progress.pdf');
   await file.writeAsBytes(await doc.save());return file;
 }
 Future<File> exportWidget(GlobalKey key) async{
   final boundary=key.currentContext!.findRenderObject() as RenderRepaintBoundary;
   final image=await boundary.toImage(pixelRatio:3);
   final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
   final dir=await getTemporaryDirectory();final file=File('${dir.path}/mishnah_progress.png');
   await file.writeAsBytes(Uint8List.view(bytes!.buffer));return file;
 }
 Future<void> share(File file)=>SharePlus.instance.share(ShareParams(files:[XFile(file.path)],text:'סיכום התקדמות בלימוד משנה'));
}