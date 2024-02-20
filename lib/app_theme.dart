import 'package:flutter/material.dart';

class AppTheme {
  static const _defaultFontFamily = 'Roboto';

  static ThemeData theme(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final cardColor = isDark
        ? const Color.fromRGBO(0, 0, 15, 1)
        : const Color.fromRGBO(255, 255, 240, 1);
    final theme = ThemeData(
      brightness: brightness,
      fontFamily: _defaultFontFamily,
      cardColor: cardColor,
    );
    return theme.copyWith(
      iconTheme: theme.iconTheme.copyWith(size: 32),
    );
  }
}
