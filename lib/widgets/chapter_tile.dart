import 'package:flutter/material.dart';
import '../utils/hebrew.dart';

class ChapterTile extends StatelessWidget {
  final String tractateId;
  final int chapter;
  final bool done;
  final ValueChanged<bool> onChanged;
  const ChapterTile({super.key, required this.tractateId, required this.chapter, required this.done, required this.onChanged});

  @override
  Widget build(BuildContext context) => CheckboxListTile(
        dense: true,
        value: done,
        onChanged: (value) => onChanged(value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(chapterLabel(chapter)),
        secondary: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? Theme.of(context).colorScheme.primary : null),
      );
}
