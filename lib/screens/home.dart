import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:elearn/apis/dataapis.dart';
import 'package:elearn/models/itopics.dart';
import 'package:elearn/models/user.dart';
import 'package:elearn/screens/question_list.dart';
import 'package:elearn/screens/settings.dart';
import 'package:elearn/screens/signin_screen.dart';
import 'package:elearn/services/registration_service.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var dev_width;
  var dev_height;

  bool showDropDown = false;
  bool isGuest = true;
  Registration _registration = Registration();
  User user = User();

  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  List<Itopics> _iconData = [];
  List<String> _topics = [];

  @override
  void initState() {
    super.initState();
    _iconData = iconData;
  }

  //Function show dropdown
  showDropDownItems() {
    setState(() {
      showDropDown = !showDropDown;
    });
  }


//Sign out
  signout() async {
    // Registration _registration = Registration();
    await _registration.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    dev_width = MediaQuery.of(context).size.width;
    dev_height = MediaQuery.of(context).size.height;
    return new WillPopScope(
      child: GestureDetector(
        child: Scaffold(
          drawer: null,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: dev_height * 2 / 7,
                  width: dev_width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.9), BlendMode.dstATop),
                              image: AssetImage('assets/images/home_image.png'),
                              fit: BoxFit.cover,
                            )),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 20,
                        width: dev_width - 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset:
                                Offset(0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: SimpleAutoCompleteTextField(
                            key: key,
                            suggestions: _topics,
                            textChanged: (value) => setState(() {
                              var searchvalue =
                              value.replaceAll(new RegExp(r'[^\w\s]+'), '');
                              if (searchvalue.trim() == null ||
                                  searchvalue == ' ') {
                                _iconData = iconData;
                              } else {
                                _iconData = iconData
                                    .where((i) => i.tname
                                    .toUpperCase()
                                    .contains(searchvalue.toUpperCase()))
                                    .toList();
                              }
                            }),
                            decoration: const InputDecoration(
                              labelText: 'What would you like to Practice ?',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(0),
                              prefixIcon: Icon(Icons.search),
                              //suffixIcon: Icon(Icons.mic),
                            ),
                            textSubmitted: (value) => setState(() {
                              var search_value =
                              value.replaceAll(new RegExp(r'[^\w\s]+'), '');
                              print(search_value);
                              if (search_value == null || search_value == ' ') {
                                _iconData = iconData;
                              } else {
                                _iconData = iconData
                                    .where((i) => i.tname
                                    .toUpperCase()
                                    .contains(search_value.toUpperCase()))
                                    .toList();
                              }
                            }),
                            keyboardType: TextInputType.text,

                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                           showDropDownItems();
                          },
                          child :Icon(
                            Icons.account_box,
                            size: dev_width / 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (showDropDown)
                        Positioned(
                          right: 0,
                          top: 60,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showDropDown = false;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      isGuest
                                          ? 'Guest User'
                                          : user?.email ?? '',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                              .size
                                              .width /
                                              25),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showDropDown = false;
                                    });
                                   Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Setting()));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      "Setting",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                              .size
                                              .width /
                                              25),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: signout,
                                    child: Text(
                                      isGuest ? "Sign Up/In" : "Sign Out",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                              .size
                                              .width /
                                              25),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  height: dev_height * 5 / 7 - 40,
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: _iconData.length > 0
                      ? GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    children: _iconData.map((data) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QuestionList())
                          );
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                                decoration: ShapeDecoration(
                                  //color: Colors.amber,
                                  //shadows: ,
                                    shape: CircleBorder()),
                                child: Container(
                                  margin: EdgeInsets.all(3.0),
                                  width: (dev_width/8),
                                  height: (dev_width/8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/icons/' + data.ticon),
                                        fit: BoxFit.cover),
                                  ),
                                )),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              data?.tname == null || data?.tname == ''
                                  ? "Icon"
                                  : data.tname.toUpperCase(),
                              overflow: TextOverflow
                                  .ellipsis, // added to maintain overflow
                              style: TextStyle(
                                fontSize: dev_width / 40,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  )
                      : Container(),
                )
              ],
            ),
          ),
        ),
      ),
      onWillPop: null,
    );
  }
}