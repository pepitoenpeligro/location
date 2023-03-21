import 'package:flutter/material.dart';

class RegisterHome extends StatefulWidget {
  const RegisterHome({super.key, required this.title});
  final String title;

  @override
  State<RegisterHome> createState() => _RegisterHomeState();
}

class _RegisterHomeState extends State<RegisterHome> {
  String toShow = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text(widget.title)],
        ),
      ),
    );
  }
}
