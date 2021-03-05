class Utils {
  static int convertTime12to24(String time12h) {
    int hours = int.parse(time12h.replaceAll(RegExp(r'[^0-9]'),''));
    String modifier = time12h.replaceAll(hours.toString(), '');
    if (hours == 12) {
      hours = 0;
    }
    if (modifier == 'pm') {
      hours = hours + 12;
    }
    return hours;
  }  
}