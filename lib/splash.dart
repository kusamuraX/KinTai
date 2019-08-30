import 'package:flutter/material.dart';
import 'package:teskin/dateInfo.dart';
import 'package:teskin/util.dart';

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
            new Text(
              '∞',
              style: TextStyle(color: Colors.white, fontSize: 64),
            ),
            new SpaceBox(
              height: 16.0,
            ),
            new CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)),
            new SpaceBox(
              height: 16.0,
            ),
            new Text(
              '起動処理中',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
