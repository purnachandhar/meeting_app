// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:video_call/pages/home_page.dart';
import 'package:video_call/pages/logical_home_page.dart';
import 'package:video_call/pages/login_page.dart';
import 'package:video_call/provider/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){
    await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyDci2mpOPPwpk8GmDLUzjpRl0OJurx_KXM",
          appId:  "1:860749772223:web:b3a31eb257e59be4519d0a",
          authDomain: "testcalliing.firebaseapp.com",
          messagingSenderId: "G-K58E01THLC",
          projectId: "testcalliing",)
    );
  }
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VideoConferrence',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: GoogleFonts.lato().fontFamily,
        ),
        home: const SpScrn(),
      ),
    );
  }
}

class SpScrn extends StatelessWidget {
  const SpScrn({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashScreen(
        seconds: 2,
        backgroundColor: Colors.black,
        navigateAfterSeconds: const LogicalHomePage(),
        photoSize: 120,
        styleTextUnderTheLoader: const TextStyle(),
        loaderColor: Colors.pink,
      ),
    );
  }
}
