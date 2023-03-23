import 'package:flutter/material.dart';
import 'package:location/utils/UIButton.dart';
import 'package:location/utils/snackbar.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../utils/Loader.dart';
import '../state/AuthState.dart';

class SignUp extends StatefulWidget {
  final VoidCallback? loginCallback; //!
  const SignUp({Key? key, this.loginCallback}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late Loader loader;
  String toShow = "";

  @override
  void initState() {
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    loader = Loader();
    super.initState();
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

  Widget _registerButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 35),
      child: UIButton(
        label: "Register",
        onPressed: _doRegister,
        borderRadius: 30,
      ),
    );
  }

  void _doRegister() {
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
          .signUp(_usernameController.text, _emailController.text,
              _passwordController.text,
              context: context)
          .then((status) {
        if (status == 200) {
          Utils.customSnackBar(context, '[SignUp] Success');

          Navigator.pop(context);
          Navigator.of(context).pushNamed('/Home');

          state.getCurrentUser(context: context).then((status) {
            loader.hideLoader();
            Navigator.pop(context);
            // widget.loginCallback!();
            Navigator.of(context).pushNamed('/Home');
          }).catchError((error) {
            Utils.customSnackBar(
                context, '[SignUp] error getting current user');
          });
        } else {
          loader.hideLoader();
          Utils.customSnackBar(context, '[SignUp] your credentials are wrong');
        }
      });
    }
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
              _entryField('Enter username', controller: _usernameController),
              _entryField('Enter email', controller: _emailController),
              _entryField('Enter password',
                  controller: _passwordController, isPassword: true),
              _registerButton(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SignUp"),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
}
