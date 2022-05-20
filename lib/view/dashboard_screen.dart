import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_application/firebaseQuery/firebase_quiery.dart';
import 'package:firebase_chat_application/pref/pref_const.dart';
import 'package:firebase_chat_application/view/chat_list_screen.dart';
import 'package:firebase_chat_application/view/login_screen.dart';
import 'package:firebase_chat_application/view/user_list_screen.dart';
import 'package:flutter/material.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen() : super();

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseQuiery.getMyInformation((userInfoDetail) {
      // Pref.setObject("myUserInfo", userInfoDetail);
      Pref.setValue("myName", userInfoDetail.name);
    });

    FirebaseQuiery.createOnlineStatus();

  }

  @override
  Widget build(BuildContext context) {
    TabBar get_tabBar = TabBar(
      indicatorColor: Colors.orange,
      unselectedLabelStyle: const TextStyle(color: Colors.white),
      tabs: [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.message,
                color: Colors.white,
              ),
              Text("Chat")
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.manage_accounts,
                color: Colors.white,
              ),
              Text("User List")
            ],
          ),
        ),
      ],
    );

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Center(
            child: Text(
              "Messaging app",
              style: TextStyle(color: Colors.white),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: get_tabBar.preferredSize,
            child: ColoredBox(
              color: Colors.white10,
              child: get_tabBar,
            ),
          ),
          actions: [
            InkWell(
                onTap: () {
                  FirebaseQuiery.onlineStatusUpdate(false);
                  FirebaseAuth.instance.signOut().then(
                      (value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false));

                },
                child: const Icon(Icons.login))
          ],
        ),
        body: const TabBarView(
          children: [ChatListScreen(), UserListScreen()],
        ),
      ),
    );
  }
}
