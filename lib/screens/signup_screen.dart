import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elearn/models//user.dart';
import 'package:elearn/screens/home.dart';
import 'package:elearn/screens/signin_screen.dart';
import 'package:elearn/services/registration_service.dart';
import 'package:elearn/utilities/constants.dart';
import 'package:elearn/utilities/string.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  String _fullName;
  String _userName;
  String _email;
  String _password;
  String _gender="na";
  Size size;
  bool _isLoading = false;
  Registration _registration = Registration();
  final tenPixelWidthSizedBox = SizedBox(
    width: 10,
  );
  final tenPixelheightSizedBox = SizedBox(
    height: 10,
  );

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffold,
      body: Stack(
        children: [
          _isLoading
              ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : Container(),
          Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      padding: EdgeInsets.only(top: 20),
                      color: Colors.blue,
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child :Icon(
                                Icons.arrow_back_ios,
                                size: 40,
                                color: Colors.white,
                              )

                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Sign Up    ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - 70,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*   TextFormField(
                              style: kHintTextStyleBlack,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.only(top: 14.0),
                                hintText: 'Full Name',
                                hintStyle: kHintTextStyleBlack,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "please enter Full Name";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _fullName = value;
                              },
                            ),
                            tenPixelheightSizedBox,*/
                            TextFormField(
                              style: kHintTextStyleBlack,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.only(top: 14.0),
                                hintText: username,
                                hintStyle: kHintTextStyleBlack,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return usernameError;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _userName = value;
                              },
                            ),
                            tenPixelheightSizedBox,
                            TextFormField(
                              style: kHintTextStyleBlack,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.only(top: 14.0),
                                hintText: email,
                                hintStyle: kHintTextStyleBlack,
                              ),
                              validator: (value) {
                                value = value.trim();
                                Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern);
                                return (!regex.hasMatch(value))
                                    ? emailError
                                    : null;
                              },
                              onSaved: (value) {
                                _email = value;
                              },
                            ),
                            tenPixelheightSizedBox,
                            TextFormField(
                              obscureText: true,
                              style: kHintTextStyleBlack,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.only(top: 14.0),
                                hintText: password,
                                hintStyle: kHintTextStyleBlack,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return passwordError;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _password = value.trim();
                              },
                              onSaved: (value) {
                                _password = value;
                              },
                            ),
                            tenPixelheightSizedBox,
                            TextFormField(
                              obscureText: true,
                              style: kHintTextStyleBlack,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.only(top: 14.0),
                                hintText: retypepassword,
                                hintStyle: kHintTextStyleBlack,
                              ),
                              validator: (value) {
                                if (value.isEmpty ||
                                    value.trim() != _password.trim()) {
                                  return retypepassworderror;
                                }
                                return null;
                              },
                            ),
                            tenPixelheightSizedBox,
                            /*  Text(
                              "Gender",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: "Male",
                                  groupValue: _gender,
                                  activeColor: Colors.pink,
                                  onChanged: (String value) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  },
                                ),
                                Text("Male"),
                                tenPixelWidthSizedBox,
                                Radio(
                                  value: "Female",
                                  groupValue: _gender,
                                  activeColor: Colors.pink,
                                  onChanged: (String value) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  },
                                ),
                                Text("Female"),
                              ],
                            ),
                            if (_gender == "NULL")
                              Text(
                                "Please select gender",
                                style: TextStyle(color: Colors.red),
                              ),*/
                            tenPixelheightSizedBox,
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: () async {
        if (_isLoading) {
          return;
        }
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          setState(() {
            _isLoading = true;
          });
          String result = await _registration.signUpWithIdPassword(
              email: _email,
              password: _password,
              username: _userName,
              gender: _gender,
              fullname: _fullName);
          if (result == "success") {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginScreen()));
          }
          else {
            final snackBar = SnackBar(content: Text(result),duration: Duration(seconds: 20),);
            _scaffold.currentState.showSnackBar(snackBar);

          }
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Container(
        height: 50,
        width: size.width,
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            'REGISTER',
            style: kLabelStyle,
          ),
        ),
      ),
    );
  }
}
