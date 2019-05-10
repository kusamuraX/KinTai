import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dateInfo.dart';

// タブタイトル
class TabHead extends StatefulWidget {
  final int _month;

  TabHead(int month) : _month = month;

  @override
  State<StatefulWidget> createState() => new _TabHeadState(_month);
}

class _TabHeadState extends State<TabHead> {
  int _month;

  _TabHeadState(int month) {
    _month = month;
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery
        .of(context)
        .size;
    return Container(
      width: mediaSize.width,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(_month.toString() + '月'),
          new Text('稼働時間 : ( ${MyApp.actualWorkingHours} / ${DateInfo
              .normalWorkingHours} )h'),
        ],
      ),
    );
  }
}

// 日付の１行データ
class DayView extends StatefulWidget {
  final int _month;
  final int _day;
  final dynamic _caller;

  DayView(int month, int day, dynamic caller)
      : _month = month,
        _day = day,
        _caller = caller;

  @override
  State<StatefulWidget> createState() => new _DayViewState(_month, _day);
}

class _DayViewState extends State<DayView> {

  int _month;
  int _day;

  _DayViewState(int month, int day) {
    _month = month;
    _day = day;
  }

  DateInfo dateInfo;

  final _stKey = GlobalKey<_StTimeBtnState>();
  final _edKey = GlobalKey<_EdTimeBtnState>();

  @override
  void initState() {
    super.initState();
    dateInfo = new DateInfo();
  }

  @override
  void dispose() {
    super.dispose();
    print('_DayViewState dispose $_day');
  }

  @override
  Widget build(BuildContext context) {
    print('_DayViewState build $_day');
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: new BoxDecoration(
          color: dateInfo.getDayColor(_month, _day),
          border: new Border(
              bottom: new BorderSide(color: Colors.black12, width: 1.0))),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: dateInfo.getDayText(_month, _day),
                  ),
                  Row(
                    children: [
                      new StTimeBtn(key: _stKey, timeStr: DateInfo.noneTime,),
                      const Text(
                        '～',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      new EdTimeBtn(key: _edKey, timeStr: DateInfo.noneTime,),
                    ],
                  ),
                  SpaceBox(),
                  Row(
                    children: <Widget>[
                      new MaterialButton(
                        minWidth: 30.0,
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: () {
                          widget._caller('tg $_day');
                          _stKey.currentState.setFixTime();
                          _edKey.currentState.setFixTime();
                        },
                        child: const Text("定時"),
                      ),
                      SpaceBox.width(16.0),
                      new MaterialButton(
                        minWidth: 30.0,
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text("休暇"),
                      ),
                      SpaceBox.width(16.0),
                      new MaterialButton(
                        minWidth: 30.0,
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: () {
                          _stKey.currentState.clear();
                          _edKey.currentState.clear();
                        },
                        child: const Text("クリア"),
                      ),
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }
}

// 開始時間表示ボタン
class StTimeBtn extends StatefulWidget {

  final String timeStr;

  const StTimeBtn({
    Key key,
    this.timeStr,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _StTimeBtnState(timeStr);

}

class _StTimeBtnState extends State<StTimeBtn> {

  String _time;

  _StTimeBtnState(this._time);

  TimeOfDay _getStShowTime(String timeStr) {
    if (timeStr == DateInfo.noneTime) {
      return TimeOfDay(hour: 9, minute: 0);
    } else {
      return new TimeOfDay(
          hour: int.parse(timeStr.split(":")[0]),
          minute: int.parse(timeStr.split(":")[1]));
    }
  }

  void setFixTime() {
    setState(() {
      _time = TimeOfDay(hour: 9, minute: 0).format(context);
    });
  }

  void clear() {
    setState(() {
      _time = DateInfo.noneTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      onPressed: () async {
        TimeOfDay selectTime = await showTimePicker(
            context: context,
            initialTime: _getStShowTime(_time));
        if (selectTime != null) {
          setState(() {
            _time = selectTime.format(context);
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

// 終了時間表示ボタン
class EdTimeBtn extends StatefulWidget {

  final String timeStr;
  final String day;

  const EdTimeBtn({
    Key key,
    this.timeStr,
    this.day,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _EdTimeBtnState(timeStr, day);

}

class _EdTimeBtnState extends State<EdTimeBtn> {

  String _time;
  String _day;

  _EdTimeBtnState(this._time, this._day);

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
    if(_time != DateInfo.noneTime) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(_day, _time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      onPressed: () async {
        TimeOfDay selectTime = await showTimePicker(
            context: context,
            initialTime: _getEdShowTime(_time));
        if (selectTime != null) {
          setState(() {
            _time = selectTime.format(context);
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