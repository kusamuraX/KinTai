import 'package:flutter/material.dart';
import 'sheet.dart';
import './workTimeTab/tabView.dart';

class FloatBtnArea extends StatefulWidget {

  final List<GlobalKey<DayViewState>> tabViewKeys;

  FloatBtnArea({Key key, this.tabViewKeys}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new FloatBtnAreaState();
}

class FloatBtnAreaState extends State<FloatBtnArea>
    with SingleTickerProviderStateMixin {
  FloatBtnAreaState() : commonDuration = Duration(milliseconds: 500);

  Animation<double> _rotaTween;
  Animation<double> _scaleTween;
  AnimationController animationController;
  final Duration commonDuration;
  bool animated = false;
  final double baseMargin = 65.0;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: commonDuration, vsync: this);

    var curvedAnimation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeIn);

    _rotaTween = Tween<double>(
      begin: 0.0,
      end: 0.625,
    ).animate(curvedAnimation);
    _scaleTween = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 300.0,
      child: new Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        new AnimatedContainer(
          duration: commonDuration,
          margin: new EdgeInsets.only(bottom: animated ? baseMargin * 3 : 0.0),
          child: new ScaleTransition(
            scale: _scaleTween,
            child: new FloatingActionButton(
                heroTag: 'btn4',
                child: const Text('全削',style: TextStyle(fontWeight: FontWeight.bold,)),
                onPressed: () {
                  widget.tabViewKeys.forEach((k) {
                    if(k.currentState != null){
                      k.currentState.clearTime();
                    }
                  });
                },
                backgroundColor: Colors.cyan),
          ),
        ),
        new AnimatedContainer(
          duration: commonDuration,
          margin: new EdgeInsets.only(bottom: animated ? baseMargin * 2 : 0.0),
          child: new ScaleTransition(
            scale: _scaleTween,
            child: new FloatingActionButton(
                heroTag: 'btn3',
                child: const Text('全定時',style: TextStyle(fontWeight: FontWeight.bold,)),
                onPressed: () {
                  widget.tabViewKeys.forEach((k) {
                    if(k.currentState != null){
                      k.currentState.saveFixTimeIfNotSaved();
                    }
                  });
                },
                backgroundColor: Colors.cyan),
          ),
        ),
        new AnimatedContainer(
          duration: commonDuration,
          margin: new EdgeInsets.only(bottom: animated ? baseMargin : 0.0),
          child: new ScaleTransition(
            scale: _scaleTween,
            child: new FloatingActionButton(
                heroTag: 'btn2',
                child: new Icon(Icons.cloud_upload),
                onPressed: () {
                  signIn();
                },
                backgroundColor: Colors.cyan),
          ),
        ),
        new RotationTransition(
          turns: _rotaTween,
          child: new FloatingActionButton(
              heroTag: 'btn1',
              child: new Icon(Icons.add),
              onPressed: _btnPress,
              backgroundColor: Colors.cyan),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  _btnPress() {
    setState(() {
      if (animationController.isCompleted) {
        animationController.reverse();
        animated = false;
      } else {
        animationController.forward();
        animated = true;
      }
    });
  }
}
