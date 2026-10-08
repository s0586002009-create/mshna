#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
m=Path("android/app/src/main/AndroidManifest.xml")
s=m.read_text()
p='    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>'
if p not in s:s=s.replace('<manifest xmlns:android="http://schemas.android.com/apk/res/android">','<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n'+p)
s=s.replace('android:label="mishnah_tracker"','android:label="משניות"')
if 'android:roundIcon=' not in s:
    s=s.replace('android:icon="@mipmap/ic_launcher"', 'android:icon="@mipmap/ic_launcher" android:roundIcon="@mipmap/ic_launcher"')
s=s.replace('android:label="@string/app_name"','android:label="@string/app_name"')
m.write_text(s)
v=Path("android/app/src/main/res/values/strings.xml")
v.write_text('<?xml version="1.0" encoding="utf-8"?>\n<resources><string name="app_name">משניות</string></resources>\n')
p=Path("ios/Runner/Info.plist")
if p.exists():
 s=p.read_text().replace('<string>mishnah_tracker</string>','<string>משניות</string>')
 p.write_text(s)
PY
