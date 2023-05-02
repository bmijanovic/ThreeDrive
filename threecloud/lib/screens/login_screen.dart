import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threecloud/screens/registration_screen.dart';
import '../models/user.dart';
import '../widgets/big_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Login to use our services!",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(
                height: 50.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                child: Column(
                  children: [
                    BigTextField(usernameController, TextInputType.name, "Username*", false),
                    BigTextField(passwordController, TextInputType.visiblePassword, "Password*", true),
                    ElevatedButton(
                      onPressed: (() => logIn(context)),
                      child: const Text("Login"),
                    ),
                    const Padding(
                        padding: EdgeInsets.all(16.0)
                    ),
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text.rich(
                        TextSpan(
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: [
                              TextSpan(
                                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  text: "Register now",
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegistrationScreen()));
                                    }
                              ),
                            ]
                        )
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  logIn(BuildContext context) async {
    if (!areInputsValid(context)) return;
    try
    {
      String id = await User.logIn(usernameController.text, passwordController.text);

      Fluttertoast.showToast(
          msg: "Logged in successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      await rememberThatUserLoggedIn(id);
    } on StateError catch (error)
    {
      showError(context, error.message);
    }
  }

  rememberThatUserLoggedIn(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("loggedIn", true);
    await prefs.setString("userId", id);
  }

  bool areInputsValid(BuildContext context) {
    if (passwordController.text == "" ||
        passwordController.text == "") {
      showError(context, "Invalid input values");
      return false;
    }
    return true;
  }

  showError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Error"),
          content: Text(message),
        );
      },
      barrierDismissible: true,
    );
  }
}