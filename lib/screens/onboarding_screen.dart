import 'package:flutter/material.dart';
import '../models/mishnah.dart';
import '../services/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  final AppState state;
  const OnboardingScreen({super.key, required this.state});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  final ids = <String>{};
  DateTime target = DateTime.now().add(const Duration(days: 90));
  final per = TextEditingController(text: '3');
  @override void dispose(){per.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final data=widget.state.data!;
    return Scaffold(
      appBar: AppBar(title: Text(step==0?'בחירת מסכתות':step==1?'תאריך יעד':'קצב לימוד')),
      body: Directionality(textDirection:TextDirection.rtl,child:Column(children:[
        Expanded(child:step==0?_tree(data):step==1?_date(context):_pace(context)),
        Padding(padding:const EdgeInsets.all(16),child:Row(children:[
          if(step>0) ...[Expanded(child:OutlinedButton(onPressed:()=>setState(()=>step--),child:const Text('חזרה'))),const SizedBox(width:10)],
          Expanded(child:FilledButton(onPressed:_next,child:Text(step==2?'סיום':'המשך'))),
        ])),
      ])),
    );
  }
  Widget _tree(MishnahData data)=>ListView(children:[
    for(final seder in data.sedarim) ExpansionTile(
      title:Text(seder.name,style:const TextStyle(fontWeight:FontWeight.bold)),
      leading:Checkbox(
        value:seder.tractates.every((t)=>ids.contains(t.id)),
        onChanged:(value)=>setState((){
          for(final t in seder.tractates){if(value==true){ids.add(t.id);}else{ids.remove(t.id);}}
        }),
      ),
      children:[for(final tractate in seder.tractates) CheckboxListTile(
        value:ids.contains(tractate.id),
        onChanged:(value)=>setState(()=>value==true?ids.add(tractate.id):ids.remove(tractate.id)),
        title:Text(tractate.name),
        subtitle:Text('${tractate.chapters} פרקים'),
      )],
    ),
  ]);
  Widget _date(BuildContext context)=>Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
    const Text('בחר תאריך יעד לסיום'),const SizedBox(height:12),
    FilledButton.icon(
      onPressed:()async{
        final picked=await showDatePicker(context:context,firstDate:DateTime.now(),lastDate:DateTime.now().add(const Duration(days:3650)),initialDate:target);
        if(picked!=null)setState(()=>target=picked);
      },
      icon:const Icon(Icons.calendar_month),
      label:Text('${target.day}/${target.month}/${target.year}'),
    ),
  ]));
  Widget _pace(BuildContext context){
    final total=ids.fold<int>(0,(sum,id)=>sum+widget.state.data!.tractate(id).chapters);
    final planned=int.tryParse(per.text)??0;
    final days=target.difference(DateTime.now()).inDays+1;
    final required=days<=0?total:(total+days-1)~/days;
    final finishDays=planned<=0?0:(total+planned-1)~/planned;
    final finish=DateTime.now().add(Duration(days:finishDays==0?0:finishDays-1));
    return Padding(padding:const EdgeInsets.all(20),child:Column(children:[
      Text('סה״כ $total פרקים נבחרו'),
      TextField(controller:per,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'כמה פרקים ביום?',border:OutlineInputBorder()),onChanged:(_)=>setState((){})),
      const SizedBox(height:20),
      Text(planned>=required?'בקצב של $planned פרקים ביום, תסיים בתאריך ${finish.day}/${finish.month}/${finish.year}':'כדי לסיים בתאריך היעד, עליך ללמוד $required פרקים ביום',textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleMedium),
    ]));
  }
  void _next(){
    if(step==0&&ids.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('יש לבחור לפחות מסכת אחת')));return;}
    if(step<2){setState(()=>step++);}else{final planned=int.tryParse(per.text)??1;widget.state.finishOnboarding(ids:ids,targetDate:target,perDay:planned.clamp(1,999));}
  }
}