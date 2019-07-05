import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

const String _calLang = 'japanese__ja@holiday.calendar.google.com';
const String _apiKey = '';

class DateInfo {
  var _dateKeyFmt = new DateFormat('yyyy-MM-dd');

  final saturdayColor = Colors.blueAccent.shade100;
  final sundayColor = Colors.redAccent.shade100;
  final normalColor = Colors.white;

  static final String noneTime = '--:--';

  static Map<String, String> holidayMap = {};
  static double normalWorkingHours = 0.0;

  String getDayText(int month, int day) {
    String dayStr = '$day 日 ';
    DateTime _dateTime = new DateTime(2019, month, day);
    switch (_dateTime.weekday) {
      case DateTime.sunday:
        dayStr += '(日)';
        break;
      case DateTime.monday:
        dayStr += '(月)';
        break;
      case DateTime.tuesday:
        dayStr += '(火)';
        break;
      case DateTime.wednesday:
        dayStr += '(水)';
        break;
      case DateTime.thursday:
        dayStr += '(木)';
        break;
      case DateTime.friday:
        dayStr += '(金)';
        break;
      case DateTime.saturday:
        dayStr += '(土)';
        break;
      default:
        break;
    }

    var key = _dateKeyFmt.format(_dateTime);
    if (holidayMap.containsKey(key)) {
      dayStr += ' : ${holidayMap[key]}';
    }

    return dayStr;
  }

  int getDayColor(int month, int day) {
    DateTime _dateTime = new DateTime(2019, month, day + 1);
    var week = _dateTime.weekday;


    if (holidayMap.containsKey(_dateKeyFmt.format(_dateTime))) {
      week = DateTime.sunday;
    }

    return week;
  }

  Future<bool> getHoliday(var month) async {
    final lastDayOfMonth = new DateTime(2019, month + 1, 0);

    String monthStr =
        month.toString().length == 1 ? '0$month' : month.toString();

    var stTime = '2019-$monthStr-01T00:00:00.000Z';
    var edTime = '2019-$monthStr-${lastDayOfMonth.day}T23:59:59.000Z';

    String url =
        'https://www.googleapis.com/calendar/v3/calendars/$_calLang/events?key=$_apiKey&timeMin=$stTime&timeMax=$edTime&maxResults=30&orderBy=startTime&singleEvents=true';

    var response = await http.get(url);

    Map<String, dynamic> jsonData = json.decode(response.body);
    List<dynamic> items = jsonData['items'];
    if(items != null){
      items.forEach((item) {
        holidayMap.putIfAbsent(item['start']['date'], () => item['summary']);
      });
    }
    print(holidayMap);

    setNormalWorkingHours(month);

    return true;
  }

  setNormalWorkingHours(int month) {
    final lastDayOfMonth = new DateTime(2019, month + 1, 0);

    DateTime currentDay = new DateTime(2019, month, 1);
    currentDay.add(new Duration(days: 1));
    List.generate(lastDayOfMonth.day, (i) => i).forEach((i) {
      var date = currentDay.add(new Duration(days: i));
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday &&
          !holidayMap.containsKey(_dateKeyFmt.format(date))) {
        normalWorkingHours += 8.0;
      }
    });
  }

  Future<double> getActualWorkingHours(int month) async {
    double actualTime = 0.0;

    final lastDayOfMonth = new DateTime(2019, month + 1, 0);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime currentDay = new DateTime(2019, month, 1);
    List.generate(lastDayOfMonth.day, (i) => i).forEach((i) {
      var date = currentDay.add(new Duration(days: i));
      String stKey = '${date.month}-${date.day}-st';
      String edKey = '${date.month}-${date.day}-ed';
      String stTime = prefs.getString(stKey);
      String edTime = prefs.getString(edKey);
      if (stTime != null && edTime != null) {
        DateTime stDateTime = new DateTime(2019, month, i, int.parse(stTime.split(":")[0]), int.parse(stTime.split(":")[1]));
        DateTime edDateTime = new DateTime(2019, month, i, int.parse(edTime.split(":")[0]), int.parse(edTime.split(":")[1]));

        // 午前深夜
        actualTime += _calcAMMid(stDateTime, edDateTime, month, i);

        // 午前早出
        actualTime += _calcAMEarly(stDateTime, edDateTime, month, i);

        // 午前
        actualTime += _calcAM(stDateTime, edDateTime, month, i);

        // 午後
        actualTime += _calcPM(stDateTime, edDateTime, month, i);

        // 午後残業
        actualTime += _calcPMLate(stDateTime, edDateTime, month, i);

        // 午後深夜
      }
    });

    return actualTime;
  }

  //
  // 午前深夜 0:00 - 04:00
  //
  double _calcAMMid(DateTime stDateTime, DateTime edDateTime, int month, int day){
    double actualTime = 0.0;

    // 深夜
    DateTime midStDateTime = new DateTime(2019, month, day);
    DateTime midEdDateTime = new DateTime(2019, month, day, 4);

    // st <= 00:00 && ed >= 4:00
    if(stDateTime.compareTo(midStDateTime) <= 0
        && edDateTime.compareTo(midEdDateTime) >= 0){
      actualTime = 4.0;
    }
    // st > 00:00 && ed >= 4:00
    else if(stDateTime.isAfter(midStDateTime)
        && edDateTime.compareTo(midEdDateTime) >= 0){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(midEdDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st <= 00:00 && ed < 4:00
    else if(stDateTime.compareTo(midStDateTime) <= 0
        && edDateTime.compareTo(midEdDateTime) < 0){
      DateTime stTimeCalc = new DateTime(midStDateTime.year, midStDateTime.month, midStDateTime.day, midStDateTime.hour, midStDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st > 00:00 && ed < 4:00
    else if(stDateTime.isAfter(midStDateTime)
        && edDateTime.isBefore(midEdDateTime)){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }

    return actualTime;
  }

  //
  // 午前早出 5:00 - 09:00
  //
  double _calcAMEarly(DateTime stDateTime, DateTime edDateTime, int month, int day){
    double actualTime = 0.0;

    // 早出
    DateTime amEarlyStDateTime = new DateTime(2019, month, day, 5, 0);
    DateTime amEarlyEdDateTime = new DateTime(2019, month, day, 9, 0);

    // st <= 05:00 && ed >= 9:00
    if(stDateTime.compareTo(amEarlyStDateTime) <= 0
        && edDateTime.compareTo(amEarlyEdDateTime) >= 0){
      actualTime = 4.0;
    }
    // st > 05:00 && ed >= 9:00
    else if(stDateTime.isAfter(amEarlyStDateTime)
        && edDateTime.compareTo(amEarlyEdDateTime) >= 0){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(amEarlyEdDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st <= 00:00 && ed < 4:00
    else if(stDateTime.compareTo(amEarlyStDateTime) <= 0
        && edDateTime.compareTo(amEarlyEdDateTime) < 0){
      DateTime stTimeCalc = new DateTime(amEarlyStDateTime.year, amEarlyStDateTime.month, amEarlyStDateTime.day, amEarlyStDateTime.hour, amEarlyStDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st > 00:00 && ed < 4:00
    else if(stDateTime.isAfter(amEarlyStDateTime)
        && edDateTime.isBefore(amEarlyEdDateTime)){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }

    return actualTime;
  }


  //
  // 午前稼働 9:00 - 11:45
  //
  double _calcAM(DateTime stDateTime, DateTime edDateTime, int month, int day){
    double actualTime = 0.0;

    // 通常
    DateTime amStDateTime = new DateTime(2019, month, day, 9, 00);
    DateTime amEdDateTime = new DateTime(2019, month, day, 11, 45);

    // st <= 09:00 && ed >= 11:45
    if(stDateTime.compareTo(amStDateTime) <= 0
        && edDateTime.compareTo(amEdDateTime) >= 0){
      actualTime = 2.75;
    }
    // st > 09:00 && ed >= 11:45
    else if(stDateTime.isAfter(amStDateTime)
        && edDateTime.compareTo(amEdDateTime) >= 0){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(amEdDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st <= 09:00 && ed < 11:45
    else if(stDateTime.compareTo(amStDateTime) <= 0
        && edDateTime.compareTo(amEdDateTime) < 0){
      DateTime stTimeCalc = new DateTime(amStDateTime.year, amStDateTime.month, amStDateTime.day, amStDateTime.hour, amStDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st > 09:00 && ed < 11:45
    else if(stDateTime.isAfter(amStDateTime)
        && edDateTime.isBefore(amEdDateTime)){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }

    return actualTime;
  }

  //
  // 午後稼働 12:45 - 18:00
  //
  double _calcPM(DateTime stDateTime, DateTime edDateTime, int month, int day){
    double actualTime = 0.0;

    DateTime pmStDateTime = new DateTime(2019, month, day, 12, 45);
    DateTime pmEdDateTime = new DateTime(2019, month, day, 18, 00);

    // st <= 09:00 && ed >= 11:45
    if(stDateTime.compareTo(pmStDateTime) <= 0
        && edDateTime.compareTo(pmEdDateTime) >= 0){
      actualTime = 5.25;
    }
    // st > 09:00 && ed >= 11:45
    else if(stDateTime.isAfter(pmStDateTime)
        && edDateTime.compareTo(pmEdDateTime) >= 0){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(pmEdDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st <= 09:00 && ed < 11:45
    else if(stDateTime.compareTo(pmStDateTime) <= 0
        && edDateTime.compareTo(pmEdDateTime) < 0){
      DateTime stTimeCalc = new DateTime(pmStDateTime.year, pmStDateTime.month, pmStDateTime.day, pmStDateTime.hour, pmStDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st > 09:00 && ed < 11:45
    else if(stDateTime.isAfter(pmStDateTime)
        && edDateTime.isBefore(pmEdDateTime)){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }

    return actualTime;
  }

  //
  // 午後残業稼働 18:30 - 22:00
  //
  double _calcPMLate(DateTime stDateTime, DateTime edDateTime, int month, int day){
    double actualTime = 0.0;

    DateTime pmLateStDateTime = new DateTime(2019, month, day, 18, 30);
    DateTime pmLateEdDateTime = new DateTime(2019, month, day, 22, 00);

    // st <= 09:00 && ed >= 11:45
    if(stDateTime.compareTo(pmLateStDateTime) <= 0
        && edDateTime.compareTo(pmLateEdDateTime) >= 0){
      actualTime = 3.5;
    }
    // st > 09:00 && ed >= 11:45
    else if(stDateTime.isAfter(pmLateStDateTime)
        && edDateTime.compareTo(pmLateEdDateTime) >= 0){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(pmLateEdDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st <= 09:00 && ed < 11:45
    else if(stDateTime.compareTo(pmLateStDateTime) <= 0
        && edDateTime.compareTo(pmLateEdDateTime) < 0){
      DateTime stTimeCalc = new DateTime(pmLateStDateTime.year, pmLateStDateTime.month, pmLateStDateTime.day, pmLateStDateTime.hour, pmLateStDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }
    // st > 09:00 && ed < 11:45
    else if(stDateTime.isAfter(pmLateStDateTime)
        && edDateTime.isBefore(pmLateEdDateTime)){
      DateTime stTimeCalc = new DateTime(stDateTime.year, stDateTime.month, stDateTime.day, stDateTime.hour, stDateTime.minute);
      while(stTimeCalc.isBefore(edDateTime)){
        stTimeCalc = stTimeCalc.add(const Duration(minutes: 15));
        actualTime+=0.25;
      }
    }

    return actualTime;
  }
}
