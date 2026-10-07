import 'package:flutter/material.dart';
class ProgressCard extends StatelessWidget {
 final int completed,total; const ProgressCard({super.key,required this.completed,required this.total});
 @override Widget build(BuildContext c){final p=total==0?0:completed/total;return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${(p*100).round()}% הושלם',style:Theme.of(c).textTheme.titleLarge),const SizedBox(height:10),LinearProgressIndicator(value:p,minHeight:10,borderRadius:BorderRadius.circular(8)),const SizedBox(height:8),Text('$completed מתוך $total פרקים')]))) ;}
}