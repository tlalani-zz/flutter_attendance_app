
import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/auth.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';
import 'package:flutter_attendance/shared/cusom-text-field.dart';
import 'package:flutter_attendance/shared/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SignIn extends StatefulWidget {
  @override
  _State createState() => _State();
}


class _State extends State<SignIn> {

  String email = "";
  String password = "";
  String error = '';
  bool loading = false;
  bool introComplete;
  AuthService _authService = new AuthService();
  final _formKey = GlobalKey<FormState>();

  Future<Null> checkPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    introComplete = prefs.containsKey('intro') ? (prefs.get('intro') == true ? true : false) : false;
//    showAckDialog(context, "GOT PREFS", "Is the intro complete? : $introComplete");
  }

  bool emailInvalid(String val) {
    return !(val.length > 6 && val.split("@").length == 2);
  }

  bool isFormErrored() {
    return _formKey.currentState != null && !_formKey.currentState.validate() || email.length == 0 || password.length == 0;
  }

  @override
  void initState() {
    checkPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: loading == true
              ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Signing in and getting your user information'),
                SizedBox(height: 40.0),
                Loader(),
              ])
                : Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset("images/logo.png"),
                  ),

                  Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0)),

                  CustomTextField(
                      labelText: 'Email',
                      onChanged: (val) => (setState(() => email = val.toString().trim())),
                      validator: (val) => (emailInvalid(val) && email.isNotEmpty)? 'Please enter a valid email' : null,
                  ),

                  SizedBox(height: 20.0),

                  CustomTextField(
                      labelText: 'Password',
                      onChanged: (val) => (setState(() => password = val.toString().trim())),
                      validator: (val) => (val.length < 4 && password.isNotEmpty) ? 'Password cannot be less than 3 characters' : null,
                      isPassword: true,
                  ),

                  SizedBox(height:40.0),

                  RaisedButton(
                    color: Colors.teal[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5)
                    ),
                    onPressed: isFormErrored() ? null : submitForm,
                    child: Text('Sign In'),
                  ),

                  SizedBox(height: 40),

                  Divider(color: Colors.black45),

                  FlatButton(
                    color: Colors.grey[50],
                    child: Text('Request an Account'),
                    onPressed: () async {
                      if(await canLaunch(REGISTER_URL)) {
                        bool res = await showConfirmDialog(context,
                            "Redirecting you to: \n$REGISTER_URL\n");
                        if(res) await launch(REGISTER_URL);
                      } else {
                        showAckDialog(context, "Alert", "Couldn't open browser, please go to:\n$REGISTER_URL\nto request and account");
                      }
                    }
                  ),

                  FlatButton(
                    color: Colors.grey[50],
                    child: Text('Forgot your password?'),
                    onPressed: () async {
                      if(await canLaunch(RESET_URL)) {
                        bool res = await showConfirmDialog(context,
                            "Redirecting you to: \n$RESET_URL\n");
                        if(res) await launch(RESET_URL);
                      }
                      else
                        showAckDialog(context, "Alert", "Couldn't open browser, please go to:\n$RESET_URL\nto reset your password");
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  void submitForm() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    bool isConnected = await connectedToInternet();
    if(isConnected) {
      setState(() => loading = true);
      bool signedIn = await _authService.signIn(email, password);
      setState(() => loading = false);
      if (signedIn) {
        if(introComplete) {
          Navigator.pushNamed(context, "/select");
        } else {
          Navigator.pushNamed(context, "/intro");
        }
      } else {
        setState(() =>
        error =
        'Unable to sign in with username and password');
      }
    } else {
      showAckDialog(context, 'Alert', 'Not connected to Internet. Internet is required for this application');
    }
  }
}
