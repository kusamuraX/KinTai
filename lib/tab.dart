import 'package:flutter/material.dart';
import 'main.dart';
import 'dateInfo.dart';

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
    final Size mediaSize = MediaQuery.of(context).size;
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

  DayView(int month, int day)
      : _month = month,
        _day = day;

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

  String stTime = '--:--';
  String edTime = '--:--';
  DateInfo dateInfo;

  TimeOfDay _getStShowTime(String timeStr) {
    if (timeStr == MyHomePage.noneTime) {
      return TimeOfDay(hour: 9, minute: 0);
    } else {
      return new TimeOfDay(
          hour: int.parse(timeStr.split(":")[0]),
          minute: int.parse(timeStr.split(":")[1]));
    }
  }

  TimeOfDay _getEdShowTime(String timeStr) {
    if (timeStr == MyHomePage.noneTime) {
      return TimeOfDay.now();
    } else {
      return new TimeOfDay(
          hour: int.parse(timeStr.split(":")[0]),
          minute: int.parse(timeStr.split(":")[1]));
    }
  }

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
                  new FlatButton(
                    onPressed: () async {
                      TimeOfDay selectTime = await showTimePicker(
                          context: context,
                          initialTime: _getStShowTime(stTime));
                      if (selectTime != null) {
                        setState(() {
                          stTime = selectTime.format(context);
                        });
                      }
                    },
                    child: new Text(
                      stTime,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  const Text(
                    '～',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  new FlatButton(
                    onPressed: () async {
                      TimeOfDay selectTime = await showTimePicker(
                          context: context,
                          initialTime: _getEdShowTime(edTime));
                      if (selectTime != null) {
                        setState(() {
                          edTime = selectTime.format(context);
                        });
                      }
                    },
                    child: new Text(
                      edTime,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  new MaterialButton(
                    minWidth: 30.0,
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        stTime =
                            TimeOfDay(hour: 9, minute: 0).format(context);
                        edTime =
                            TimeOfDay(hour: 18, minute: 0).format(context);
                      });
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
                      setState(() {
                        stTime = MyHomePage.noneTime;
                        edTime = MyHomePage.noneTime;
                      });
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
