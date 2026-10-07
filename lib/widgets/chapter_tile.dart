import 'package:flutter/material.dart';
import '../utils/hebrew.dart';
class ChapterTile extends StatelessWidget {
 final String tractateId; final int chapter; final bool done; final ValueChanged<bool> onChanged;
 const ChapterTile({super.key,required this.tractateId,required this.chapter,required this.done,required this.onChanged});
 @override Widget build(BuildContext c)=>ListTile(dense:true,title:Text(chapterLabel(chapter)),leading:Icon(done?Icons.check_circle:Icons.radio_button_unchecked,color:done?Theme.of(c).colorScheme.primary:null),trailing:Switch(value:done,onChanged:onChanged));
}