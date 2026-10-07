String hebrewNumber(int n) {
  if (n <= 0) return '';
  const units=['','א','ב','ג','ד','ה','ו','ז','ח','ט'];
  const tens=['','י','כ','ל','מ','נ','ס','ע','פ','צ'];
  const hundreds=['','ק','ר','ש','ת'];
  var x=n; var out='';
  while(x>=400){out+='ת'; x-=400;}
  if(x>=100){final h=x~/100; out+=hundreds[h]; x%=100;}
  if(x==15){out+='טו'; x=0;} else if(x==16){out+='טז'; x=0;}
  if(x>=10){out+=tens[x~/10]; x%=10;}
  if(x>0) out+=units[x];
  if(out.length==1) return out+'׳';
  return out.substring(0,out.length-1)+'״'+out.substring(out.length-1);
}
String chapterLabel(int n)=>'פרק ${hebrewNumber(n)}';