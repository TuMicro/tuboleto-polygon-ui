import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:turuta/scaffold.dart';
import 'package:turuta/screens/page_scaffold_new.dart';
import 'package:turuta/screens/pd_alert_near_links.dart';
import 'package:turuta/screens/pd_alert_recharge_opts.dart';
import 'package:turuta/screens/pd_camera_request_onboarding.dart';
import 'package:turuta/screens/pd_recharge_onboarding.dart';
import 'package:turuta/screens/pd_recharge_other_amount_card.dart';
import 'package:turuta/screens/pd_recharge_register_card.dart';
import 'package:turuta/screens/pd_recharge_status_card.dart';
import 'package:turuta/screens/pd_welcome_community.dart';
import 'package:turuta/styles.dart';
import 'package:turuta/testing/transacciones_test.dart';
import 'package:turuta/util/dio_util.dart';
import 'package:turuta/util/firebase_analytics.dart';
import 'package:turuta/util/toast.dart';
import 'package:turuta/widgets/analytics/GestureDetectorTr.dart';
import 'package:turuta/widgets/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turuta/util/native.dart';

import 'package:turuta/data/firestore_user_dependant_data.dart';
import 'package:turuta/screens/pd_main_screen.dart';
import 'package:turuta/util/pd_trip_util.dart';
import 'package:url_launcher/url_launcher.dart';

class RechargeAmountCard extends StatefulWidget {
  static const routeName = '/recharge_amount_card';

  RechargeAmountCard({Key? key}) : super(key: key);

  @override
  _RechargeAmountCardState createState() => _RechargeAmountCardState();
}

class _RechargeAmountCardState extends State<RechargeAmountCard> {
  final controllerMonto = TextEditingController();
  final focusNodeMonto = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.

    var controllers = [
      controllerMonto,
    ];

    var focus = [
      focusNodeMonto,
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
  void initState() {
    setState(() {
      controllerMonto.text = (allPagesAnswers[Field.monto] as String) ?? "";
    });
    controllerMonto.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)!.settings.arguments as CardTopUpFlowArgs) ??
            CardTopUpFlowArgs();

    if (isLoading) {
      return buildLoadingWidgetScreen();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final grey_arrow_left = Padding(
      padding: EdgeInsets.only(top: 21.6, left: 17.6),
      child: GestureDetectorTr(
          analyticsName: "btn_rechargeAmountCard_back",
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Image.asset('assets/icon/grey_arrow_left.png')),
    );

    final box = Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: getPadding(0)).copyWith(bottom: 0),
        padding: EdgeInsets.symmetric(horizontal: getPadding(0)),
        // white box that covers everything
        decoration: new BoxDecoration(
          color: Color(0xffffffff),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Image.asset('assets/images/grupo-15.png'),
            verticalSpace(111.7),
            Image.asset('assets/images/pd_golden_recharge.png'),
            verticalSpace(23.2),
            Text(
              english_txt_enable?"Choose how much\nyou’d like to top up":"Elige el monto\nque quieres recargar",
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Color(0xff000000),
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace(39),
            buildRechargeAmount("30 soles", 30, args),
            buildRechargeAmount("20 soles", 20, args),
            buildRechargeAmount("10 soles", 10, args),
            buildRechargeAmount(english_txt_enable?"Other amount":"Otro monto", null, args),
            verticalSpace(108),
          ],
        ),
      ),
    );

    final boxFinal = Stack(
      children: [
        box,
        Positioned(top: 0, left: 0, child: Center(child: grey_arrow_left)),
      ],
    );

    return PageScaffold(
      boxDecoration: BoxDecoration(
        color: Colors.white
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              boxFinal,
            ],
          ),
        ),
      ),
    );

    /*return PageScaffold(
        padding: false,
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: <Widget>[
                box,
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(child: cellphone)
                ),
              ],
            )
        )
    );*/
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

  Widget buildRechargeAmount(String amount, int? amountInSoles, CardTopUpFlowArgs args) {


    double? celoDollars = convertSolesToRechargeTypeCurrency(args.rechargeType, amountInSoles);

    return Padding(
      padding: EdgeInsets.fromLTRB(19, 0, 19, 21),
      child: GestureDetectorTr(
        analyticsName: "btn_rechargeAmount_" + amount.substring(0, 2),
        onTap: () async {

          if (amountInSoles == null) {
            Navigator.of(context).pushNamed(RechargeOtherAmountCard.routeName, arguments: args);
          } else {
            args.penCents = amountInSoles * 100;

            if (args.rechargeType==RechargeType.AURORA) {

              startValoraFlow(celoDollars??0, args, context);

            } else if (args.rechargeType==RechargeType.NEAR) {

              final nearArgs = AlertNearLinksArgs()
                ..amount = celoDollars??0
                ..penCents = args.penCents;

              Navigator.of(context).pushNamed(AlertNearLinks.routeName,
                  arguments: nearArgs);
            } else {
              visanetFlowWrapper(args);
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 10, bottom: 11),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              colors: [Color(0xff42f9b6), Color(0xff08cea7)],
              stops: [0, 1],
              begin: Alignment(1.00, -0.00),
              end: Alignment(-1.00, 0.00),
            ),
            boxShadow: [
              BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  spreadRadius: 0)
            ],
          ),
          child: Text(
            amount.toString()+ (getStringFormattedForRechargeBtns(args.rechargeType, celoDollars, amountInSoles)??""),
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Color(0xffffffff),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
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

  // alsa copied on pd_recharge_other_amount_card
  void visanetFlowWrapper(CardTopUpFlowArgs args) async {
    setState(() {
      isLoading = true;
    });
    try {
      final success = await startVisanetPaymentFlow(context, args);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      toast(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }
}


Future<void> startValoraFlow(double celoDollars, CardTopUpFlowArgs args, BuildContext context) async {

  //TODO CELO
  /*final bool result = await platform.invokeMethod('startWebViewRechargeCelo', <String, dynamic>{
    'amount' : celoDollars.toStringAsFixed(2),
  }) as bool;*/

  final bool result = await platform.invokeMethod('startWebViewRechargeAurora', <String, dynamic>{
    'amount' : celoDollars.toStringAsFixed(6),
  }) as bool;

  print ("WebView callBack: " + result.toString());

  if (result) {
    //print("launching google");
    //launch("http://google.com/");

    analytics.logEvent(
      //name: 'valora_recharge_success', //TODO CELO
      name: 'aurora_recharge_success',
      parameters: <String, dynamic>{
        'amount_cusd': celoDollars.toStringAsFixed(2),
        'amount_pen_cents': args.penCents
      },
    );

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user =  _auth.currentUser;
    if (user == null) {
      toast("El usuario debe hacer login");
      return;
    }

  } else {
    toast("error");
  }
}

class CardTopUpFlowArgs {
  int penCents = 500;
  bool isOnboarding = false;
  //bool isCELO = false;
  RechargeType? rechargeType;
  CardTopUpFlowArgs() {
    penCents = 500;
    isOnboarding = false;
    //bool isCELO = false;
    rechargeType = RechargeType.VISA;
  }
}
