import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'KinTai',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'KinTai',),
    );
  }
}

class SpaceBox extends SizedBox {
  SpaceBox({double width = 8.0, double height = 8.0})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8.0]) : super(width: value);
  SpaceBox.height([double value = 8.0]) : super(height: value);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final String noneTime = '--:--';
  final saturdayColor = Colors.blueAccent.shade100;
  final sundayColor = Colors.redAccent.shade100;
  final normalColor = Colors.white;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  TabController _tabController;

  int _normalWorkingHours = 0;
  int _actualWorkingHours = 0;

  List<String> stTimes = <String>[];
  List<String> edTimes = <String>[];

  List<Widget> _getTab(){
    final Size mediaSize = MediaQuery.of(context).size;
    List<Widget> tabs = <Widget>[];
    for(var i = 4; i <= 4; i++) {
      tabs.add(Container(
        width: mediaSize.width,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          new Text(i.toString() + '月'),
          new Text('稼働時間 : ( $_actualWorkingHours/$_normalWorkingHours )h'),
        ],),
      ));
    }
    return tabs;
  }

  List<Widget> _getTabView(){
    List<Widget> tabs = <Widget>[];
    for(var i = 4; i <= 4; i++) {
      tabs.add(new ListView(children: _getDayList(i),));
    }
    return tabs;
  }

  TimeOfDay _getStShowTime(String timeStr){
    if(timeStr == widget.noneTime){
      return TimeOfDay(hour: 9, minute: 0);
    } else {
      return new TimeOfDay(hour: int.parse(timeStr.split(":")[0]), minute: int.parse(timeStr.split(":")[1]));
    }
  }

  TimeOfDay _getEdShowTime(String timeStr){
    if(timeStr == widget.noneTime){
      return TimeOfDay.now();
    } else {
      return new TimeOfDay(hour: int.parse(timeStr.split(":")[0]), minute: int.parse(timeStr.split(":")[1]));
    }
  }

  Color _getDayColor(int month, int day){
    var week = new DateTime(2019, month + 1, day).weekday;
    if(week == DateTime.saturday){
      return widget.saturdayColor;
    } else if(week == DateTime.sunday){
      return widget.sundayColor;
    } else {
      return widget.normalColor;
    }
  }

  List<Widget> _getDayList(var month){
    List<Widget> days = <Widget>[];
    final lastDayOfMonth = new DateTime(2019, month + 1, 0);
    days.addAll(List.generate(lastDayOfMonth.day, (i) => i).map((int i){
      stTimes.add(widget.noneTime);
      edTimes.add(widget.noneTime);
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: new BoxDecoration(
            color: _getDayColor(month, i),
            border: new Border(bottom: new BorderSide(color: Colors.black12, width: 1.0))
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Text((i+1).toString() + '日'),
                ),
                Container(
                  child: Row(
                    children: [
                      new FlatButton(
                        onPressed: () async {
                          TimeOfDay selectTime = await showTimePicker(
                              context: context,
                              initialTime: _getStShowTime(stTimes[i])
                          );
                          setState(() {
                            stTimes[i] = selectTime.format(context);
                          });
                        },
                        child: new Text(stTimes[i], style: TextStyle(fontSize: 20.0),),
                      ),
                      Text('～', style: TextStyle(fontSize: 20.0),),
                      new FlatButton(
                        onPressed: () async {
                          TimeOfDay selectTime = await showTimePicker(
                              context: context,
                              initialTime: _getEdShowTime(edTimes[i])
                          );
                          setState(() {
                            edTimes[i] = selectTime.format(context);
                          });
                        },
                        child: new Text(edTimes[i], style: TextStyle(fontSize: 20.0),),
                      ),
                    ],
                  ),
                ),
               Row(
                children: <Widget>[
                  new MaterialButton(
                    minWidth: 30.0,
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: (){
                      setState(() {
                        stTimes[i] = TimeOfDay(hour: 9, minute: 0).format(context);
                        edTimes[i] = TimeOfDay(hour: 18, minute: 0).format(context);
                      });
                    },
                    child: new Text("定時"),
                  ),
                  SpaceBox.width(16.0),
                  new MaterialButton(
                    minWidth: 30.0,
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: (){
                      setState(() {
                      });
                    },
                    child: new Text("休暇"),
                  ),
                  SpaceBox.width(16.0),
                  new MaterialButton(
                    minWidth: 30.0,
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: (){
                      setState(() {
                        stTimes[i] = widget.noneTime;
                        edTimes[i] = widget.noneTime;
                      });
                    },
                    child: new Text("クリア"),
                  ),
                ],
              ) ,
              ],
            ))
          ],
        ),);
    }).toList());

    return days;
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        bottom: new TabBar(
          tabs: _getTab(),
          controller: _tabController,
          isScrollable: true,
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: _getTabView(),
      ),
    );
  }
}
