import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elearn/models/questions.dart';
import 'package:elearn/screens/question_view.dart';

class QuestionList extends StatefulWidget {
  final int id;
  QuestionList({Key key, this.id}) : super(key: key);

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  TextEditingController _searchController = TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  List<String> _questionList = [];

  List<Question> _questions;
  List<Question> questions;
  double width;

  @override
  void initState() {
    super.initState();
    getQuestions();
    //  width = MediaQuery.of(context).size.width;
  }

  getQuestions() async {
    questions = await Firestore.instance
        .collection('iqanda')
        .where("qtopicid", isEqualTo: widget.id)
        .getDocuments()
        .then((value) {
      return value.documents.map((e) {
        _questionList.add(e.data['qquestions']);
        return Question.fromJson(e.data);
      }).toList();
    });
    _questions = questions;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      "assets/images/back.svg",
                      height: 40,
                      width: 40,
                    ),
                  ),
                  Expanded(
                    child: SimpleAutoCompleteTextField(
                      key: key,
                      controller: _searchController,
                      suggestions: _questionList,
                      textChanged: (value) => setState(() {
                        var searchvalue =
                        value.replaceAll(new RegExp(r'[^\w\s]+'), '');
                        if (searchvalue.trim() == null || searchvalue == ' ') {
                          _questions = questions;
                        } else {
                          _questions = questions
                              .where((i) => i.qquestions
                              .toUpperCase()
                              .contains(searchvalue.toUpperCase()))
                              .toList();
                        }
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Search keywords eg- Threads, Integer ...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        prefixIcon: Icon(Icons.search),
                        //suffixIcon: Icon(Icons.mic),
                      ),
                      clearOnSubmit: false,
                      textSubmitted: (value) => setState(() {
                        var searchValue =
                        value.replaceAll(new RegExp(r'[^\w\s]+'), '');
                        if (searchValue == null || searchValue == ' ') {
                          _questions = questions;
                        } else {
                          _questions = questions
                              .where((i) => i.qquestions
                              .toUpperCase()
                              .contains(searchValue.toUpperCase()))
                              .toList();
                        }
                      }),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              _questions == null
                  ? CircularProgressIndicator()
                  : Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: () {
                        print(
                            "diffi ${questions.indexOf(_questions[index])}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionFullview(
                              index: questions.indexOf(_questions[index]),
                              list: questions,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Material(
                          elevation: 5,
                          child: ListTile(
                            //trailing: Text(_questions[index].qdifficulty),
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (questions[index].qdifficulty=="Mid"?Colors.blue:questions[index].qdifficulty=="Expert"?Colors.redAccent:questions[index].qdifficulty=="Senior"?Colors.brown:Colors.green),
                              ),
                              child: Center(
                                child: Text(
                                  _questions[index].qquestions[0],
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            title: Text(
                              _questions[index].qquestions,
                              style: TextStyle(fontSize:  MediaQuery.of(context).size.width / 30),
                              overflow: TextOverflow.ellipsis,
                            ),
                            /*subtitle: Text(
                                    _questions[index].qanswer,
                                    style: TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,

                                  ),*/
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}