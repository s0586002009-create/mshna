import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/calculations.dart';
import '../widgets/dedication_banner.dart';
import '../widgets/progress_card.dart';
import '../widgets/chapter_tile.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'badges_screen.dart';
class HomeScreen extends StatelessWidget{final AppState state;const HomeScreen({super.key,required this.state});
@override Widget build(BuildContext c){final d=state.data!;final pace=state.pace();final start=DateTime.tryParse(state.settings['start_date']??'')??DateTime.now();final expected=expectedByToday(total:state.totalSelected,start:start,today:DateTime.now(),target:state.target);final gap=expected-state.completedCount;return Scaffold(appBar:AppBar(title:const Text('מעקב משנה'),actions:[IconButton(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>SettingsScreen(state:state))),icon:const Icon(Icons.settings)),PopupMenuButton<String>(onSelected:(x){final w=x=='stats'?StatsScreen(state:state):BadgesScreen(state:state);Navigator.push(c,MaterialPageRoute(builder:(_)=>w));},itemBuilder:(_)=>const [PopupMenuItem(value:'stats',child:Text('סטטיסטיקות')),PopupMenuItem(value:'badges',child:Text('תגים'))])]),body:Directionality(textDirection:TextDirection.rtl,child:ListView(children:[DedicationBanner(text:state.dedication),Padding(padding:const EdgeInsets.all(12),child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(pace.remaining==0?'סיימת את כל הלימוד!':(gap<=0?'אתה בקצב מצוין! נותרו ${maxInt(0,pace.requiredPerDay)} פרקים להיום':'פיגור של $gap פרקים מהיעד'),style:Theme.of(c).textTheme.titleMedium),const SizedBox(height:8),Text('רצף: ${state.streak()} ימים'),Text('קצב נדרש: ${pace.requiredPerDay} פרקים ביום')] ))),ProgressCard(completed:state.completedCount,total:state.totalSelected),for(final s in d.sedarim)_seder(c,s)]));}
Widget _seder(BuildContext c,dynamic s)=>ExpansionTile(title:Text(s.name,style:const TextStyle(fontWeight:FontWeight.bold)),children:[for(final t in s.tractates.where((t)=>state.selected.contains(t.id)))ExpansionTile(title:Text(t.name),subtitle:LinearProgressIndicator(value:state.completed.where((k)=>k.startsWith('${t.id}:')).length/t.chapters),children:[for(var i=1;i<=t.chapters;i++)ChapterTile(tractateId:t.id,chapter:i,done:state.completed.contains('${t.id}:$i'),onChanged:(v)=>state.toggle(t.id,i,v))])]);
int maxInt(int a,int b)=>a>b?a:b;
}