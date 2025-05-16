import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:obdv2/pages/dashboard/dashComb_page.dart';
import 'package:obdv2/pages/dashboard/dashOx_page.dart';
import 'package:obdv2/pages/dashboard/dashboard_page.dart';
import 'package:obdv2/pages/dashboard/home_dash.dart';
import 'package:obdv2/pages/home_page.dart';
import 'package:obdv2/pages/login_page.dart';
import 'package:obdv2/pages/register_page.dart';
import 'firebase_options.dart';

//options: DefaultFirebaseOptions.currentPlatform,
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Login',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginPage());
  }
}
