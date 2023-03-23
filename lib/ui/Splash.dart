import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:location/state/AuthState.dart';
import 'package:location/ui/Login.dart';
import 'package:location/utils/AuthStatusEnum.dart';

import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer();
    });
    super.initState();
    // print(isAndroid);
    // print(isIOS);
    // print(isWindows);
    // print(isWeb);
  }

  void timer() async {
    Future.delayed(const Duration(seconds: 2)).then((_) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/SignIn');
      // var state = Provider.of<AuthState>(context, listen: false);
      // state.getCurrentUser(context: context);
    });
  }

  Widget _body() {
    var height = 150.0;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(50),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              isIOS
                  ? const CupertinoActivityIndicator(
                      radius: 35,
                    )
                  : const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
              // Image.asset(
              //   'assets/images/icon-480.png',
              //   height: 30,
              //   width: 30,
              // )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Scaffold(
      backgroundColor: Colors.orange,
      body: state.authStatus == AuthStatus.NOT_DETERMINED
          ? _body()
          : state.authStatus == AuthStatus.NOT_LOGGED_IN
              ? const SignIn()
              : const SignIn(),
    );
  }
}
