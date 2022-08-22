import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oktoast/oktoast.dart';
import 'package:turuta/screens/pd_main_screen.dart';
import 'package:turuta/util/dio_util.dart';
import 'package:turuta/util/open_url.dart';
import 'package:turuta/util/toast.dart';
import 'package:turuta/widgets/analytics/GestureDetectorTr.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertNearLinks extends StatefulWidget {
  static const routeName = '/alert_near_links';

  AlertNearLinks({Key? key}) : super(key: key);

  @override
  _AlertNearLinksState createState() => _AlertNearLinksState();
}

class _AlertNearLinksState extends State<AlertNearLinks> {
  @override
  Widget build(BuildContext context) {

    final args =
        (ModalRoute.of(context)!.settings.arguments as AlertNearLinksArgs) ??
            AlertNearLinksArgs();

    final btnNoValidar = Padding(
      padding: EdgeInsets.fromLTRB(35, 0, 35, 0),
      child: GestureDetectorTr(
        analyticsName: "btn_near_other",
        onTap: () async {
          nerOptChosen(false, args);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 9, bottom: 10),
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: Color(0xfff63dca),
            boxShadow: [BoxShadow(
                color: Color(0xff000000).withOpacity(0.16),
                offset: Offset(0,3),
                blurRadius: 6,
                spreadRadius: 0
            ) ],
          ),
          child: Text(english_txt_enable?"Other device":"En otro equipo",
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Color(0xffffffff),
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    final mainColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        verticalSpace(30),
        Image.asset('assets/icon/icon_key.png'),
        verticalSpace(26),
        Text(english_txt_enable?"Where do you use your wallet?\n":"¿Dónde tienes tu wallet?\n",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xff536fe0),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace(12),
        Padding(
          padding: EdgeInsets.fromLTRB(35, 0, 35, 0),
          child: GestureDetectorTr(
            analyticsName: "btn_near_cellphone",
            onTap: () {
              nerOptChosen(true, args);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 9, bottom: 10),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                color: Color(0xff5A78C9),
                boxShadow: [BoxShadow(
                    color: Color(0xff000000).withOpacity(0.16),
                    offset: Offset(0,3),
                    blurRadius: 6,
                    spreadRadius: 0
                ) ],
              ),
              child: Text(english_txt_enable?"This phone":"En mi celular",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xffffffff),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        verticalSpace(16),
        btnNoValidar,
        verticalSpace(30),
      ],
    );

    final box = Container(
      margin: EdgeInsets.symmetric(horizontal: getPadding(12)).copyWith(bottom: 0),
      padding: EdgeInsets.symmetric(horizontal: getPadding(12)),
      // white box that covers everything
      decoration: new BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(getPadding(15)),
        boxShadow: [
          BoxShadow(
              color: Color(0x29000000),
              offset: Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 0
          )
        ],
      ),
      child: mainColumn,
    );

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Stack(
        children: <Widget>[
          // background:
          GestureDetectorTr(
            analyticsName: "btn_grey_area",
            child: Container(
              color: Color(0xff444d52).withOpacity(0.8600000143051147),
            ),
            onTap: () {
//              Navigator.of(context).pop();
            },
          ),
          Positioned.fill(
            left: 24,
            right: 24,
            top: 44,
            bottom: 24,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: box,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget textUnderline() {
    return Padding(
      padding: EdgeInsets.fromLTRB(44.5, 0, 44.5, 0),
      child: new Container(
        width: double.infinity,
        height: getPadding(1),
        color: Color(0xff707070),
      ),
    );
  }

  Widget verticalSpace(double h) {
    return Container(
      height: h,
    );
  }

  double getPadding(double p) {
    return p;
  }

  double getFontSize(double f) {
    return f;
  }

  Future<void> nerOptChosen(bool isCellPhoneLink, AlertNearLinksArgs args) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user =  _auth.currentUser;
    if (user == null) {
      return null;
    }

    String URL = "https://tuboleto-near.web.app/?amount="+args.amount.toString()+"&userId="+user.uid+"&penCents="+args.penCents.toString()+"";
    print("Near URL:"+URL);
    if (isCellPhoneLink) {
      await launch(URL);
    } else {
      String mailTo = user.email??"";
      String subject = "Continúa tu recarga a TuBoleto usando Near";
      String body = "Se sugiere enviar este mensaje a un correo personal y abrir el link siguiente desde el dispositivo donde tienes tu wallet (Ejm: PC de escritorio): "+URL;
      String mailToUri = "mailto:"+mailTo+"?subject="+Uri.encodeComponent(subject)+"&body="+Uri.encodeComponent(body);
      print("Near mailToUri: "+mailToUri);
      await launch(mailToUri);
    }

    Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.routeNameBalance, ModalRoute.withName("/"));
    showToast("Termina de recargar con Near y verás tu saldo actualizado", duration: const Duration(seconds: 3));
  }

}

class AlertNearLinksArgs {
  double amount = 0;
  int penCents = 0;
  AlertNearLinksArgs() {
    amount = 0;
    penCents = 0;
  }
}