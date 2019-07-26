import 'package:flutter/material.dart';
import 'dateInfo.dart';
import 'tab.dart';
import 'dart:async';
import 'customfloadbtn.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  static double actualWorkingHours = 0.0;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '勤怠',
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

class SpaceBox extends SizedBox {
  SpaceBox({double width = 8.0, double height = 8.0})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8.0]) : super(width: value);

  SpaceBox.height([double value = 8.0]) : super(height: value);
}

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _timer();
  }

  _timer() async {
    new DateInfo().getHoliday(DateTime.now().month).then((bool) {
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(Icons.people, size: 128.0,),
            new SpaceBox(height: 16.0,),
            new CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)
            ),
            new SpaceBox(height: 16.0,),
            new Text('起動処理中',style: TextStyle(color: Colors.white),)
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

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

  _bindAfter(_) {
    _setScrollPosition();
  }
  _setScrollPosition() async {
    RenderBox render = _lineSizeGetKey.currentContext.findRenderObject();
    var offset = (DateTime.now().day - 1) * render.size.height;
    while (true) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(offset,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        break;
      } else {
        await new Future.delayed(new Duration(milliseconds: 500));
      }
    }
  }

  List<Widget> _getDayList(var month) {
    final lastDayOfMonth = new DateTime(2019, month + 1, 0);
    var index = 0;
    return (List.generate(lastDayOfMonth.day, (i) => i+1).map((int i) {
      if(currentMonth == month && index == 0){
        index++;
        return new DayView(
          month: month,
          day: i,
          titleKey: currentMonth == month ? _tabHeaderKey2 : _tabHeaderKey1,
          lineSizeGetKey: _lineSizeGetKey,
        );
      } else {
        return new DayView(
          month: month,
          day: i,
          titleKey: currentMonth == month ? _tabHeaderKey2 : _tabHeaderKey1,
        );
      }
    }).toList());
  }

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
    currentMonth = DateTime.now().month;
    WidgetsBinding.instance.addPostFrameCallback(_bindAfter);
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
        controller: _tabController,
        children: _getTabView(),
      ),
      floatingActionButton: new FloatBtnArea(),
    );
  }
}
