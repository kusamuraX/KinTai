import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FloatBtnArea extends StatefulWidget {
  FloatBtnArea({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new FloatBtnAreaState();
}

class FloatBtnAreaState extends State<FloatBtnArea>
    with SingleTickerProviderStateMixin {

  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new SectorAnimation(
      controller: animationController,
    );
  }
}

class SectorAnimation extends StatelessWidget {
  SectorAnimation({Key key, this.controller})
      : _openScale = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(
          new CurvedAnimation(parent: controller, curve: Curves.linear),
        ),
        _closeScale = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          new CurvedAnimation(parent: controller, curve: Curves.linear),
        ),
        _transTween1 =
            Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.2))
                .animate(
          new CurvedAnimation(parent: controller, curve: Curves.linear),
        ),
        _transTween2 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -2.4))
            .animate(
          new CurvedAnimation(parent: controller, curve: Curves.linear),
        ),
        _transTween3 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -3.6))
            .animate(
          new CurvedAnimation(parent: controller, curve: Curves.linear),
        ),
        super(key: key);

  final AnimationController controller;
  final Animation<double> _openScale;
  final Animation<double> _closeScale;
  final Animation<Offset> _transTween1;
  final Animation<Offset> _transTween2;
  final Animation<Offset> _transTween3;

  build(context) {
    return new AnimatedBuilder(
      animation: controller,
      builder: (context, builder) {
        return Stack(alignment: Alignment.center, children: <Widget>[
          new SlideTransition(
            position: _transTween3,
            child: new FloatingActionButton(
                child: new Icon(FontAwesomeIcons.playstation),
                onPressed: null,
                backgroundColor: Colors.red),
          ),
          new SlideTransition(
            position: _transTween2,
            child: new FloatingActionButton(
                child: new Icon(FontAwesomeIcons.trashAlt),
                onPressed: null,
                backgroundColor: Colors.red),
          ),
          new SlideTransition(
            position: _transTween1,
            child: new FloatingActionButton(
                child: new Icon(FontAwesomeIcons.cloudUploadAlt),
                onPressed: null,
                backgroundColor: Colors.red),
          ),
          new ScaleTransition(
            scale: _openScale,
            child: new FloatingActionButton(
                child: new Icon(FontAwesomeIcons.plusCircle),
                onPressed: _open,
                backgroundColor: Colors.red),
          ),
          new ScaleTransition(
            scale: _closeScale,
            child: new FloatingActionButton(
                child: new Icon(FontAwesomeIcons.timesCircle),
                onPressed: _close,
                backgroundColor: Colors.red),
          ),
        ]);
      },
    );
  }

  _close() {
    controller.reverse();
  }

  _open() {
    controller.forward();
  }
}
