import 'package:firebase_chat_app/const.dart';
import 'package:firebase_chat_app/services/alert_service.dart';
import 'package:firebase_chat_app/services/auth_service.dart';
import 'package:firebase_chat_app/services/navigation_service.dart';
import 'package:firebase_chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  String? email, password;
  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(
          children: [
            _headerText(),
            _loginForm(),
            _createAccountLink(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, Welcome Back!",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            Text(
              " Nice to see you again 😁",
              style: (TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.35,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.01,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomFormField(
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.10,
              validationRegEx: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomFormField(
              hintText: "Password (Test123!)",
              height: MediaQuery.sizeOf(context).height * 0.10,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.45,
      height: MediaQuery.sizeOf(context).height * 0.05,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email!, password!);
            print(result);
            if (result) {
              _navigationService.pushReplacementNamed("/home");
            } else {
              _alertService.showToast(
                  text: "Failed to login, Please try again!",
                  icon: Icons.error);
            }
          }
        },
        color: Colors.blue,
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
          
        ),
      ),
    );
  }

  Widget _createAccountLink() {
    return  Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
         const Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 20),
        ),
        GestureDetector(
          onTap:(){
            _navigationService.pushNamed("/register");
          } ,
          child: const Text(
            "Sign up",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        )
      ],
    ));
  }
}
