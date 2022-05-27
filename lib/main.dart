import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_application/firebaseQuery/firebase_quiery.dart';
import 'package:firebase_chat_application/view/dashboard_screen.dart';
import 'package:firebase_chat_application/view/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  // FirebaseAuth.instance.setSettings()
  FirebaseFirestore.instance.settings =
      const Settings(
          persistenceEnabled: false,
      );
  await FirebaseAppCheck.instance.activate(
      // webRecaptchaSiteKey: 'recaptcha-v3-site-key',
      );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    log("initState");
    FirebaseQuiery.onlineStatusUpdate(true);

  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    // print("Status state pause=========${  AndroidServiceForegroundType.foregroundServiceTypeNone.value}++++++++");
    log("initState life cycle ${state}");


    switch (state) {
      case AppLifecycleState.inactive:

        ///============ Inactive ============
        await FirebaseQuiery.onlineStatusUpdate(false);
        break;

      case AppLifecycleState.paused:

        ///============ Paused ============
       await FirebaseQuiery.onlineStatusUpdate(false);

        break;

      case AppLifecycleState.resumed:

        ///============ Resumed ============
        await FirebaseQuiery.onlineStatusUpdate(true);

        break;

      case AppLifecycleState.detached:

        ///============ Detached ============
        await FirebaseQuiery.onlineStatusUpdate(false);

        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    log("deactivate");
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseAuth.instance.currentUser != null ? const DashBoardScreen() : LoginScreen(),
    );
  }
}
