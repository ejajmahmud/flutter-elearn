import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elearn/models/user.dart';
import 'package:elearn/screens/home.dart';
import 'package:elearn/services//registration_service.dart';
import 'package:elearn/utilities/string.dart';
import 'package:intl/intl.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  User user = User();
  Registration _reg = Registration();

  bool _remindMe = false;
  final f = new DateFormat('dd-MM-yyyy');
  bool _notLogin = false;
  bool _isLoading = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextStyle _styleWithUnderline = TextStyle(
    color: Colors.black,
    fontSize: 18,
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.solid,
  );

  TextStyle _style = TextStyle(
    color: Colors.black,
    fontSize: 18,
  );
  SizedBox _sizedBox = SizedBox(
    height: 18,
  );

  Size size;

  @override
  void initState() {
    getuserData();
    super.initState();
  }

  getuserData() async {
    FirebaseUser firebaseuser = await FirebaseAuth.instance.currentUser();
    if (firebaseuser != null) {
      if (!firebaseuser.isAnonymous) {
        final result = await Firestore.instance
            .collection('users')
            .where('email', isEqualTo: firebaseuser.email)
            .getDocuments();
        user = User(
            email: result.documents[0].data['email'],
            expirydate:
            result.documents[0].data['expirydate'].toString() ?? null,
            fullname: result.documents[0].data['fullname'],
            plan: result.documents[0].data['plan'] ?? null,
            userName: result.documents[0].data['username']);
      } else {
        _notLogin = true;
      }
    } else {
      _notLogin = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
              padding: EdgeInsets.all(5),
              child :Icon(
                Icons.arrow_back_ios,
                size: 40,
                color: Colors.white,
              )
          ),
        ),
        title: Text(
          "Account Settings",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: Container(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : _notLogin
            ? Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.blue,
              padding: EdgeInsets.all(10),
              child: Text(
                "You are not Login",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        )
            : SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.grey[300],
                  height: 50,
                  width: size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.account_box,
                          color: Colors.grey,
                        ),
                      ]),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username,
                        style: _style,
                      ),
                      Text(
                        user.userName ?? '',
                        style: _style,
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.deepOrange, height: 0),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        email,
                        style: _style,
                      ),
                      Text(
                        user.email ?? '',
                        style: _style,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.grey[300],
                  height: 50,
                  width: size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.grey,
                        ),
                      ]),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentplan,
                        style: _style,
                      ),
                      Text(
                        user.plan ?? noactiveplan,
                        style: _style,
                      ),
                    ],
                  ),
                ),
                if (user.plan != null)
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.red, width: 0),
                        )),
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          expirydate,
                          style: _style,
                        ),
                        Text(
                          f.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(user.expirydate))),
                          style: _style,
                        ),
                      ],
                    ),
                  ),
                Divider(
                  color: Colors.deepOrange,
                  height: 0,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.local_cafe,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Subscribe()));*/
                            },
                            child: Text(
                              buyaplan,
                              style: _style,
                            ),
                          ),
                        ),
                      ]),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.grey[300],
                  height: 50,
                  width: size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.grey,
                        ),
                      ]),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (user.email == null) {
                                _scaffoldKey.currentState
                                    .showSnackBar(SnackBar(
                                  content: Text("Please login"),
                                ));
                                return;
                              }
                              await _reg.forgotPassword(user.email);
                              _scaffoldKey.currentState
                                  .showSnackBar(SnackBar(
                                content: Text(resetlinkMsg +
                                    " : " +
                                    user.email),
                              ));
                            },
                            child: Text(
                              changepassword,
                              style: _style,
                            ),
                          ),
                        ),
                      ]),
                ),
                Divider(color: Colors.deepOrange, height: 0),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await _reg.signOut();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HomeScreen()));
                              },
                              child: Text(
                                "Sign Out",
                                style: _style,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.grey[300],
                  height: 50,
                  width: size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.call,
                          color: Colors.grey,
                        ),
                      ]),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text(
                        "For any support - support@elearn.com",
                        style: _style,
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.deepOrange, height: 0),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text(
                        "Terms and Condition",
                        style: _style,
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.deepOrange, height: 0),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        deleteaccount,
                        style: _style,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
