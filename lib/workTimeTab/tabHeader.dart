import 'package:flutter/material.dart';
import 'package:teskin/dateInfo.dart';

/// タブヘッダ
/// 月と月の総時間を表示
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
    _actualWorkTime = 0.0;
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
          new Text('稼働時間 : ( $_actualWorkTime / ${DateInfo.normalWorkingHours} )h'),
        ],
      ),
    );
  }
}