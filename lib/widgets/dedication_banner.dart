import 'package:flutter/material.dart';
class DedicationBanner extends StatelessWidget {
 final String text; const DedicationBanner({super.key,required this.text});
 @override Widget build(BuildContext c)=>Container(width:double.infinity,margin:const EdgeInsets.fromLTRB(12,10,12,6),padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),decoration:BoxDecoration(border:Border.all(color:Theme.of(c).colorScheme.secondary.withOpacity(.45)),borderRadius:BorderRadius.circular(12)),child:Text(text,textAlign:TextAlign.center,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w600,height:1.35));
}