import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/dedication_banner.dart';
class StatsScreen extends StatelessWidget{
 final AppState state; const StatsScreen({super.key,required this.state});
 @override Widget build(BuildContext context){
   final values=state.weekly();
   final maxValue=values.fold<int>(0,(a,b)=>a>b?a:b);
   return Scaffold(
     appBar:AppBar(title:const Text('סטטיסטיקות')),
     body:Directionality(textDirection:TextDirection.rtl,child:ListView(padding:const EdgeInsets.all(12),children:[
       DedicationBanner(text:state.dedication),
       Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[
         const Text('פרקים שנלמדו לפי ימי השבוע'),const SizedBox(height:12),
         SizedBox(height:300,child:BarChart(BarChartData(
           maxY:(maxValue+2).toDouble(),
           barGroups:[for(var i=0;i<7;i++)BarChartGroupData(x:i,barRods:[BarChartRodData(toY:values[i].toDouble(),width:18)])],
           titlesData:FlTitlesData(
             bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,getTitlesWidget:(value,meta){const labels=['א','ב','ג','ד','ה','ו','ש'];return Text(labels[value.toInt()]);})),
             leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:true)),
             topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
             rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
           ),
         ))),
       ]))),
     ]),
   );
 }
}