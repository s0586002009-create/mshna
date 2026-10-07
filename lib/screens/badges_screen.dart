import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/dedication_banner.dart';
class BadgesScreen extends StatelessWidget{
 final AppState state; const BadgesScreen({super.key,required this.state});
 @override Widget build(BuildContext context)=>Scaffold(
   appBar:AppBar(title:const Text('תגים')),
   body:Directionality(textDirection:TextDirection.rtl,child:ListView(padding:const EdgeInsets.all(12),children:[
     DedicationBanner(text:state.dedication),
     _badge('streak7','7 ימי רצף','לימוד לפחות פעם אחת במשך 7 ימים רצופים'),
     _badge('weekly_goal','עמידה ביעד שבועי','לפחות 7 סימונים בשבוע'),
     for(final id in state.badges.where((x)=>x.startsWith('tractate_')))
       ListTile(leading:const Icon(Icons.menu_book),title:Text('סיום מסכת: ${id.substring(10)}'),trailing:const Icon(Icons.verified)),
   ]));
 Widget _badge(String id,String title,String subtitle){final earned=state.badges.contains(id);return ListTile(leading:Icon(earned?Icons.workspace_premium:Icons.lock),title:Text(title),subtitle:Text(subtitle),trailing:Text(earned?'נפתח':'נעול'));}
}