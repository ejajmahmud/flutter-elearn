import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:elearn/models/user.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'userprofile_firestore.dart';

class Registration {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    hostedDomain: "",
    clientId: "",
  );
  final UserFireStore _userFireStore = UserFireStore();
  User firebaseUserToUser(
      {String userName, String email, String gender, String fullname}) {
    return User(
        email: email ?? '',
        gender: gender ?? '',
        userName: userName ?? '',
        fullname: fullname ?? '');
  }

  getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    User name = User();
    print("user ${user.email}");
    var value = await Firestore.instance
        .collection('users')
        .where("email", isEqualTo: user.email)
        .getDocuments();

    name = firebaseUserToUser(
      email: value.documents[0]['email'],
      userName: value.documents[0]['username'],
    );
    print(" in get user ${name.userName ?? ''}");
    return name;
  }

  //stream of User
  /* Stream<User> get user {
    return _auth.onAuthStateChanged.map();
  }*/

  //Google sign in
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
      await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final AuthResult authResult =
      await _auth.signInWithCredential(credential);

      final FirebaseUser currentUser = authResult.user;
      User fuser = firebaseUserToUser(
          email: currentUser.email,
          userName: currentUser.displayName,
          fullname: currentUser.displayName);

      await _userFireStore.addUser(authResult.user.uid,fuser.toJson());
      await _googleSignIn.signOut();
      print("google ${fuser.fullname}");
      return fuser;
    } catch (e) {
      print("error $e");
    }
  }

  //facebook login
  signInWithFacebook() async {
    try {
      final facebookLogin = FacebookLogin();
      FacebookLoginResult _fresult = await facebookLogin.logIn(['email']);
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: _fresult.accessToken.token,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      if (user != null) {
        User cUser = firebaseUserToUser(
            userName: user.displayName ?? '',
            email: user.email ?? '',
            gender: "",
            fullname: "");
        //await _userFireStore.addUser(cUser.toJson());
        await _userFireStore.addUser(user.uid,cUser.toJson());
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
  }

  // firebase sign in Anonymously
  Future<User> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      return firebaseUserToUser();
    } catch (e) {
      print("ERROR: "+e.toString());
      return null;
    }
  }

  // forgot password
  Future forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future signInWithIdPassword({String email, String password}) async {
    try {
      AuthResult newUser  = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      User user = firebaseUserToUser(email: email);
      if (!newUser.user.isEmailVerified)
      {
        newUser.user.sendEmailVerification();
        return "not_verified";
      }
      return "success";
    } catch (e) {

      print("error "+e.message);
      return e.message.toString();
    }
  }

  Future signUpWithIdPassword({
    String email,
    String password,
    String username,
    String gender,
    String fullname,
  }) async {
    try {
      print("Inside signUpWithIdPassword");
      AuthResult newUser =await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      var firebaseUser = newUser.user;
      await firebaseUser.sendEmailVerification();
      User user = firebaseUserToUser(
          userName: username, email: email, gender: gender, fullname: fullname);
      await _userFireStore.addUser(newUser.user.uid,user.toJson());
      return "success";

    } catch (e) {
      print("ERROR: "+e.toString());
      return e.message;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print("ERROR: "+e.toString());
      return null;
    }
  }

}
