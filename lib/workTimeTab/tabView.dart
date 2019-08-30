import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teskin/util.dart';
import 'package:teskin/dateInfo.dart';
import 'package:teskin/workTimeTab/tabHeader.dart';
import 'package:teskin/workTimeTab/subWidget/stTimeBtn.dart';
import 'package:teskin/workTimeTab/subWidget/edTimeBtn.dart';

/// タブビュー
/// 日付の１行データ
class DayView extends StatefulWidget {
  final int month;
  final int day;
  final GlobalKey<TabHeadState> titleKey;
  final GlobalKey lineSizeGetKey;
  final saturdayColor = Colors.blueAccent.shade100;
  final sundayColor = Colors.redAccent.shade100;
  final normalColor = Colors.white;
  final stKey = GlobalKey<StTimeBtnState>();
  final edKey = GlobalKey<EdTimeBtnState>();

  DayView({Key key, this.month, this.day, this.titleKey, this.lineSizeGetKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new DayViewState(month, day);



}

class DayViewState extends State<DayView> {
  int _month;
  int _day;

  DayViewState(int month, int day) {
    _month = month;
    _day = day;
  }

  DateInfo dateInfo;
  String _dayText;
  String _dayTextOrg;
  Color _backGroundColor;
  int _dayOfWeek;


  @override
  void initState() {
    super.initState();
    dateInfo = new DateInfo();
    // 日の文字列
    _dayTextOrg = dateInfo.getDayText(_month, _day);
    _dayText = _dayTextOrg;

    // 日の背景色
    _dayOfWeek = dateInfo.getDayColor(_month, _day);

    if (_dayOfWeek == DateTime.saturday) {
      _backGroundColor = widget.saturdayColor;
    } else if (_dayOfWeek == DateTime.sunday) {
      _backGroundColor = widget.sundayColor;
    }

    // 休暇のチェック
    getSavedHoliday(_month, _day);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getSavedHoliday(int month, int day) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String exKey = '$month-$day-ex';
    String _exStr = prefs.getString(exKey);
    if (_exStr != null && _exStr.isNotEmpty) {
      setState(() {
        _dayText += ' $_exStr';
        _backGroundColor = Colors.deepOrangeAccent;
      });
    }
  }

  // 休暇登録
  void saveHoliday(var holidayStr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_month-$_day-ex', holidayStr);
  }

  // 定時で登録
  void saveFixTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_month-$_day-st', '09:00');
    await prefs.setString('$_month-$_day-ed', '18:00');
    await prefs.remove('$_month-$_day-ex');
    widget.titleKey.currentState.calc();
  }

  // 登録されていなければ定時で登録
  // ただし平日のみ
  void saveFixTimeIfNotSaved() async {
    if (_dayOfWeek != DateTime.saturday && _dayOfWeek != DateTime.sunday) {
      widget.stKey.currentState.setFixTimeIfNotInput();
      widget.edKey.currentState.setFixTimeIfNotInput();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool suc = await prefs.setString('$_month-$_day-st', '09:00');
      print('save $suc');
      await prefs.setString('$_month-$_day-ed', '18:00');
      widget.titleKey.currentState.calc();
    }
  }

  // 時間クリア
  void clearTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_month-$_day-st');
    await prefs.remove('$_month-$_day-ed');
    await prefs.remove('$_month-$_day-ex');
    widget.titleKey.currentState.calc();
    widget.stKey.currentState.clear();
    widget.edKey.currentState.clear();
    // 休日はクリアしない
    if (_dayOfWeek != DateTime.saturday && _dayOfWeek != DateTime.sunday) {
      setState(() {
        _dayText = '$_dayTextOrg';
        _backGroundColor = Colors.white;
      });
    }
  }

  void getHoliday() async {
    var result = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: const Text('休暇選択',
                style: TextStyle(fontSize: 34.0, color: Colors.black12)),
            children: <Widget>[
              new SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '有給休暇'),
                child: const Text('有給休暇', style: TextStyle(fontSize: 26.0)),
              ),
              new SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '代休'),
                child: const Text('代休', style: TextStyle(fontSize: 26.0)),
              ),
              new SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '特別休暇'),
                child: const Text('特別休暇', style: TextStyle(fontSize: 26.0)),
              ),
              new SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '欠勤'),
                child: const Text('欠勤', style: TextStyle(fontSize: 26.0)),
              ),
            ],
          );
        });

    setState(() {
      if (result != null) {
        _dayText = '$_dayTextOrg $result';
        _backGroundColor = Colors.deepOrangeAccent;
      } else {
        _dayText = '$_dayTextOrg';
        _backGroundColor = Colors.white;
      }
    });

    // 休暇登録
    saveHoliday(result);
  }

  List<Widget> getBtnWidget() {
    // 休日用
    if (_dayOfWeek == DateTime.saturday || _dayOfWeek == DateTime.sunday) {
      return <Widget>[
        new MaterialButton(
          minWidth: 30.0,
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            widget.stKey.currentState.setFixTime();
            widget.edKey.currentState.setFixTime();
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
            widget.stKey.currentState.clear();
            widget.edKey.currentState.clear();
            clearTime();
          },
          child: const Text("クリア"),
        ),
      ];
    }
    // 平日用
    else {
      return <Widget>[
        new MaterialButton(
          minWidth: 30.0,
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            widget.stKey.currentState.setFixTime();
            widget.edKey.currentState.setFixTime();
            saveFixTime();
          },
          child: const Text("定時"),
        ),
        SpaceBox.width(16.0),
        new MaterialButton(
          minWidth: 30.0,
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () async {
            getHoliday();
          },
          child: const Text("休暇"),
        ),
        SpaceBox.width(16.0),
        new MaterialButton(
          minWidth: 30.0,
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            widget.stKey.currentState.clear();
            widget.edKey.currentState.clear();
            clearTime();
          },
          child: const Text("クリア"),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.lineSizeGetKey,
      padding: const EdgeInsets.all(16.0),
      decoration: new BoxDecoration(
          color: _backGroundColor,
          border: new Border(
              bottom: new BorderSide(color: Colors.black12, width: 1.0))),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: new Text(_dayText),
              ),
              Row(
                children: [
                  new StTimeBtn(
                    key: widget.stKey,
                    timeStr: DateInfo.noneTime,
                    date: '$_month-$_day',
                    titleKey: widget.titleKey,
                  ),
                  const Text(
                    '～',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  new EdTimeBtn(
                    key: widget.edKey,
                    timeStr: DateInfo.noneTime,
                    date: '$_month-$_day',
                    titleKey: widget.titleKey,
                  ),
                ],
              ),
              SpaceBox(),
              Row(
                children: getBtnWidget(),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
