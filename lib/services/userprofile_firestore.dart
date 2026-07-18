import 'package:cloud_firestore/cloud_firestore.dart';

class UserFireStore {
  Future addUser(String uid,Map<String, dynamic> _user) async {
    var isAlredyUser = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: _user['email'])
        .getDocuments();
    if (!(isAlredyUser.documentChanges.length > 0)) {
      await Firestore.instance.collection('users').document(uid).setData(_user);
      print("added login");
    }
  }
}
