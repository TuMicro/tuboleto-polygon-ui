import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:turuta/screens/pd_recharge_amount_card.dart';
import 'package:turuta/screens/pd_recharge_other_amount_card.dart';
import 'package:turuta/screens/pd_recharge_yape.dart';
import 'package:turuta/util/dio_util.dart';
import 'package:turuta/util/open_url.dart';
import 'package:turuta/util/toast.dart';
import 'package:turuta/widgets/analytics/GestureDetectorTr.dart';

import '../main.dart';

class AlertRechargeOpts extends StatefulWidget {
  static const routeName = '/alert_recharge_opts';

  AlertRechargeOpts({Key? key}) : super(key: key);

  @override
  _AlertRechargeOptsState createState() => _AlertRechargeOptsState();
}

class _AlertRechargeOptsState extends State<AlertRechargeOpts> {
  @override
  Widget build(BuildContext context) {

    double marginL = 25;
    double marginR = 25;

    final btnOptNear = Padding(
      padding: EdgeInsets.fromLTRB(marginL, 0, marginR, 0),
      child: GestureDetectorTr(
        //analyticsName: "btn_recharge_opt_celo", //TODO CELO
        analyticsName: "btn_recharge_opt_near",
        onTap: () async {

          CardTopUpFlowArgs args = CardTopUpFlowArgs();
          args.rechargeType = RechargeType.NEAR;
          Navigator.of(context).pushReplacementNamed(RechargeAmountCard.routeName, arguments: args);

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
          child: Text("NEAR",//"CELO",
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

    final btnOptPolygon = Padding(
      padding: EdgeInsets.fromLTRB(marginL, 0, marginR, 0),
      child: GestureDetectorTr(
        //analyticsName: "btn_recharge_opt_celo", //TODO CELO
        analyticsName: "btn_recharge_opt_polygon",
        onTap: () async {

          CardTopUpFlowArgs args = CardTopUpFlowArgs();
          args.rechargeType = RechargeType.POLYGON;

          Navigator.of(context)
                .pushReplacementNamed(RechargeOtherAmountCard.routeName, arguments: args);    

        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 9, bottom: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: Color(0xfff63dca),
            boxShadow: [BoxShadow(
                color: Color(0xff000000).withOpacity(0.16),
                offset: Offset(0,3),
                blurRadius: 6,
                spreadRadius: 0
            ) ],
          ),
          child: Text("POLYGON",
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

    final btnOptAurora = Padding(
      padding: EdgeInsets.fromLTRB(marginL, 0, marginR, 0),
      child: GestureDetectorTr(
        //analyticsName: "btn_recharge_opt_celo", //TODO CELO
        analyticsName: "btn_recharge_opt_aurora",
        onTap: () async {

          CardTopUpFlowArgs args = CardTopUpFlowArgs();
          args.rechargeType = RechargeType.AURORA;
          Navigator.of(context).pushReplacementNamed(RechargeAmountCard.routeName, arguments: args);

        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 9, bottom: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: Color(0xfff63dca),
            boxShadow: [BoxShadow(
                color: Color(0xff000000).withOpacity(0.16),
                offset: Offset(0,3),
                blurRadius: 6,
                spreadRadius: 0
            ) ],
          ),
          child: Text("AURORA",//"CELO",
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

    final btnOptCard = Padding(
      padding: EdgeInsets.fromLTRB(marginL, 0, marginR, 0),
      child: GestureDetectorTr(
        analyticsName: "btn_recharge_opt_card",
        onTap: () {
          Navigator.of(context).pushReplacementNamed(RechargeAmountCard.routeName);
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
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(is_english_txt_enable?"Debit/Credit Card":"Tarjeta Cr??dito/D??bito",
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
    );

    final btnOptYape = Padding(
      padding: EdgeInsets.fromLTRB(marginL, 0, marginR, 0),
      child: GestureDetectorTr(
        analyticsName: "btn_recharge_opt_yape",
        onTap: () async {
          Navigator.of(context).pushReplacementNamed(RechargeYape.routeName);
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
          child: Text("Yape",
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
        Image.asset('assets/images/pd_recharge_balance.png'),
        verticalSpace(26),
        Text(is_english_txt_enable?"How would you like to\ntop up your balance?\n":"Con qu?? medio de pago te\ngustar??a recargar saldo?\n",
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
        (is_production || !IS_POLYGON_ACTIVE)?Container():btnOptPolygon,
        (is_production || !IS_POLYGON_ACTIVE)?Container():verticalSpace(16),
        (is_production || !IS_NEAR_ACTIVE)?Container():btnOptNear,
        (is_production || !IS_NEAR_ACTIVE)?Container():verticalSpace(16),
        (is_production || !IS_AURORA_ACTIVE)?Container():btnOptAurora,
        (is_production || !IS_AURORA_ACTIVE)?Container():verticalSpace(16),
        btnOptCard,
        (is_production || !IS_YAPE_ACTIVE)?verticalSpace(16):Container(),
        (is_production || !IS_YAPE_ACTIVE)?Container():btnOptYape,
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
              Navigator.of(context).pop();
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

}

enum RechargeType {
  YAPE,
  CELO,
  VISA,
  NEAR,
  AURORA,
  POLYGON
}

String getBtnNameFromRechargeEnum (RechargeType rechargeOpts) {
  switch (rechargeOpts){
    case RechargeType.CELO: return "CELO";
    case RechargeType.VISA: return is_english_txt_enable?"Debit/Credit Card":"Tarjeta Cr??dito/D??bito";
    case RechargeType.YAPE: return "Yape";
    case RechargeType.NEAR: return "Near";
    case RechargeType.AURORA: return "AURORA";
    case RechargeType.POLYGON: return "Polygon";
    default:
      toast ("Error getBtnNameFromRechargeEnum");
      return "null";
  }
}

double? convertSolesToRechargeTypeCurrency (RechargeType? rechargeOpts,int? amountInSoles) {
  if (amountInSoles == null || RechargeType == null) return null;

  switch (rechargeOpts){ 
    case RechargeType.CELO: return amountInSoles*1.003977/4.02; //TODO CELO update exchange rate
    case RechargeType.VISA: return amountInSoles*1.0;
    case RechargeType.YAPE: return amountInSoles*1.0;
    case RechargeType.NEAR: return double.parse((amountInSoles*0.08333333333333/3.75).toStringAsFixed(5)) ; //TODO NEAR update exchange rate
    case RechargeType.AURORA: return double.parse((amountInSoles*0.0003071602116948179/3.75).toStringAsFixed(5)) ; //TODO AURORA update exchange rate
    case RechargeType.POLYGON: return double.parse((amountInSoles*0.32656).toStringAsFixed(5)); //tipo de cambio de 19/08/22
    default:
      return amountInSoles*1.0;
  }
}

String? getStringFormattedForRechargeBtns (RechargeType? rechargeOpts, double? currencyValue, int? amountInSoles) {
  if (currencyValue == null) currencyValue = 0;
  switch (rechargeOpts){
    case RechargeType.CELO: return "\n"+(amountInSoles!=null?currencyValue.toStringAsFixed(2)+" Celo Dollars":"in Celo Dollars"); //TODO CELO update exchange rate
    case RechargeType.VISA: return null;
    case RechargeType.YAPE: return null;
    case RechargeType.NEAR: return "\n"+(amountInSoles!=null?currencyValue.toStringAsFixed(5)+" NEAR":"with NEAR"); //TODO NEAR update exchange rate
    case RechargeType.AURORA: return "\n"+(amountInSoles!=null?currencyValue.toStringAsFixed(5)+" AETH":"with AETH"); //TODO AURORA update exchange rate
    case RechargeType.POLYGON: return "\n"+(amountInSoles!=null?currencyValue.toStringAsFixed(5)+" MATIC":"with MATIC");
    default:
      return null;
  }
}

String? getCurrencySymbol(RechargeType? rechargeOpts){

  switch (rechargeOpts){
    case RechargeType.CELO: return "CUSD";
    case RechargeType.VISA: return null;
    case RechargeType.YAPE: return null;
    case RechargeType.NEAR: return "NEAR";
    case RechargeType.AURORA: return "AETH";
    case RechargeType.POLYGON: return "MATIC";
    default:
      return null;
  }
}