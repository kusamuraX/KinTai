import 'package:flutter/material.dart';
import 'package:teskin/workTimeTab/tabHeader.dart';
import 'package:teskin/dateInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 開始時間表示ボタン
class StTimeBtn extends StatefulWidget {
  final String timeStr;
  final String date;
  final GlobalKey<TabHeadState> titleKey;

  const StTimeBtn({Key key, this.timeStr, this.date, this.titleKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new StTimeBtnState(timeStr);
}

/// 開始時間ボタンSTATE
class StTimeBtnState extends State<StTimeBtn> {
  String _time;

  StTimeBtnState(this._time);

  TimeOfDay _getStShowTime(String timeStr) {
    if (timeStr == DateInfo.noneTime) {
      return TimeOfDay(hour: 9, minute: 0);
    } else {
      return new TimeOfDay(
          hour: int.parse(timeStr.split(":")[0]),
          minute: int.parse(timeStr.split(":")[1]));
    }
  }

  // 定時を設定
  void setFixTime() {
    setState(() {
      _time = TimeOfDay(hour: 9, minute: 0).format(context);
    });
  }

  // 表示をクリア
  void clear() {
    setState(() {
      _time = DateInfo.noneTime;
    });
  }

  // 時間を登録
  void saveTime() async {
    if (_time != DateInfo.noneTime) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('${widget.date}-st', _time);
      widget.titleKey.currentState.calc();
    }
  }

  // 入力されていなければ定時を設定
  void setFixTimeIfNotInput() async{
    if (_time == DateInfo.noneTime) {
      setState(() {
        _time = TimeOfDay(hour: 9, minute: 0).format(context);
      });
    }
  }

  void getSavedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String time = prefs.getString('${widget.date}-st');
    if (time != null && time.isNotEmpty) {
      setState(() {
        _time = time;
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
            context: context, initialTime: _getStShowTime(_time));
        if (selectTime != null) {
          setState(() {
            _time = selectTime.format(context);
          });
          saveTime();
        }
      },
      child: new Text(
        _time,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}