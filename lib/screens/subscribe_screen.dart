import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elearn/screens//home.dart';
import 'package:elearn/models/user.dart';
import 'package:elearn/utilities/string.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Subscribe extends StatefulWidget {
  @override
  _SubscribeState createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> {
  StreamSubscription<List<PurchaseDetails>> _subscription;
  final databaseReference = Firestore.instance;
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  User _user = User();
  bool isanonymouse = true;
  bool isLoading = true;
  final user = FirebaseAuth.instance;
  bool isAnySubscribe = false;

  @override
  void initState() {
    getCurrentUserDetails();
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) async {
      _listenToPurchaseUpdated(purchaseDetailsList);

      await _getPastPurchases();
      await getCurrentUserDetails();
      //Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
    super.initState();
  }

  getCurrentUserDetails() async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    if (fUser != null) {
      if (!fUser.isAnonymous) {
        var value = await Firestore.instance
            .collection('users')
            .where("email", isEqualTo: fUser?.email ?? '')
            .getDocuments();
        _user = User(
          email: value.documents[0].data['email'],
          userName: value.documents[0].data['username'],
          fullname: value.documents[0].data['fullname'],
          plan: value.documents[0].data['plan'] ?? null,
          // changed
          expirydate: value.documents[0].data['expirydate'] == null
              ? null
              : value.documents[0].data['expirydate'].toString(),
        );
        //added
        if (_user.expirydate != null) {
          DateTime _expire = DateTime.fromMillisecondsSinceEpoch(
              int.parse(_user.expirydate ?? '0'));
          if (DateTime.now().compareTo(_expire).isNegative) {
            isAnySubscribe = true;
          }
        }
        isanonymouse = false;
      }
    }
    isLoading = false;
    setState(() {});
  }

  TextStyle _style = TextStyle(
    color: Colors.black,
    fontSize: 18,
  );

  updateCurrentPlan(String planid, var expiryDate, String purchaseId) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    //added
    var ispastpurchase = await Firestore.instance
        .collection('purhcase')
        .where('purchaseid', isEqualTo: purchaseId)
        .getDocuments();
    if (ispastpurchase.documents.length > 0) {
      return;
    }
    final result = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .getDocuments();
    await Firestore.instance
        .collection('users')
        .document(result.documents[0].documentID)
        .updateData({"plan": planid});
    await Firestore.instance
        .collection('users')
        .document(result.documents[0].documentID)
        .updateData({"expirydate": expiryDate});
    //added
    await Firestore.instance.collection('purhcase').add(
      {
        'purchaseid': purchaseId,
        'plan': planid,
        'expirydate': expiryDate,
        'email': user.email
      },
    );
  }

  _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        log("In app Pending......");
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        log("In app ERROR......");
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        if (Platform.isAndroid) {
          print("Android product id ${purchaseDetails.productID}");
          await InAppPurchaseConnection.instance
              .consumePurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }

        Duration _add;
        if (_user != null && !isanonymouse) {
          switch (purchaseDetails.productID) {
            case 'icafe':
              _add = Duration(days: 90);
              break;
            case 'icafe_premium':
              _add = Duration(days: 365);
              break;
            case 'icafe_standard':
              _add = Duration(days: 180);
          }
          var _purchase = DateTime.now();
          _purchase = DateTime.now().add(_add);
          await updateCurrentPlan(purchaseDetails.productID,
              _purchase.millisecondsSinceEpoch, purchaseDetails.purchaseID);
          _scaffold.currentState
              .showSnackBar(SnackBar(content: Text("Purchase successful")));
        }
      } else {
        log("In app no idea somewhere else......");
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  purchaseItem(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam =
    PurchaseParam(productDetails: productDetails);
    if ((Platform.isIOS &&
        productDetails.skProduct.subscriptionPeriod == null) ||
        (Platform.isAndroid && productDetails.skuDetail.type == SkuType.subs)) {
      await InAppPurchaseConnection.instance
          .buyConsumable(purchaseParam: purchaseParam);
    } else {
      await InAppPurchaseConnection.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<List<ProductDetails>> retrieveProducts() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    if (!available) {
      return null;
    } else {
      Set<String> _kIds = <String>[
        'icafe_standard',
        'icafe_premium',
        'icafe',
      ].toSet();
      final ProductDetailsResponse response =
      await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
      return new Future(() => response.productDetails);
    }
  }

  final spcaer = SizedBox(
    height: 5,
  );

  Widget buildProductRow(ProductDetails productDetail) {
    String title = 'None';
    double price;
    int months;
    price = double.parse(productDetail.price.substring(1).replaceAll(',', ''));
    switch (productDetail.id) {
      case 'icafe':
        title = 'Basic';
        months = 3;
        break;
      case 'icafe_premium':
        title = 'Premium';
        months = 12;
        break;
      case 'icafe_standard':
        title = 'Platinum';
        months = 6;
        break;
    }
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          children: <Widget>[
            new Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      title,
                      style: _style,
                    ),
                    spcaer,
                    new Text(productDetail.description,
                        style: new TextStyle(color: Colors.black45)),
                    spcaer,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _user.plan == productDetail.id
                            ? RaisedButton(
                            color:
                            isAnySubscribe ? Colors.grey : Colors.blue,
                            child: Icon(Icons.check),
                            onPressed: () {})
                            : RaisedButton(
                            color:
                            isAnySubscribe ? Colors.grey : Colors.blue,
                            child: Text("Buy",
                                style:
                                _style.copyWith(color: Colors.white)),
                            onPressed: isAnySubscribe
                                ? () {}
                                : () async {
                              await purchaseItem(productDetail);
                            }),
                        Text(
                          "${productDetail.price.substring(0, 1)}${(price / months).round()} / Month",
                          style: _style,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child :Icon(
              Icons.arrow_back_ios,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          "Subscribe",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : !isanonymouse
          ? Column(
        children: [
          Container(
            padding: new EdgeInsets.all(20.0),
            child:Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.credit_card, size: 50, color: Colors.grey),
                  Text(
                      subscriptionMessage,
                      style: _style,
                      textAlign: TextAlign.center),
                ]),
          ),
          Container(
            child: new FutureBuilder<List<ProductDetails>>(
                future: retrieveProducts(),
                initialData: List<ProductDetails>(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<ProductDetails>> products) {
                  if (products.data != null) {
                    return new SingleChildScrollView(
                        padding: new EdgeInsets.all(20.0),
                        child: new Column(
                            children: products.data
                                .map((item) => buildProductRow(item))
                                .toList()));
                  }
                  return Container();
                }),
          ),

//                    RaisedButton(
//                      child: Text("Home Page"),
//                      onPressed: () {
//                        Navigator.pop(context);
//                        Navigator.pushReplacement(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) => HomeScreen()));
//                      },
//                    )
        ],
      )
          : Container(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            "Please login to purchase plan",
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      ),
    );
  }

  /// Gets past purchases
  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response =
    await InAppPurchaseConnection.instance.queryPastPurchases();
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        await InAppPurchaseConnection.instance.completePurchase(purchase);
      } else {
        await InAppPurchaseConnection.instance.consumePurchase(purchase);
      }
    }
    _listenToPurchaseUpdated(response.pastPurchases);
  }
}
