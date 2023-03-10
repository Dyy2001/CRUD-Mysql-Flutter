import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:d_view/d_view.dart';
import 'package:d_input/d_input.dart';
import 'package:http/http.dart' as http;
import 'package:d_info/d_info.dart';
import 'package:task_crudmysql/homepage.dart';
import 'package:task_crudmysql/login/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginStatus { notSignin, signIn }

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginStatus _loginStatus = LoginStatus.notSignin;
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  login(BuildContext context) async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      DInfo.toastError('Please fill all the fields');
      return;
    }

    String url = 'http://192.168.1.27/task_crudmysql/user/login.php';
    var response = await http.post(Uri.parse(url), body: {
      'username': usernameController.text,
      'password': passwordController.text
    });
    Map responseBody = jsonDecode(response.body);
    if (responseBody['success']) {
      DInfo.toastSuccess('Success login');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', usernameController.text);
      setState(() {
        _loginStatus = LoginStatus.signIn;
      });
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => HomePage( signOut: _si,)));
    } else {
      DInfo.toastError('Failed Login');
    }
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 0);
      preferences.commit();
      _loginStatus = LoginStatus.notSignin;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignin:
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login Page",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24),
                ),
                // DView.textTitle("Login Page", style: TextStyle(color: Colors.blue)),
                DView.spaceHeight(),
                DInput(
                  controller: usernameController,
                  hint: 'Username',
                ),
                DView.spaceHeight(),
                DInputPassword(
                  controller: passwordController,
                  hint: 'Password',
                  obsecureCharacter: '*',
                ),
                DView.spaceHeight(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => login(context),
                    child: Text("Login"),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black)),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case LoginStatus.signIn:
        return HomePage(
          signOut,
        );
    }
  }
}
