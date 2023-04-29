//@dart = 2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences _pref;
  bool _darkTheme;

  bool get darkTheme => _darkTheme;

  ThemeProvider() {
    _darkTheme = true;
    _loadFromPrefs();
  }

  toggleTheme(){
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    _pref ??= await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
      await _initPrefs();
      _darkTheme = _pref.getBool(key) ?? true;
      notifyListeners();
  }
  
  _saveToPrefs() async {
    await _initPrefs();
    _pref.setBool(key, _darkTheme);
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    primarySwatch: Colors.red,
    bottomAppBarColor: Colors.grey[800],
    colorScheme: const ColorScheme.dark(),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.grey[800],
    ),
  );

  static final lightTheme = ThemeData(
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    bottomAppBarColor: Colors.white,
    primarySwatch: Colors.red,
    colorScheme: const ColorScheme.light(),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: Colors.white,
    ),
  );
}

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch.adaptive(
      activeColor: Colors.red,
      value: themeProvider.darkTheme,
      onChanged: (value) {
        final provider = Provider.of<ThemeProvider>(context,listen: false);
        provider.toggleTheme();
      }
    );
  }
}