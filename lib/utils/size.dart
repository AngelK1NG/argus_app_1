import 'package:flutter/widgets.dart';

class SizeConfig {
  bool _init = false;
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeWidth;
  static double safeHeight;

  void init(BuildContext context) {
    if (!_init) {
      _init = true;
      _mediaQueryData = MediaQuery.of(context);
      screenWidth = _mediaQueryData.size.width;
      screenHeight = _mediaQueryData.size.height;

      _safeAreaHorizontal =
          _mediaQueryData.padding.left + _mediaQueryData.padding.right;
      _safeAreaVertical =
          _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

      safeWidth = screenWidth - _safeAreaHorizontal;
      safeHeight = screenHeight - _safeAreaVertical;
    }
  }
}
