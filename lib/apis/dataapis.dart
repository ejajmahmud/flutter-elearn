import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearn/models/itopics.dart';

List<Itopics> iconData = [];

class DataApi {
  //var FireDB = Firestore.instance;
  // get the data from itopics data from firebase
  Future<List<Itopics>> getMenu() async {
    try {
      print("--- getting the icons from firebase ---");
      List<Itopics> _itopics = [];
      var data = await Firestore.instance.collection('itopics').getDocuments();
      data.documents.forEach((doc) {
        print("--- adding itopics ---- ");
        Itopics itopics = Itopics.fromJson(doc.data);
        _itopics.add(itopics);
      });
      iconData = _itopics;
    } catch(e)
    {
      print("error" +  e.toString());
    }
  }
}