import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_application/firebaseQuery/firebase_quiery.dart';
import 'package:firebase_chat_application/model/user_info.dart';
import 'package:firebase_chat_application/view/dashboard_screen.dart';
import 'package:firebase_chat_application/widget/my_text_form_field.dart';
import 'package:firebase_chat_application/widget/utils.dart';
import 'package:flutter/material.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({Key? key}) : super(key: key);

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  TextEditingController emailTextEditController = TextEditingController();
  TextEditingController passwordTextEditController = TextEditingController();
  TextEditingController nameTextEditController = TextEditingController();

  bool isLoading=false;
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
                validator: (validator) {},
                callOnChangedValue: (validator) {},
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
            MyTextFormField(
                controller: nameTextEditController,
                hintText: "name",
                labeltext: "name",
                onSaved: (onSaved) {},
                validator: (validator) {},
                callOnChangedValue: (validator) {},
                callBackPasswordView: (callBackPasswordView) {}),
            const SizedBox(
              height: 20,
            ),
            isLoading?CircularProgressIndicator():ElevatedButton(
                onPressed: () async {
                  if (emailTextEditController.text.isEmpty || passwordTextEditController.text.isEmpty|| nameTextEditController.text.isEmpty) {
                    AppUtils.showSnakeBar(context: context, msg: "input field should not be empty", backgroundColors: Colors.pink);
                  } else {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      final User? user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: emailTextEditController.text.toString().trim(), password: passwordTextEditController.text.toString().trim()))
                          .user;

                      if (user!.uid.isNotEmpty) {
                        log("login value email pass = user is not empty}");
                        
                        UserInfoDetails userInfoDetails = UserInfoDetails(email: emailTextEditController.text.trim().toString(), password: passwordTextEditController
                            .text.trim().toString(), name: nameTextEditController.text.toString().trim(), uID: user.uid.toString());

                        await FirebaseFirestore.instance.collection("users").doc(user.uid).set(userInfoDetails.toMap());
                         FirebaseQuiery.createOnlineStatus();

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
                child: const Text("Register")),
            Spacer(),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Go login screen"))
          ],
        ),
      ),
    );
  }
}
