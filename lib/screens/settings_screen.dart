import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/app_state.dart';
import '../services/export_service.dart';
import '../widgets/dedication_banner.dart';
import 'export_preview_screen.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;
  const SettingsScreen({super.key,required this.state});
  @override State<SettingsScreen> createState()=>_SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen>{
  late final TextEditingController dedication,reminder;
  TimeOfDay time=const TimeOfDay(hour:20,minute:0); bool enabled=false;
  @override void initState(){super.initState();
    dedication=TextEditingController(text:widget.state.dedication);
    reminder=TextEditingController(text:widget.state.reminderText);
    enabled=widget.state.settings['reminder_enabled']=='true';
    final p=(widget.state.settings['reminder_time']??'20:00').split(':');
    if(p.length==2)time=TimeOfDay(hour:int.tryParse(p[0])??20,minute:int.tryParse(p[1])??0);
  }
  @override void dispose(){dedication.dispose();reminder.dispose();super.dispose();}

  @override Widget build(BuildContext c)=>Scaffold(
    appBar:AppBar(title:const Text('הגדרות')),
    body:Directionality(textDirection:TextDirection.rtl,child:ListView(padding:const EdgeInsets.all(16),children:[
      DedicationBanner(text:dedication.text),
      TextField(controller:dedication,maxLines:3,decoration:const InputDecoration(labelText:'נוסח הקדשה',border:OutlineInputBorder())),
      const Divider(),
      ListTile(leading:const Icon(Icons.library_books_outlined),title:const Text('סדרים ומסכתות'),
        subtitle:Text('נבחרו ${widget.state.selected.length} מסכתות'),onTap:_editSelection),
      const Divider(),
      TextField(controller:reminder,maxLines:2,decoration:const InputDecoration(
        labelText:'נוסח תזכורת ({remaining} = מספר הפרקים להיום)',border:OutlineInputBorder())),
      SwitchListTile(title:const Text('תזכורת יומית'),subtitle:const Text('התראה מקומית בלבד'),value:enabled,
        onChanged:(v)=>setState(()=>enabled=v)),
      ListTile(title:const Text('שעת תזכורת'),subtitle:Text(time.format(c)),trailing:const Icon(Icons.schedule),
        onTap:enabled?()async{final p=await showTimePicker(context:c,initialTime:time);if(p!=null)setState(()=>time=p);}:null),
      const Divider(),
      ListTile(title:const Text('מצב תצוגה'),trailing:DropdownButton<ThemeMode>(
        value:widget.state.theme,items:const[
          DropdownMenuItem(value:ThemeMode.system,child:Text('לפי המערכת')),
          DropdownMenuItem(value:ThemeMode.light,child:Text('בהיר')),
          DropdownMenuItem(value:ThemeMode.dark,child:Text('כהה'))],
        onChanged:(v){if(v==null)return;widget.state.setSetting('theme_mode',v==ThemeMode.system?'system':v==ThemeMode.dark?'dark':'light');})),
      FilledButton(onPressed:_save,child:const Text('שמור')),
      OutlinedButton(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>ExportPreviewScreen(state:widget.state))),
        child:const Text('ייצוא סיכום — תמונה / PDF')),
      OutlinedButton(onPressed:_backup,child:const Text('גיבוי נתונים ל‑JSON')),
      OutlinedButton(onPressed:_import,child:const Text('שחזור מגיבוי JSON')),
      const SizedBox(height:16),
      OutlinedButton.icon(onPressed:_reset,icon:const Icon(Icons.delete_forever),label:const Text('איפוס כל הנתונים'),
        style:OutlinedButton.styleFrom(foregroundColor:Theme.of(c).colorScheme.error)),
    ])));

  Future<void> _editSelection()async{
    final chosen=Set<String>.from(widget.state.selected);
    final result=await showModalBottomSheet<Set<String>>(context:context,isScrollControlled:true,builder:(sheet)=>StatefulBuilder(
      builder:(c,set)=>Directionality(textDirection:TextDirection.rtl,child:SafeArea(child:SizedBox(
        height:MediaQuery.of(c).size.height*.88,child:Column(children:[
          const Padding(padding:EdgeInsets.all(14),child:Text('בחירת סדרים ומסכתות',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),
          const Padding(padding:EdgeInsets.symmetric(horizontal:14),child:Text('הסרה אינה מוחקת התקדמות. הוספה מחדש מחזירה אותה.')),
          Expanded(child:ListView(children:[for(final s in widget.state.data!.sedarim)ExpansionTile(
            title:Text(s.name),leading:Checkbox(value:s.tractates.every((t)=>chosen.contains(t.id)),tristate:true,
              onChanged:(v)=>set(()=>v==true?chosen.addAll(s.tractates.map((t)=>t.id)):chosen.removeAll(s.tractates.map((t)=>t.id)))),
            children:[for(final t in s.tractates)CheckboxListTile(value:chosen.contains(t.id),title:Text(t.name),
              subtitle:Text('${t.chapters} פרקים'),onChanged:(v)=>set(()=>v==true?chosen.add(t.id):chosen.remove(t.id)))] )])),
          Padding(padding:const EdgeInsets.all(10),child:FilledButton(onPressed:()=>Navigator.pop(sheet,chosen),child:const Text('שמור בחירה'))),
        ])))));
    if(result==null)return;
    final removed=widget.state.selected.difference(result).where((id)=>widget.state.completed.any((k)=>k.startsWith('${id}:'))).toList();
    if(removed.isNotEmpty&&mounted){
      final names=removed.map((id)=>widget.state.data!.tractate(id).name).join(', ');
      final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
        title:const Text('יש התקדמות במסכת'),content:Text('במסכתות ${names} יש התקדמות. ההסרה רק תסתיר אותן ולא תמחק את ההתקדמות. להמשיך?'),
        actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('ביטול')),
          FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('המשך'))]));
      if(ok!=true)return;
    }
    await widget.state.setSelectedTractates(result);
    if(mounted)setState((){});
  }

  Future<void> _save()async{
    await widget.state.setSetting('dedication_text',dedication.text.trim());
    await widget.state.setSetting('reminder_text',reminder.text.trim());
    await widget.state.setSetting('reminder_enabled',enabled.toString());
    await widget.state.setSetting('reminder_time','${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}');
    if(enabled){
      final asked=widget.state.settings['notification_permission_requested']=='true';
      if(!asked){
        final granted=await widget.state.notifications.requestNotificationPermissionOnce();
        await widget.state.setSetting('notification_permission_requested','true');
        if(!granted){if(mounted)await _denied();return;}
      }else if(!await widget.state.notifications.notificationsEnabled()){if(mounted)await _denied();return;}
      await widget.state.notifications.scheduleDaily(hour:time.hour,minute:time.minute,
        body:reminder.text.replaceAll('{remaining}',widget.state.pace().remaining.toString()));
    }else{await widget.state.notifications.cancel();}
    if(mounted)Navigator.pop(context);
  }

  Future<void> _denied()async{
    if(!mounted)return;
    await showDialog<void>(context:context,builder:(c)=>AlertDialog(
      title:const Text('ההתראות כבויות'),content:const Text('כדי לקבל תזכורות, יש לאפשר התראות עבור האפליקציה בהגדרות המכשיר.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('אחר כך')),
        FilledButton(onPressed:()async{Navigator.pop(c);await AppSettings.openAppSettings(type:AppSettingsType.notification);},
          child:const Text('פתח הגדרות'))]));
  }

  Future<void> _backup()async{
    final f=File('${(await getApplicationDocumentsDirectory()).path}/mishnah_backup.json');
    await f.writeAsString(jsonEncode(await widget.state.database.exportAll()));await ExportService().share(f);
  }

  Future<void> _import()async{
    final r=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['json']);final p=r?.files.single.path;if(p==null)return;
    try{await widget.state.database.importAll(jsonDecode(await File(p).readAsString()) as Map<String,dynamic>);await widget.state.init();
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('השחזור הושלם')));
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('קובץ הגיבוי אינו תקין: ${e}')));}
  }

  Future<void> _reset()async{
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('איפוס כל הנתונים'),content:const Text('האם אתה בטוח? הפעולה תמחק את כל ההתקדמות וההגדרות.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('ביטול')),
        FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('אפס הכל'))]));
    if(ok!=true)return;await widget.state.resetAllData();if(!mounted)return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(_)=>OnboardingScreen(state:widget.state)),(_)=>false);
  }
}
