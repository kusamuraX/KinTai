import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';

const String _calLang = 'japanese__ja@holiday.calendar.google.com';
const String _apiKey = 'AIzaSyBaAkBi0L9OVLn0_64P8vU7oFw2VSizD0M';

class DateInfo {
  var _dateKeyFmt = new DateFormat('yyyy-MM-dd');

  final saturdayColor = Colors.blueAccent.shade100;
  final sundayColor = Colors.redAccent.shade100;
  final normalColor = Colors.white;

  static final String noneTime = '--:--';

  static Map<String, String> holidayMap = {};
  static double normalWorkingHours = 0.0;

  Text getDayText(int month, int day) {
    String dayStr = (day + 1).toString() + '日 ';
    DateTime _dateTime = new DateTime(2019, month, day + 1);
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

    return new Text(dayStr);
  }

  Color getDayColor(int month, int day) {

    print('getDayColor()');

    DateTime _dateTime = new DateTime(2019, month, day + 1);
    var week = _dateTime.weekday;

    var rtnColor = normalColor;

    if (week == DateTime.saturday) {
      rtnColor = saturdayColor;
    }
    else if (week == DateTime.sunday) {
      rtnColor =  sundayColor;
    }

    if (holidayMap.containsKey(_dateKeyFmt.format(_dateTime))) {
      rtnColor =  sundayColor;
    }

    return rtnColor;
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
    items.forEach((item) {
      holidayMap.putIfAbsent(item['start']['date'], () => item['summary']);
    });

    print(holidayMap);

    setNormalWorkingHours(month);

    return true;
  }

  setNormalWorkingHours(int month){
    final lastDayOfMonth = new DateTime(2019, month + 1, 0);

    DateTime currentDay = new DateTime(2019, month, 1);
    currentDay.add(new Duration(days: 1));
    List.generate(lastDayOfMonth.day, (i) => i).forEach((i){
      var date = currentDay.add(new Duration(days: i));
      if(date.weekday != DateTime.saturday
      && date.weekday != DateTime.sunday
      && !holidayMap.containsKey(_dateKeyFmt.format(date))){
        normalWorkingHours += 8.0;
      }
    });
  }
}
