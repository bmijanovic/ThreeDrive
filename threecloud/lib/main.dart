import 'package:flutter/material.dart';
import 'package:threecloud/screens/login_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:threecloud/screens/registration_screen.dart';
import 'style.dart';
import 'helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // checkIfUserIsLoggedIn();
  }

  // checkIfUserIsLoggedIn() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   loggedIn = prefs.getBool('loggedIn');
  //   if (loggedIn == true) {
  //     await User.getPersonalInformations(prefs.getString('userId'));
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        iconTheme: myIconTheme,
        elevatedButtonTheme:
        ElevatedButtonThemeData(style: myElevatedButtonStyle),
        colorScheme: mainColorScheme,
        appBarTheme: const AppBarTheme(
          titleTextStyle: appBarTextStyle,
        ),
        textTheme: const TextTheme(
          subtitle1: titleTextStyle,
          bodyText1: bodyTextStyle,
        ),
        tabBarTheme: myTabBarTheme,
      ),
      home: loggedIn == true ? RegistrationScreen() : LoginScreen(),
    );
  }
}
