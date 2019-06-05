import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FloatBtnArea extends StatefulWidget {
  FloatBtnArea({Key key}) : super(key: key);

  final IconData closeIcon = const IconData(59528, fontFamily: 'MaterialIcons');
  final IconData openIcon = const IconData(58298, fontFamily: 'MaterialIcons');

  @override
  State<StatefulWidget> createState() => new FloatBtnAreaState();
}

class FloatBtnAreaState extends State<FloatBtnArea>
    with SingleTickerProviderStateMixin {
  // main floatボタンの押下状態
  bool floatOff = true;
  double _opacity = 0.0;

  IconData mainIcon;

  AnimationController animationController;

  List<Widget> getFloatBtn() {
    List<Widget> buttons = <Widget>[];

    buttons.add(new Padding(
      padding: EdgeInsets.all(8.0),
      child: new AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: new FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blueAccent,
          child: Icon(const IconData(58051, fontFamily: 'MaterialIcons')),
        ),
      ),
    ));
    buttons.add(new Padding(
      padding: EdgeInsets.all(8.0),
      child: new AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: new FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blueAccent,
          child: Icon(const IconData(59506, fontFamily: 'MaterialIcons')),
        ),
      ),
    ));
    buttons.add(new Padding(
      padding: EdgeInsets.all(8.0),
      child: new FloatingActionButton(
        onPressed: () {
          setState(() {
            if (floatOff) {
              floatOff = false;
              _opacity = 1.0;
              mainIcon = widget.openIcon;
            } else {
              floatOff = true;
              _opacity = 0.0;
              mainIcon = widget.closeIcon;
            }
          });
        },
        backgroundColor: Colors.pinkAccent,
        child: new Icon(mainIcon),
      ),
    ));

    return buttons;
  }

  @override
  void initState() {
    super.initState();
    mainIcon = widget.openIcon;
    animationController =
        AnimationController(duration: Duration(milliseconds: 900), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: getFloatBtn(),
    );
  }
}

class SectorAnimation extends StatelessWidget {
  SectorAnimation({Key key, this.controller})
      : scale = Tween<double>(
          begin: 1.5,
          end: 0.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
        super(key: key);
  final AnimationController controller;
  final Animation<double> scale;

  build(context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, builder) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform(
                transform: new Matrix4.identity()
                  ..scale(0.0, scale.value - 1.5),
                child: FloatingActionButton(
                    child: Icon(FontAwesomeIcons.timesCircle),
                    onPressed: _close,
                    backgroundColor: Colors.red)),
            Transform(
                transform: new Matrix4.identity()
                  ..scale(0.0, scale.value),
                child: FloatingActionButton(
                    child: Icon(FontAwesomeIcons.timesCircle),
                    onPressed: _open,
                    backgroundColor: Colors.red)),
          ],
        );
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
