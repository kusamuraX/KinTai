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
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new SectorAnimation(
      controller: animationController,
      curvedAnimation: new CurvedAnimation(
          parent: animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
}

class SectorAnimation extends StatelessWidget {
  SectorAnimation({Key key, this.controller, this.curvedAnimation})
      : _rotaTween = Tween<double>(
          begin: 0.0,
          end: 0.625,
        ).animate(
          curvedAnimation,
        ),
        _transTween1 =
            Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.2))
                .animate(
          curvedAnimation,
        ),
        _transTween2 =
            Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -2.4))
                .animate(
          curvedAnimation,
        ),
        _transTween3 =
            Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -3.6))
                .animate(
          curvedAnimation,
        ),
        _scaleTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          curvedAnimation,
        ),
        super(key: key);

  final AnimationController controller;
  final CurvedAnimation curvedAnimation;
  final Animation<double> _rotaTween;
  final Animation<Offset> _transTween1;
  final Animation<Offset> _transTween2;
  final Animation<Offset> _transTween3;
  final Animation<double> _scaleTween;

  build(context) {
    return new AnimatedBuilder(
      animation: controller,
      builder: (context, builder) {
        return Stack(alignment: Alignment.center, children: <Widget>[
          new SlideTransition(
            position: _transTween3,
            child: new ScaleTransition(
              scale: _scaleTween,
              child: new FloatingActionButton(
                  child: new Icon(FontAwesomeIcons.playstation),
                  onPressed: () {},
                  backgroundColor: Colors.cyan),
            ),
          ),
          new SlideTransition(
            position: _transTween2,
            child: new ScaleTransition(
              scale: _scaleTween,
              child: new FloatingActionButton(
                  child: new Icon(FontAwesomeIcons.trashAlt),
                  onPressed: () {},
                  backgroundColor: Colors.cyan),
            ),
          ),
          new SlideTransition(
            position: _transTween1,
            child: new ScaleTransition(
              scale: _scaleTween,
              child: new FloatingActionButton(
                  child: new Icon(FontAwesomeIcons.cloudUploadAlt),
                  onPressed: () {},
                  backgroundColor: Colors.cyan),
            ),
          ),
          new RotationTransition(
            turns: _rotaTween,
            child: new FloatingActionButton(
                child: new Icon(FontAwesomeIcons.plusCircle),
                onPressed: _btnPress,
                backgroundColor: Colors.cyan),
          ),
        ]);
      },
    );
  }

  _btnPress() {
    if (controller.isCompleted) {
      controller.reverse();
    } else {
      controller.forward();
    }
  }
}
