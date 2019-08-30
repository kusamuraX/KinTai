import 'package:flutter/material.dart';
import 'package:teskin/workTimeTab/tabHeader.dart';
import 'package:teskin/dateInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 終了時間表示ボタン
class EdTimeBtn extends StatefulWidget {
  final String timeStr;
  final String date;
  final GlobalKey<TabHeadState> titleKey;

  const EdTimeBtn({Key key, this.timeStr, this.date, this.titleKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new EdTimeBtnState(timeStr);
}

class EdTimeBtnState extends State<EdTimeBtn> {
  String _time;

  EdTimeBtnState(this._time);

  TimeOfDay _getEdShowTime(String timeStr) {
    if (timeStr == DateInfo.noneTime) {
      return TimeOfDay.now();
    } else {
      return new TimeOfDay(
          hour: int.parse(timeStr.split(":")[0]),
          minute: int.parse(timeStr.split(":")[1]));
    }
  }

  void setFixTime() {
    setState(() {
      _time = TimeOfDay(hour: 18, minute: 0).format(context);
    });
  }

  void clear() {
    setState(() {
      _time = DateInfo.noneTime;
    });
  }

  void saveTime() async {
    if (_time != DateInfo.noneTime) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('${widget.date}-ed', _time);
      widget.titleKey.currentState.calc();
    }
  }

  void getSavedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String time = prefs.getString('${widget.date}-ed');
    if (time != null && time.isNotEmpty) {
      setState(() {
        _time = time;
      });
    }
  }

  // 入力されていなければ定時を設定
  void setFixTimeIfNotInput() async{
    if (_time == DateInfo.noneTime) {
      setState(() {
        _time = TimeOfDay(hour: 18, minute: 0).format(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSavedTime();
  }

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      onPressed: () async {
        TimeOfDay selectTime = await showTimePicker(
            context: context, initialTime: _getEdShowTime(_time));
        if (selectTime != null) {
          setState(() {
            _time = selectTime.format(context);
            saveTime();
          });
        }
      },
      child: new Text(
        _time,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}