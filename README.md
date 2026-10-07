# מעקב משנה — Mishnah Tracker

אפליקציית Flutter אישית למעקב לימוד משנה, בעברית וב־RTL, עם עבודה מקומית בלבד.

## מה כלול
- בחירת סדרים ומסכתות מתוך assets/data/mishnah.json.
- מחשבון קצב לפי תאריך יעד ומספר פרקים ביום.
- סימון פרקים, אחוזי התקדמות ורצף יומי.
- תזכורת מקומית יומית הניתנת לעריכה.
- סטטיסטיקת לימוד לפי ימי השבוע.
- תגים מקומיים.
- ייצוא PDF עם הקדשה ופונט עברי מוטמע.
- גיבוי ושחזור JSON מקומי.
- מצב בהיר/כהה.
- ללא הרשאת INTERNET וללא שרת, חשבון, אנליטיקס או ענן.

## בנייה
flutter pub get
dart run flutter_launcher_icons
flutter analyze
flutter test
flutter build apk --release

## GitHub Actions
בכל push ל-main ה-workflow ב-.github/workflows/build.yml מפעיל בדיקות ובונה APK Release ומעלה אותו כ-Artifact בשם mishnah-tracker-release-apk.

## נתוני המשנה
הסכומים אינם מקודדים בקוד אלא מחושבים מתוך JSON. אבות מוגדר כ-6 פרקים; כדי לשנות ל-5 יש לשנות רק את chapters: 6 של avot ב-JSON.

## חתימה
ה-APK של CI הוא Release build אך אינו חתום במפתח חנות אישי. לפרסום ב-Google Play יש להוסיף keystore ו-Secrets ל-GitHub ולהגדיר signing ב-Gradle.