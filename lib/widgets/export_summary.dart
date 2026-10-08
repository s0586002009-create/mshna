import 'package:flutter/material.dart';
import '../services/export_service.dart';

class ExportSummary extends StatelessWidget {
  final ExportSnapshot data;
  const ExportSummary({super.key, required this.data});
  static const colors=[Color(0xFF4C8B5A),Color(0xFF4B78A8),Color(0xFF7C5AA6),Color(0xFFC27B32),Color(0xFFB84B4B),Color(0xFF3B8E8E)];

  @override
  Widget build(BuildContext context)=>Directionality(
    textDirection:TextDirection.rtl,
    child:Container(
      width:900,padding:const EdgeInsets.all(30),
      decoration:BoxDecoration(
        gradient:const LinearGradient(colors:[Color(0xFFF9F1E4),Color(0xFFEAD5B8)]),
        borderRadius:BorderRadius.circular(26),border:Border.all(color:const Color(0xFF9B6A35),width:3)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const Text('משניות',textAlign:TextAlign.center,style:TextStyle(fontSize:34,fontWeight:FontWeight.w900,color:Color(0xFF5B3A23))),
        const SizedBox(height:8),Text(data.dedication,textAlign:TextAlign.center),
        const SizedBox(height:20),Wrap(alignment:WrapAlignment.center,spacing:10,runSpacing:10,children:[
          _m('נלמדו','${data.completed}',Icons.menu_book),_m('התקדמות','${data.percent}%',Icons.pie_chart),
          _m('רצף','${data.currentStreak}',Icons.local_fire_department),_m('שיא','${data.bestStreak}',Icons.emoji_events),
          _m('ממוצע',data.average.toStringAsFixed(1),Icons.speed),
        ]),
        const SizedBox(height:24),_title('לימוד לפי ימי השבוע'),const SizedBox(height:8),_week(context),
        const SizedBox(height:24),_title('התקדמות לפי סדר'),const SizedBox(height:8),
        for(var i=0;i<data.sederNames.length;i++) Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(children:[
          SizedBox(width:80,child:Text(data.sederNames[i])),Expanded(child:LinearProgressIndicator(
            minHeight:20,value:data.seders.isEmpty||data.seders.reduce((a,b)=>a>b?a:b)==0?0:data.seders[i]/data.seders.reduce((a,b)=>a>b?a:b),
            color:colors[i],backgroundColor:Colors.white70)),const SizedBox(width:8),Text('${data.seders[i]}')
        ])),
        const SizedBox(height:20),_title('תגים שנפתחו'),const SizedBox(height:8),
        Wrap(spacing:8,runSpacing:8,children:data.badges.isEmpty?[const Chip(label:Text('עדיין לא נפתחו תגים'))]:
          data.badges.map((b)=>Chip(avatar:const Icon(Icons.verified,size:18),label:Text(b))).toList()),
      ]),
    ),
  );

  Widget _m(String t,String v,IconData i)=>Container(width:140,padding:const EdgeInsets.all(12),
    decoration:BoxDecoration(color:Colors.white.withValues(alpha:.75),borderRadius:BorderRadius.circular(16),
      border:Border.all(color:const Color(0xFFB78A55))),child:Column(children:[
        Icon(i,color:const Color(0xFF7A5637)),Text(t,style:const TextStyle(fontSize:12)),
        Text(v,style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold))]));

  Widget _title(String s)=>Text(s,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w800,color:Color(0xFF5B3A23)));

  Widget _week(BuildContext c){
    const labels=['א','ב','ג','ד','ה','ו','ש']; final max=data.weekdays.fold<int>(0,(a,b)=>a>b?a:b);
    return SizedBox(height:170,child:Row(crossAxisAlignment:CrossAxisAlignment.end,mainAxisAlignment:MainAxisAlignment.spaceEvenly,
      children:[for(var i=0;i<7;i++)Column(mainAxisAlignment:MainAxisAlignment.end,children:[
        Text('${data.weekdays[i]}'),const SizedBox(height:3),Container(width:42,height:max==0?3:105*data.weekdays[i]/max,
          decoration:BoxDecoration(color:Theme.of(c).colorScheme.primary,borderRadius:BorderRadius.circular(8))),
        const SizedBox(height:3),Text(labels[i])])]));
  }
}
