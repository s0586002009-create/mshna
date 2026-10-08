import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/export_service.dart';
import '../widgets/export_summary.dart';

class ExportPreviewScreen extends StatefulWidget {
  final AppState state;
  const ExportPreviewScreen({super.key,required this.state});
  @override State<ExportPreviewScreen> createState()=>_ExportPreviewScreenState();
}
class _ExportPreviewScreenState extends State<ExportPreviewScreen>{
  final key=GlobalKey(); late final ExportSnapshot data;
  @override void initState(){super.initState();data=ExportService().snapshot(widget.state);}
  @override Widget build(BuildContext c)=>Scaffold(
    appBar:AppBar(title:const Text('ייצוא סיכום')),
    body:Directionality(textDirection:TextDirection.rtl,child:Column(children:[
      const Padding(padding:EdgeInsets.all(8),child:Text('סיכום צבעוני עם נתוני הלימוד שלך. אפשר לשתף כתמונה או PDF.',textAlign:TextAlign.center)),
      Expanded(child:SingleChildScrollView(child:SingleChildScrollView(scrollDirection:Axis.horizontal,
        child:RepaintBoundary(key:key,child:ExportSummary(data:data))))),
      SafeArea(child:Padding(padding:const EdgeInsets.all(10),child:Row(children:[
        Expanded(child:FilledButton.icon(onPressed:_png,icon:const Icon(Icons.image),label:const Text('ייצוא PNG'))),
        const SizedBox(width:10),
        Expanded(child:OutlinedButton.icon(onPressed:_pdf,icon:const Icon(Icons.picture_as_pdf),label:const Text('ייצוא PDF'))),
      ]))),
    ])));
  Future<void> _png()async{await Future<void>.delayed(const Duration(milliseconds:120));await ExportService().share(await ExportService().exportWidget(key));}
  Future<void> _pdf()async{await ExportService().share(await ExportService().exportPdf(data));}
}
