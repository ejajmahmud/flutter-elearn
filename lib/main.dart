import 'package:elearn/screens/home.dart';
import 'package:flutter/material.dart';

import 'apis/dataapis.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataApi().getMenu();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'elearn',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
