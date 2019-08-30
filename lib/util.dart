import 'package:flutter/material.dart';

// 空白用
class SpaceBox extends SizedBox {
  SpaceBox({double width = 8.0, double height = 8.0})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8.0]) : super(width: value);

  SpaceBox.height([double value = 8.0]) : super(height: value);
}