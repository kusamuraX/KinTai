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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final String noneTime = '--:--';

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  TabController _tabController;

  List<String> stTimes = <String>[];
  List<String> edTimes = <String>[];

  List<Widget> _getTab(){
    final Size mediaSize = MediaQuery.of(context).size;
    List<Widget> tabs = <Widget>[];
    for(var i = 4; i <= 4; i++) {
      tabs.add(Container(
        width: mediaSize.width,
        height: 20.0,
        alignment: Alignment.center,
        child: new Text(i.toString() + '月'),
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

  List<Widget> _getDayList(var month){
    List<Widget> days = <Widget>[];
    final lastDayOfMonth = new DateTime(2019, month + 1, 0);

    days.addAll(List.generate(lastDayOfMonth.day, (i) => i).map((int i){
      stTimes.add(widget.noneTime);
      edTimes.add(widget.noneTime);
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          children: <Widget>[
            Expanded(child: Column(
              children: [
                Container(
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
                        child: new Text(stTimes[i]),
                      ),
                      Text(' ～ '),
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
                        child: new Text(edTimes[i]),
                      ),
                    ],
                  ),
                )
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
