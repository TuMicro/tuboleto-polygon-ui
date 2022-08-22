import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:turuta/api/pd_stop_api.dart';
import 'package:turuta/screens/page_scaffold_new.dart';
import 'package:turuta/screens/pd_history.dart';
import 'package:turuta/screens/pd_splash_screen.dart';
import 'package:turuta/screens/pd_alert_history.dart';
import 'package:turuta/util/dio_util.dart';

import 'package:turuta/util/text_utils.dart';
import 'package:turuta/util/ticket_details_util.dart';
import 'package:turuta/util/toast.dart';
import 'package:turuta/widgets/analytics/GestureDetectorTr.dart';
import 'package:turuta/widgets/common.dart';

import '../data/firestore_user_dependant_data.dart';
import '../data/prefs_helper.dart';
import '../main.dart';
import '../util/firebase_analytics.dart';

class PolygonAskWallet extends StatefulWidget {
  static const routeName = '/polygon_ask_wallet';
  PolygonAskWallet({Key? key}) : super(key: key);

  @override
  _PolygonAskWalletState createState() => _PolygonAskWalletState();
}

class _PolygonAskWalletState extends State<PolygonAskWallet>
    with WidgetsBindingObserver, RouteAware {
  bool _isLoading = true;

  final controllerWallet = TextEditingController();
  final focusNodeWallet = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    initialChecks();
  }

  Future<void> initialChecks() async {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    var controllers = [
      controllerWallet,
    ];

    var focus = [
      focusNodeWallet,
    ];

    controllers.forEach((element) {
      element.dispose();
    });
    focus.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {}

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // went to Background
    }
    if (state == AppLifecycleState.resumed) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return buildLoadingWidgetScreen();
    }

    final grey_arrow_left = Padding(
      padding: EdgeInsets.only(top: 11.6, left: 11.5, right: 15, bottom: 10.8),
      child: GestureDetectorTr(
          analyticsName: "btn_history_back",
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Image.asset('assets/icon/grey_arrow_left.png')),
    );

    final header = Container(
      margin: EdgeInsets.only(bottom: 5),
      width: double.infinity,
      decoration: new BoxDecoration(
        color: Color(0xFFFFF0C0),
        boxShadow: [
          BoxShadow(
              color: const Color(0x29000000),
              offset: Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 0)
        ],
      ),
      child: Container(
        //color: Colors.yellow,
        child: Stack(
          children: [
            grey_arrow_left,
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(top: 10),
                //color: Colors.blue,
                child: Text(
                  is_english_txt_enable ? "Add Wallet" : "Añade tu Wallet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final box = Container(
        padding: EdgeInsets.only(left: 26, right: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            verticalSpace(90),
            Image.asset('assets/images/img_ask_wallet.png'),
            verticalSpace(59),
            Text(
              is_english_txt_enable
                  ? "Write your wallet address to\nreceive your tokens there"
                  : 'Escribe tu wallet para recibir tus\ntokens en tu wallet',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                color: const Color(0xff707070),
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace(74),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controllerWallet,
                focusNode: focusNodeWallet,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(top: 18, bottom: 18, left: 28, right: 28),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFF68D2E), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelText: 'Wallet',
                  labelStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: const Color(0xff707070),
                  ),
                  hintText: 'Escribe aquí tu wallet address',
                  hintStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: const Color(0xFFAEAEAE),
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  color: const Color(0xff707070),
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            verticalSpace(100),
            GestureDetectorTr(
              analyticsName: "polygonBtn_wallet_listo",
              onTap: () async {
                if (controllerWallet.text.isEmpty) {
                  toast("wallet address vacío");
                  return;
                }
                final _prefs = await Prefs.walletAddress();
                await _prefs.setValue(controllerWallet.text);
                await storeWalletAddress(controllerWallet.text);
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                margin: EdgeInsets.only(left: 13, right: 13),
                decoration: BoxDecoration(
                  color: const Color(0xfff68d2e),
                  borderRadius: BorderRadius.circular(19.0),
                ),
                child: Text(
                  is_english_txt_enable ? "Next" : 'Listo',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 23,
                    color: const Color(0xffffffff),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ));

    return PageScaffold(
        padding: false,
        boxDecoration: BoxDecoration(
          color: Color(0xFFFFF0C0),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                header,
                Expanded(
                  child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          box,
                        ],
                      )),
                ),
                //menu
              ],
            ),
          ],
        ));
  }
}

Future<bool> storeWalletAddress(String walletAddress) async {
  try {
    // Get reference to Firestore collection

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    var collectionRef = FirebaseFirestore.instance
        .collection(FsUser.polygon_wallets_collection);

    var doc = await collectionRef.doc(user.uid).set({
      'wallet': walletAddress,
    }).then((value) {
      print("wallet ${walletAddress} stored sucessfully");
    }).catchError((error) {
      print("Failed to store wallet: $error");
    });

    return true;
  } catch (e, s) {
    logErrorAndCrashlytics("checkIfPolygonAdDocExists", e, s);
    return false;
  }
}
