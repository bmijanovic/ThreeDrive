import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../widgets/big_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {

  bool isChecked =false;

  DateTime selectedDate = DateTime.now();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordRepeatController = TextEditingController();
  final TextEditingController referralUsernameController = TextEditingController();


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
                "Register to use our services!",
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
                    BigTextField(nameController, TextInputType.name, "First name*", false),
                    BigTextField(surnameController, TextInputType.text, "Last name*", false),
                    BigTextField(emailController, TextInputType.emailAddress, "Email*", false),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: BigTextField(
                              birthdateController,
                              TextInputType.datetime,
                              "Birthdate*",
                              false
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: 1.0,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: const Text('Select date'),
                          ),
                        ),
                      ],
                    ),
                    BigTextField(passwordController, TextInputType.visiblePassword, "Password*", true),
                    BigTextField(
                        passwordRepeatController,
                        TextInputType.visiblePassword,
                        "Repeat password*",
                        true),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CheckboxListTile(
                        title: const Text("I have referral username",style: TextStyle(color: Colors.black,fontSize: 19,fontWeight: FontWeight.w400,)),
                        value: isChecked,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                      ),
                    ),
                    if (isChecked)
                    BigTextField(referralUsernameController, TextInputType.name, "Referral username*", false),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: (() {
                          if (isChecked){
                            createAccountWithInvite(context);
                          }else{
                            createAccount(context);
                          }
                          Fluttertoast.showToast(
                              msg: "Registration successful!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                          Navigator.of(context).pop(false);
                        }
                        ),
                        child: const Text("Register"),
                      ),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1950),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      birthdateController.text = "${selectedDate.toLocal()}".split(' ')[0];
    }
  }

  createAccount(BuildContext context) async {
    if (!areInputsValid(context)) return;
    try
    {
      String id = await User.register(nameController.text, surnameController.text, emailController.text, passwordController.text, birthdateController.text, usernameController.text);
      await remeberThatUserLogedIn(id);
    } on StateError catch (error)
    {
      showError(context, error.message);
    }
  }

  createAccountWithInvite(BuildContext context) async {
    if (!areInputsValid(context)) return;
    try
    {
      String id = await User.registerWithInvite(nameController.text, surnameController.text, emailController.text, passwordController.text, birthdateController.text, usernameController.text,referralUsernameController.text);
      await remeberThatUserLogedIn(id);
    } on StateError catch (error)
    {
      showError(context, error.message);
    }
  }

  remeberThatUserLogedIn(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("loggedIn", true);
    await prefs.setString("userId", id);
  }

  bool areInputsValid(BuildContext context) {
    if (nameController.text == "" ||
        surnameController.text == "" ||
        emailController.text == "" ||
        passwordController.text == "" ||
        passwordController.text == "" || (isChecked && referralUsernameController.text=="")) {
      showError(context, "Invalid input values");
      return false;
    }
    if (passwordController.text != passwordRepeatController.text) {
      showError(context, "Entered passwords don't match");
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
