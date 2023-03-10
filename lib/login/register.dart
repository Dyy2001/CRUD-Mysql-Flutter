import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:d_view/d_view.dart';
import 'package:d_input/d_input.dart';
import 'package:http/http.dart' as http;
import 'package:d_info/d_info.dart';
import 'package:task_crudmysql/homepage.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  register(BuildContext context) async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      DInfo.toastError('Please fill all the fields');
      return;
    }

    String url = 'http://192.168.1.27/task_crudmysql/user/register.php';
    var response = await http.post(Uri.parse(url), body: {
      'username': usernameController.text,
      'password': passwordController.text
    });
    Map responseBody = jsonDecode(response.body);
    if (responseBody['success']) {
      DInfo.toastSuccess('Success register');
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      if (responseBody['message'] == 'username') {
        DInfo.toastError('username sudah ada');
      } else {
        DInfo.toastError('Failed Register: ${responseBody['message']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Register Page",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24),
            ),
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
                onPressed: () => register(context),
                child: Text("Register"),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
