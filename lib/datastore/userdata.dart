import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  firstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = (prefs.getBool('firsttime') ?? true);
    await prefs.setBool('firsttime', false);
    return isFirstTime;
  }

  Future<bool> getMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = (prefs.getBool('mode') ?? true);
    return isFirstTime;
  }

  setMode(bool prefrence) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mode', prefrence);
  }

  Future<int> getQuestionViewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int isFirstTime = (prefs.getInt('Questions') ?? 0);
    return isFirstTime;
  }

  Future<int> setQuestionViewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int totalQuestions = (prefs.getInt('Questions') ?? 0);
    await prefs.setInt('Questions', totalQuestions + 1);
    return totalQuestions + 1;
  }
}
