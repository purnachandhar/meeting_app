import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:video_call/provider/google_sign_in.dart';
import 'package:video_call/services/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isVisible = false;

  Future saveUserInfoInDatabase() async {
    print("Name is ${user.displayName}");
    print("Email is ${user.displayName}");
    print("PhotoUrl is ${user.photoURL}");
    print("PhoneNumber is ${user.phoneNumber}");
    Map<String, dynamic> userInfoMap = {
      "userId": user.email,
      "userEmail": user.email,
      "userName": user.displayName,
      "userImageUrl": user.photoURL,
      "addedPhoneNumber": user.phoneNumber,
    };
    await DatabaseServices()
        .addUserInfo(user.email!, userInfoMap)
        .whenComplete(() => print("UserInfo added Complete! 😏😏😏😏😏😏"));
  }

  @override
  void initState() {
    saveUserInfoInDatabase();
    super.initState();
  }

  // final user = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();
  late String roomCode;

  joinVideoConferrencingWebRoom() async {
    String serverUrl;
    if (_formKey.currentState!.validate()) {
      serverUrl = "https://meet.jit.si";

      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      };

      if (!kIsWeb) {
        // Here is an example, disabling features for each platform
        if (Platform.isAndroid) {
          // Disable ConnectionService usage on Android to avoid issues (see README)
          featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        } else if (Platform.isIOS) {
          // Disable PIP on iOS as it looks weird
          featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        } else if (kIsWeb) {}
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomCode)
        ..serverURL = serverUrl
        ..userDisplayName = user.displayName
        ..userEmail = user.email
        ..userAvatarURL = user.photoURL
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": roomCode,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": user.displayName}
        };

      debugPrint("JitsiMeetingOptions: $options");

      await JitsiMeet.joinMeeting(options,
          listener: JitsiMeetingListener(
              onConferenceWillJoin: (message) {
                debugPrint("${options.room} will join with message: $message");
              },
              onConferenceJoined: (message) {
                debugPrint("${options.room} joined with message: $message");

              },
              onConferenceTerminated: (message) {
                debugPrint("${options.room} terminated with message: $message");

              },
              genericListeners: [
                JitsiGenericListener(
                    eventName: 'readyToClose',
                    callback: (dynamic message) {
                      debugPrint("readyToClose callback");
                    })
              ]));
    } else {
      print("please enter some code to join");
    }

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.red),
        title: Text(
          'Join Video Conferrence',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              openModal();
            },
            child: Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(right: 7, top: 8),
                child: Icon(Icons.logout)),
          )
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Container(
            alignment: Alignment.center,
            child: kIsWeb
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Container(
                              child: webChartRoom(),
                            ),
                           Expanded(
                             child: Container(
                                width: 1500,
                                height: 15000,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Card(
                                          color: Colors.black,
                                          child: JitsiMeetConferencing(
                                            extraJS: [
                                              // extraJs setup example
                                              '<script>function echo(){console.log("echo!!!")};</script>',
                                              '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                            ],
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 120.0,
                                          height: 100.0,
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                "${user.photoURL}"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                           )
                    ],
                  )
                : ChatRoomForm(),
          ),
        ),
      ),
    );
  }

  void openModal() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Loggin You Out"),
          content: Text("Are you sure you want to Log Out From this Account?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            CupertinoDialogAction(
              onPressed: () {
                logOutFromThisAccount(context);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future logOutFromThisAccount(BuildContext context) async {
    Navigator.of(context).pop();
    final provider =
        await Provider.of<GoogleSignInProvider>(context, listen: false);
    provider.googleSignOut();
  }

  Widget webChartRoom() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 90.0, right: 90),
            child: TextFormField(
              decoration: InputDecoration(hintText: "Enter Secret Code"),
              onChanged: (val) {
                roomCode = val;
                print(val);
              },
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "cant't be empty!";
                } else {
                  val = "";
                  return null;
                }
              },
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  joinVideoConferrencingWebRoom();

                },
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(29)),
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.4,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.video_camera,
                            size: 36,
                            color: Colors.amber,
                          ),
                          SizedBox(
                            width: 9,
                          ),
                          Text(
                            "Join",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ])),
              ),
              SizedBox(
                width: 19,
              ),
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    Share.share("$roomCode");
                  } else {
                    // ignore: avoid_print
                    print("Please provide some room code");
                  }
                },
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(29)),
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Share",
                          style: TextStyle(color: Colors.black, fontSize: 17),
                        ),
                      ],
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ChatRoomForm extends StatefulWidget {
  ChatRoomForm({Key? key}) : super(key: key);

  @override
  State<ChatRoomForm> createState() => _ChatRoomFormState();
}

class _ChatRoomFormState extends State<ChatRoomForm> {
  final user = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();
  late String roomCode;

  joinVideoConferrencingRoom() async {
    String serverUrl;
    if (_formKey.currentState!.validate()) {
      serverUrl = "https://meet.jit.si";

      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      };

      if (!kIsWeb) {
        // Here is an example, disabling features for each platform
        if (Platform.isAndroid) {
          // Disable ConnectionService usage on Android to avoid issues (see README)
          featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        } else if (Platform.isIOS) {
          // Disable PIP on iOS as it looks weird
          featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        } else if (kIsWeb) {}
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomCode)
        ..serverURL = serverUrl
        ..userDisplayName = user.displayName
        ..userEmail = user.email
        ..userAvatarURL = user.photoURL
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": roomCode,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": user.displayName}
        };

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(options,
          listener: JitsiMeetingListener(
              onConferenceWillJoin: (message) {
                debugPrint("${options.room} will join with message: $message");
              },
              onConferenceJoined: (message) {
                debugPrint("${options.room} joined with message: $message");
              },
              onConferenceTerminated: (message) {
                debugPrint("${options.room} terminated with message: $message");

              },
              genericListeners: [
                JitsiGenericListener(
                    eventName: 'readyToClose',
                    callback: (dynamic message) {
                      debugPrint("readyToClose callback");
                    })
              ]));
    } else {
      print("please enter some code to join");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 90.0, right: 90),
            child: TextFormField(
              decoration: InputDecoration(hintText: "Enter Secret Code"),
              onChanged: (val) {
                roomCode = val;
                print(val);
              },
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "cant't be empty!";
                } else {
                  val = "";
                  return null;
                }
              },
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  joinVideoConferrencingRoom();
                },
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(29)),
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.4,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.video_camera,
                            size: 36,
                            color: Colors.amber,
                          ),
                          SizedBox(
                            width: 9,
                          ),
                          Text(
                            "Join",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ])),
              ),
              SizedBox(
                width: 19,
              ),
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    Share.share("$roomCode");
                  } else {
                    // ignore: avoid_print
                    print("Please provide some room code");
                  }
                },
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(29)),
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Share",
                          style: TextStyle(color: Colors.black, fontSize: 17),
                        ),
                      ],
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/*
class ChatRoomFormWeb extends StatefulWidget {
  @override
  State<ChatRoomFormWeb> createState() => _ChatRoomFormWebState();
}

class _ChatRoomFormWebState extends State<ChatRoomFormWeb> {
  final user = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();
  late String roomCode;

  joinVideoConferrencingRoom() async {
    String serverUrl;
    if (_formKey.currentState!.validate()) {
      serverUrl = "https://meet.jit.si";

      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      };

      if (!kIsWeb) {
        // Here is an example, disabling features for each platform
        if (Platform.isAndroid) {
          // Disable ConnectionService usage on Android to avoid issues (see README)
          featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        } else if (Platform.isIOS) {
          // Disable PIP on iOS as it looks weird
          featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        } else if (kIsWeb) {}
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomCode)
        ..serverURL = serverUrl
        ..userDisplayName = user.displayName
        ..userEmail = user.email
        ..userAvatarURL = user.photoURL
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": roomCode,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": user.displayName}
        };

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(options,
          listener: JitsiMeetingListener(
              onConferenceWillJoin: (message) {
                debugPrint("${options.room} will join with message: $message");
              },
              onConferenceJoined: (message) {
                debugPrint("${options.room} joined with message: $message");
              },
              onConferenceTerminated: (message) {
                debugPrint("${options.room} terminated with message: $message");
              },
              genericListeners: [
                JitsiGenericListener(
                    eventName: 'readyToClose',
                    callback: (dynamic message) {
                      debugPrint("readyToClose callback");
                    })
              ]));
    } else {
      print("please enter some code to join");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 90.0, right: 90),
            child: TextFormField(
              decoration: InputDecoration(hintText: "Enter Secret Code"),
              onChanged: (val) {
                roomCode = val;
                print(val);
              },
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "cant't be empty!";
                } else {
                  val = "";
                  return null;
                }
              },
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  joinVideoConferrencingRoom();
                },
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(29)),
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.4,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.video_camera,
                            size: 36,
                            color: Colors.amber,
                          ),
                          SizedBox(
                            width: 9,
                          ),
                          Text(
                            "Join",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ])),
              ),
              SizedBox(
                width: 19,
              ),
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    Share.share("$roomCode");
                  } else {
                    // ignore: avoid_print
                    print("Please provide some room code");
                  }
                },
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(29)),
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Share",
                          style: TextStyle(color: Colors.black, fontSize: 17),
                        ),
                      ],
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
*/
