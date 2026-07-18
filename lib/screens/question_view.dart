import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearn/datastore/userdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elearn/models/questions.dart';

class QuestionFullview extends StatefulWidget {
  final List<Question> list;
  final int index;

  QuestionFullview({
    Key key,
    this.list,
    this.index,
  }) : super(key: key);

  @override
  _QuestionFullviewState createState() => _QuestionFullviewState();
}

class _QuestionFullviewState extends State<QuestionFullview> {
  int index;
  bool isDayMode = true;
  UserData _userData = UserData();
  double width = 20;
  double fontSizeRatio =25;
  int questionViewed = 0;
  bool _isSubscriber = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final snackBar =
  SnackBar(content: Text('You Reached the maximum limit of free question views, please subscribe.'),duration: Duration(seconds: 5));
  final snackBarForSignIn = SnackBar(content: Text('Please sign In'),duration: Duration(seconds: 5));
  bool _isLogin = false;

  @override
  void initState() {
    index = widget.index;
    getUser();
    getPrefrenceMode();
    //_isUserSubscibe();
    super.initState();
  }

  getUser() async {
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    if (_user != null && (!_user.isAnonymous)) {
      setState(() {
        _isLogin = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      width = MediaQuery.of(context).size.width;
      fontSizeRatio = 25;
    });
  }

  getPrefrenceMode() async {
    _userData.getMode().then((value) {
      setState(() {
        print("value $value");
        isDayMode = value;
      });
    });
  }

  checkQuestionLimit() async {
    questionViewed = await _userData.setQuestionViewed();
    print("questionViewed $questionViewed");
    print("check $_isSubscriber");
    if (questionViewed >= 5 && (!_isLogin)) {
      _scaffoldKey.currentState.showSnackBar(snackBarForSignIn);
      await Future.delayed(Duration(seconds: 1));
      /*Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));*/
    }
    if (questionViewed >= 15 && (!_isSubscriber) && (_isLogin)) {
      _scaffoldKey.currentState.showSnackBar(snackBar);
      await Future.delayed(Duration(seconds: 1));
      /*Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Subscribe()));*/
    }
  }

  List<TextSpan> buildQuestionView() {
    List listings = new List<TextSpan>();
    var sections = widget.list[index].qanswer.split("\n");
    var answer = widget.list[index].qanswer.split(" ");

    final _readerText = TextStyle(

        fontFamily: 'OpenSans',
        fontSize : width / fontSizeRatio,
        color: isDayMode ? Colors.black : Colors.white
    );

    final _readerText_highlight = TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'OpenSans',
        fontSize : width / fontSizeRatio,
        color: isDayMode ? Colors.blue : Colors.blueAccent
    );

    final _readerText_code = TextStyle(
        fontFamily: 'OpenSans',
        fontSize : width / (fontSizeRatio+5),
        color: isDayMode ? Colors.redAccent : Colors.greenAccent
    );

    for (int i = 0; i < sections.length; i++) {
      print(sections[i]);
      if (sections[i].contains("```")) // check for ´´´
          {
        var code = "";
        //append sections till next occurence of ```
        while (i < sections.length) {
          code = code + sections[i] + "\n";
          i++;
          if (sections[i].contains("```")) break;
        }
        listings.add(new TextSpan(
            text: code.replaceAll("```", "") + "\n\n",
            style: _readerText_code));
      }
      else if (sections[i].contains("**") || sections[i].contains("`")) // check for **
       {
        var words = (sections[i] + "\n\n").split(" ");
        for (int j = 0; j < words.length; j++) {
          if (words[j].contains("**") || words[j].contains("`")) // check for **
              {
                words[j] = words[j].replaceAll("**", "");
                words[j] = words[j].replaceAll("`", "");
                listings.add(new TextSpan(
                    text: words[j] + " ",
                    style: _readerText_highlight));
          } else
            listings.add(new TextSpan(
                text: words[j] + " ", style: _readerText));
        }
      } else
        listings.add(new TextSpan(
            text: sections[i] + "\n\n",
            style: _readerText));
    }
    return listings;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: null,
      child: Theme(
        data: isDayMode ? ThemeData.light() : ThemeData.dark(),
        child: SafeArea(
          child: Scaffold(
            key: _scaffoldKey,
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child :Icon(
                          Icons.arrow_back_ios,
                          size: width / 20,
                          color: isDayMode ? Colors.black : Colors.white,
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (index > 0 ) {
                                  await checkQuestionLimit();
                                  setState(() {
                                    index = index - 1;
                                  });
                                }
                              },
                              child: Icon(
                                Icons.skip_previous,
                                size: width / 20,
                              ),
                            ),
                            SizedBox(width: width / 50),
                            GestureDetector(
                              onTap: () async {
                                if (index < widget.list.length - 1) {
                                  await checkQuestionLimit();
                                  setState(() {
                                    index = index + 1;
                                  });
                                }
                              },
                              child: Icon(
                                Icons.skip_next,
                                size: width / 20,
                              ),
                            ),
                            SizedBox(width: width / 20),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  fontSizeRatio = fontSizeRatio-2;
                                });
                              },
                              child: Icon (
                                Icons.add_circle,
                                size: width / 20,
                              ),
                            ),
                            SizedBox(width: width / 50),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  fontSizeRatio = fontSizeRatio+2;
                                });
                              },
                              child: Icon (
                                Icons.remove_circle,
                                size: width / 20,
                              ),
                            ),
                            SizedBox(width: width / 20),
                            GestureDetector(
                                onTap: () async {
                                  await _userData.setMode(!isDayMode);
                                  setState(() {
                                    isDayMode = !isDayMode;
                                  });
                                },
                                child :Icon(
                                  Icons.lightbulb_outline,
                                  size:  width / 20,
                                  color: isDayMode ? Colors.black : Colors.white,
                                )
                            ),
                          ]
                      )
                    ],
                  ),
                ),
                Container(
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.list[index].qquestions,
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: width / 30,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              color: Colors.red,
                              thickness: 2,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: RichText(
                                  text: TextSpan(
                                    children: buildQuestionView(),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
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
