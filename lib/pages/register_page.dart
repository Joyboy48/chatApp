import 'dart:io';
import 'package:firebase_chat_app/models/user_profile.dart';
import 'package:firebase_chat_app/services/auth_service.dart';
import 'package:firebase_chat_app/services/media_service.dart';
import 'package:firebase_chat_app/services/navigation_service.dart';
import 'package:firebase_chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../const.dart';
import '../services/alert_service.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;
  String? email, password, name;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();

  }

  File? selectedImage;
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
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 20.0,
      ),
      child: Column(
        children: [
          _headerText(),
          if (!isLoading) _registerForm(),
          if (!isLoading) _loginAccountLink(),
          if (isLoading)
            Expanded(
                child: Center(
              child: CircularProgressIndicator(),
            ))
        ],
      ),
    ));
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
              "Let's get going!",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            Text(
              "Register an account using the form below",
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

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.04,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _profilepicfield(),
            SizedBox(
              height: 10,
            ),
            CustomFormField(
                hintText: "Name",
                height: MediaQuery.sizeOf(context).height * 0.10,
                validationRegEx: NAME_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    name = value;
                  });
                }),
            CustomFormField(
                hintText: "Email",
                height: MediaQuery.sizeOf(context).height * 0.10,
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    email = value;
                  });
                }),
            CustomFormField(
                hintText: "Password",
                height: MediaQuery.sizeOf(context).height * 0.10,
                validationRegEx: PASSWORD_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    password = value;
                  });
                },
            obscureText: true,),
            _registerButton(),

          ],
        ),
      ),
    );
  }

  Widget _profilepicfield() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.45,
      height: MediaQuery.sizeOf(context).height * 0.05,
      child: MaterialButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_registerFormKey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _registerFormKey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.UploadUserProfilePic(
                    file:selectedImage!,
                    uid:_authService.user!.uid);
                if(pfpURL != null){
                  await _databaseService.CreateUserProfile(userProfile:
                  UserProfile(uid: _authService.user!.uid,
                      name: name,
                      pfpURL: pfpURL));
                  _alertService.showToast(text: "User registered successfully!",
                  icon: Icons.check);
                  _navigationService.goBack();
                  _navigationService.pushReplacementNamed("/home");
                }else{
                  throw Exception("Unable to upload the user profile picture");
                }
              }else{
                throw Exception("Unable to register the user");
              }
            }
          } catch (e) {
            print(e);
            _alertService.showToast(text:
            "Failed to register, Please try again",
            icon: Icons.error);
          }
          setState(() {
            isLoading = false;
          });
        },
        color: Colors.blue,
        child: const Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLink() {
    return Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(fontSize: 20),
        ),
        GestureDetector(
          onTap: () {
            _navigationService.goBack();
          },
          child: const Text(
            "login",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        )
      ],
    ));
  }
}
