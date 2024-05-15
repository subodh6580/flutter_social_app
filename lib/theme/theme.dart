enum Font { lato, openSans, poppins, raleway, roboto }
enum DisplayMode { light, dark }

class AppThemeSetting {
  static DisplayMode mode = DisplayMode.light;

  static setDisplayMode(DisplayMode currentMode) {
    mode = currentMode;
  }
}

class AppTheme {
  static String get fontName {
    switch (fontType) {
      case Font.roboto:
        return 'Roboto';
      case Font.raleway:
        return 'Raleway';
      case Font.poppins:
        return 'Poppins';
      case Font.openSans:
        return 'OpenSans';
      case Font.lato:
        return 'Lato';
    }
  }

  static double iconSize = 20;
  static Font fontType = Font.poppins;
}
