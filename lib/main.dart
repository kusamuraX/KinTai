import 'package:flutter/material.dart';
import 'package:teskin/dateInfo.dart';
import 'package:teskin/workTimeTab/tabHeader.dart';
import 'package:teskin/workTimeTab/tabView.dart';
import 'package:teskin/splash.dart';
import 'dart:async';
import 'customfloadbtn.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '勤怠管理',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SplashPage(),
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => new MyHomePage(
              title: 'KinTai',
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final int closeDay = 15;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  DateInfo dateInfo;

  TabController _tabController;

  ScrollController _scrollController;

  List<DayView> dayViewList;

  bool floatOff = true;

  int currentMonth;

  final _tabHeaderKey1 = GlobalKey<TabHeadState>();
  final _tabHeaderKey2 = GlobalKey<TabHeadState>();
  final _lineSizeGetKey = GlobalKey();
  final _tabViewKey = GlobalKey();
  final List<GlobalKey<DayViewState>> dayKeys = new List<GlobalKey<DayViewState>>.generate(70, (i) {
    return GlobalKey<DayViewState>();
  });
  int dayKeyBindIndex = 0;

  // タブヘッダーの設定
  List<Widget> _getTab() {
    List<Widget> tabs = <Widget>[];
    for (var i = currentMonth-1; i <= currentMonth; i++) {
      if(i == currentMonth-1){
        tabs.add(new TabHead(
          key: _tabHeaderKey1,
          month: i,
        ));
      } else {
        tabs.add(new TabHead(
          key: _tabHeaderKey2,
          month: i,
        ));
      }
    }
    return tabs;
  }

  List<Widget> _getTabView() {
    List<Widget> tabs = <Widget>[];
    for (var i = currentMonth-1; i <= currentMonth; i++) {
      tabs.add(new SingleChildScrollView(
        child: new Column(
          children: _getDayList(i),
        ),
        controller: _scrollController,
      ));
    }

    return tabs;
  }


  // 初期のスクロール位置設定
  _setScrollPosition() async{
    RenderBox render = _lineSizeGetKey.currentContext.findRenderObject();
    var index = DateTime.now().day > 15 ? DateTime.now().day -16 : DateTime.now().day + 14;
    var offset = index * render.size.height;
    while (true) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(offset,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        break;
      } else {
        new Future.delayed(new Duration(milliseconds: 500));
      }
    }
  }

  // 月に対しての日の一覧を作成
  List<Widget> _getDayList(var month) {
    // 月ごとなら・・・
//    final lastDayOfMonth = new DateTime(2019, month + 1, 0);
//    var index = 0;
//    return (List.generate(lastDayOfMonth.day, (i) => i+1).map((int i) {
//      if(currentMonth == month && index == 0){
//        index++;
//        return new DayView(
//          month: month,
//          day: i,
//          titleKey: currentMonth == month ? _tabHeaderKey2 : _tabHeaderKey1,
//          lineSizeGetKey: _lineSizeGetKey,
//        );
//      } else {
//        return new DayView(
//          month: month,
//          day: i,
//          titleKey: currentMonth == month ? _tabHeaderKey2 : _tabHeaderKey1,
//        );
//      }
//    }).toList());
    // 15日締めなので16-15
    List<Widget> daysArray = <Widget>[];
    if(DateTime.now().day > widget.closeDay){
      month-=1;
    }
    var stDay = new DateTime(DateTime.now().year, month , widget.closeDay+1);
    final edDay = new DateTime(DateTime.now().year, month +1, widget.closeDay+1);
    var index = 0;
    while(stDay.add(Duration(days: index)).isBefore(edDay)) {
      var current = stDay.add(Duration(days: index));
      if(current.month == DateTime.now().month && current.day == DateTime.now().day){
        daysArray.add(new DayView(
          key: dayKeys[dayKeyBindIndex++],
          month: current.month,
          day: current.day,
          titleKey: _getTabHeaderKey(current),
          lineSizeGetKey: _lineSizeGetKey,
        ));
      } else {
        daysArray.add(new DayView(
          key: dayKeys[dayKeyBindIndex++],
          month: current.month,
          day: current.day,
          titleKey: _getTabHeaderKey(current),
        ));
      }
      index++;
    }
    return daysArray;
  }

  GlobalKey<TabHeadState> _getTabHeaderKey(DateTime currentDate){
    if(currentMonth == currentDate.month && currentDate.day <= widget.closeDay){
      return _tabHeaderKey2;
    } else if(currentMonth == currentDate.month+1 && currentDate.day > widget.closeDay) {
      return _tabHeaderKey2;
    } else {
      return _tabHeaderKey1;
    }
  }

  // 初期処理
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.index = 1;
    _tabController.addListener(() {
      print("change month");
    });
    _scrollController = new ScrollController();
    dateInfo = new DateInfo();
    if(DateTime.now().day <= widget.closeDay) {
      currentMonth = DateTime.now().month;
    } else {
      currentMonth = DateTime.now().month+1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _setScrollPosition());
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('_MyHomePageState build');

    return new Scaffold(
      appBar: new AppBar(
        flexibleSpace: new SafeArea(
            child: new TabBar(
          tabs: _getTab(),
          controller: _tabController,
          isScrollable: true,
        )),
      ),
      body: new TabBarView(
        key: _tabViewKey,
        controller: _tabController,
        children: _getTabView(),
      ),
      floatingActionButton: new FloatBtnArea(tabViewKeys: dayKeys,),
    );
  }
}
