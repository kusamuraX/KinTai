import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dateInfo.dart';

// タブタイトル
class TabHead extends StatefulWidget {
  final int month;

  const TabHead({
    Key key,
    this.month,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TabHeadState(month);
}

class TabHeadState extends State<TabHead> {
  int _month;
  double _actualWorkTime;

  TabHeadState(int month) {
    _month = month;
    _actualWorkTime = MyApp.actualWorkingHours;
  }

  calc() {
    _updateActualTime();
  }

  _updateActualTime() async {
    double hours = await new DateInfo().getActualWorkingHours(widget.month);
    setState(() {
      _actualWorkTime = hours;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateActualTime();
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    return Container(
      width: mediaSize.width,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(_month.toString() + '月'),
          new Text('稼働時間 : ( $_actualWorkTime / ${DateInfo
              .normalWorkingHours} )h'),
        ],
      ),
    );
  }
}

// 日付の１行データ
class DayView extends StatefulWidget {
  final int month;
  final int day;
  final GlobalKey<TabHeadState> titleKey;

  DayView({
    this.month,
    this.day,
    this.titleKey,
  });

  @override
  State<StatefulWidget> createState() => new _DayViewState(month, day);
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

  void saveFixTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_month-$_day-st', '09:00');
    await prefs.setString('$_month-$_day-ed', '18:00');
    widget.titleKey.currentState.calc();
  }

  void clearTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_month-$_day-st');
    await prefs.remove('$_month-$_day-ed');
    widget.titleKey.currentState.calc();
  }

  @override
  Widget build(BuildContext context) {
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
                  new StTimeBtn(
                    key: _stKey,
                    timeStr: DateInfo.noneTime,
                    date: '$_month-$_day',
                    titleKey: widget.titleKey,
                  ),
                  const Text(
                    '～',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  new EdTimeBtn(
                    key: _edKey,
                    timeStr: DateInfo.noneTime,
                    date: '$_month-$_day',
                    titleKey: widget.titleKey,
                  ),
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
                      _stKey.currentState.setFixTime();
                      _edKey.currentState.setFixTime();
                      saveFixTime();
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
                      clearTime();
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
  final String date;
  final GlobalKey<TabHeadState> titleKey;

  const StTimeBtn({Key key, this.timeStr, this.date, this.titleKey}) : super(key: key);

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

  void saveTime() async {
    if (_time != DateInfo.noneTime) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('${widget.date}-st', _time);
      widget.titleKey.currentState.calc();
    }
  }

  void getSavedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String time = prefs.getString('${widget.date}-st');
    if(time != null && time.isNotEmpty){
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

// 終了時間表示ボタン
class EdTimeBtn extends StatefulWidget {
  final String timeStr;
  final String date;
  final GlobalKey<TabHeadState> titleKey;

  const EdTimeBtn({
    Key key,
    this.timeStr,
    this.date,
    this.titleKey
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _EdTimeBtnState(timeStr);
}

class _EdTimeBtnState extends State<EdTimeBtn> {
  String _time;

  _EdTimeBtnState(this._time);

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
    if(time != null && time.isNotEmpty){
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
