import 'package:flutter/material.dart';
import 'package:location/utils/UIButton.dart';
import 'package:location/utils/snackbar.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../state/AuthState.dart';
import '../utils/Loader.dart';

class SignIn extends StatefulWidget {
  final VoidCallback? loginCallback; //!

  const SignIn({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late Loader loader;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    loader = Loader();
    super.initState();
  }

  Widget _body(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          alignment: Alignment.center,
          // color: Colors.amber,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  // color: Colors.red,
                  child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Visibility(
                          visible: true,
                          child: Lottie.network(
                              'https://assets6.lottiefiles.com/private_files/lf30_iraugwwv.json')))),
              const SizedBox(height: 1),
              _entryField('Enter email', controller: _emailController),
              _entryField('Enter password',
                  controller: _passwordController, isPassword: true),
              _emailLoginButton(context),
              const SizedBox(
                height: 30,
              ),
              // const SizedBox(height: 1),
              _registerPageButton(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entryField(String hint,
      {required TextEditingController controller, bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.deepPurple)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _labelButton(String title, {Function? onPressed}) {
    return TextButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      child: Text(
        title,
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _emailLoginButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 35),
      child: UIButton(
        label: "Login",
        onPressed: _emailLogin,
        borderRadius: 30,
      ),
    );
  }

  Widget _registerPageButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 35),
      child: UIButton(
          borderRadius: 30,
          label: "Register",
          onPressed: () {
            Navigator.of(context).pushNamed('/SignUp');
          }),
    );
  }

  void _emailLogin() {
    var state = Provider.of<AuthState>(context, listen: false);
    if (state.isWorking) {
      return;
    }
    loader.showLoader(context);
    var isValid = true;
    // var isValid = Utility.validateCredentials(
    //     context, _emailController.text, _passwordController.text);
    if (isValid) {
      state
          .signIn(_emailController.text, _passwordController.text,
              context: context)
          .then((status) {
        if (state.user != null) {
          print("Login success");
          Utils.customSnackBar(context, 'Login Success');
          print("El token que recojo es:");
          print(state.user!.notificationToken);

          state.getCurrentUser(context: context).then((status) {
            loader.hideLoader();
            Navigator.pop(context);
            // widget.loginCallback!();
            Navigator.of(context).pushNamed('/Home');
          }).catchError((error) {
            print("Hubo error");
          });

          // loader.hideLoader();
          // Navigator.pop(context);
          //   // widget.loginCallback!();
          //   Navigator.of(context).pushNamed('/Home');
        } else {
          // cprint('Unable to login', errorIn: '_emailLoginButton');
          loader.hideLoader();
          print("Login not success");
          print(state.toString());
          Utils.customSnackBar(context, 'Login Unsuccess');
        }
      });
    }
    // else {
    //   loader.hideLoader();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sign in', style: const TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
}
