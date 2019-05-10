import 'package:flutter/material.dart';
import 'dateInfo.dart';
import 'tab.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  static double actualWorkingHours = 0.0;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'KinTai',
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new CircularProgressIndicator(),
            new SpaceBox(),
            new Text('起動処理中')
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

  List<DayView> dayViewList;


  var callTester = (String s) =>  print(s);

  List<Widget> _getTab() {
    List<Widget> tabs = <Widget>[];
    for (var i = 5; i <= 5; i++) {
      tabs.add(new TabHead(i));
    }
    return tabs;
  }

  List<Widget> _getTabView() {
    List<Widget> tabs = <Widget>[];
    for (var i = 5; i <= 5; i++) {
      tabs.add(new SingleChildScrollView(child: new Column(
        children: _getDayList(i),
      ),));
    }
    return tabs;
  }

  List<Widget> _getDayList(var month) {

    final lastDayOfMonth = new DateTime(2019, month + 1, 0);
    return (List.generate(lastDayOfMonth.day, (i) => i).map((int i) {
      return new DayView(month, i, callTester);
    }).toList());

  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 1, vsync: this);
    dateInfo = new DateInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('_MyHomePageState build');
    callTester('init build');
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
    );
  }
}
