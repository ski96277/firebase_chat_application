import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_application/view/dashboard_screen.dart';
import 'package:firebase_chat_application/view/register_account_screen.dart';
import 'package:firebase_chat_application/widget/my_text_form_field.dart';
import 'package:firebase_chat_application/widget/utils.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditController = TextEditingController();
  TextEditingController passwordTextEditController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyTextFormField(
                controller: emailTextEditController,
                hintText: "email",
                labeltext: "email",
                onSaved: (onSaved) {},
                callOnChangedValue: (onSaved) {},
                validator: (validator) {},
                callBackPasswordView: (callBackPasswordView) {}),
            const SizedBox(
              height: 20,
            ),
            MyTextFormField(
                controller: passwordTextEditController,
                hintText: "password",
                labeltext: "password",
                onSaved: (onSaved) {},
                validator: (validator) {},
                callOnChangedValue: (validator) {},
                callBackPasswordView: (callBackPasswordView) {}),
            const SizedBox(
              height: 20,
            ),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (emailTextEditController.text.isEmpty || passwordTextEditController.text.isEmpty) {
                        AppUtils.showSnakeBar(context: context, msg: "input field should not be empty", backgroundColors: Colors.pink);
                      } else {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final User? user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: emailTextEditController.text.toString().trim(), password: passwordTextEditController.text.toString().trim()))
                              .user;

                          if (user!.uid.isNotEmpty) {
                            log("login value email pass = user is not empty}");

                            setState(() {
                              isLoading = false;
                            });
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const DashBoardScreen()), (Route<dynamic> route) => false);
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            log("login value email pass = user not empty}");

                            AppUtils.showSnakeBar(context: context, msg: "User Not found");
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          AppUtils.showSnakeBar(context: context, msg: "User Not found", backgroundColors: Colors.pink);

                          log("login value email pass e = ${e}");
                        }
                      }
                    },
                    child: const Text("Login")),
            Spacer(),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterAccountScreen()),
                  );
                },
                child: const Text("Create new account"))
          ],
        ),
      ),
    );
  }
}
