import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turuta/api/pd_stop_api.dart';
import 'package:turuta/data/firestore_user_dependant_data.dart';
import 'package:turuta/model/pd_profile.dart';
import 'package:turuta/screens/ad_screen.dart';
import 'package:turuta/screens/page_scaffold_new.dart';
import 'package:turuta/screens/pd_splash_screen.dart';
import 'package:turuta/screens/pd_alert_history.dart';
import 'package:turuta/screens/polygon_ask_wallet.dart';
import 'package:turuta/util/firebase_analytics.dart';

import 'package:turuta/util/dio_util.dart';
import 'package:turuta/util/login.dart';
import 'package:turuta/util/text_utils.dart';
import 'package:turuta/util/ticket_details_util.dart';
import 'package:turuta/util/toast.dart';
import 'package:turuta/widgets/analytics/GestureDetectorTr.dart';
import 'package:turuta/widgets/common.dart';

import '../data/prefs_helper.dart';
import '../main.dart';

class PdHistory extends StatefulWidget {
  static const routeName = '/history_screen';

  PdHistory({Key? key}) : super(key: key);

  @override
  _PdHistoryState createState() => _PdHistoryState();
}

class _PdHistoryState extends State<PdHistory>
    with WidgetsBindingObserver, RouteAware {
  bool isLoading = true;
  User? _user;
  PdProfile? _pdProfile;
  bool isShowingTripHistory = true;

  List<Widget> tripHistoryList = [];
  List<Widget> rechargeHistoryList = [];

  List<String> months = [
    is_english_txt_enable ? "January" : 'Enero',
    is_english_txt_enable ? "February" : 'Febrero',
    is_english_txt_enable ? "March" : 'Marzo',
    is_english_txt_enable ? "April" : 'Abril',
    is_english_txt_enable ? "May" : 'Mayo',
    is_english_txt_enable ? "June" : 'Junio',
    is_english_txt_enable ? "July" : 'Julio',
    is_english_txt_enable ? "August" : 'Agosto',
    is_english_txt_enable ? "September" : 'Setiembre',
    is_english_txt_enable ? "October" : 'Octubre',
    is_english_txt_enable ? "November" : 'Noviembre',
    is_english_txt_enable ? "December" : 'Diciembre'
  ];
  List<int> years = [2020, 2021, 2022, 2023, 2024, 2025];

  int year = 2021;
  int month = 0;

  @override
  void initState() {
    super.initState();
    print("init pd_history");
    WidgetsBinding.instance!.addObserver(this);
    initialChecks();
  }

  Future<void> initialChecks() async {
    setState(() {
      isLoading = true;
    });

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;

    if (user == null) {
      Navigator.of(context).pushReplacementNamed(SplashScreen.routeName);
      return;
    }

    final pdProfileWrapped = await FsUser.pdProfile.getDocument();
    if (pdProfileWrapped.value == null) {
      Navigator.of(context).pushReplacementNamed(SplashScreen.routeName);
      return;
    }

    setState(() {
      _user = user;
      _pdProfile = pdProfileWrapped.value;
    });

    final now = DateTime.now();
    year = now.year;
    month = now.month;

    await loadTripHistory();

    setState(() {
      isLoading = false;
    });

    loadRechargeHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    routeObserver.unsubscribe(this);
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
  void didPopNext() {
    debugPrint("didPopNext");
    refreshHistoryData();
  }

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
    if (isLoading) {
      return buildLoadingWidgetScreen();
    }

    final defPicProfile = ClipOval(
        child: Container(
      width: 72,
      height: 72,
      child: Image.asset('assets/icon/avatar_default.png'),
    ));

    final nameProfile = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _pdProfile?.nombre ?? "",
          //"Peppa Pig",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xff707070),
            fontSize: 20,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
        /*Container(
            padding: EdgeInsets.only(left: 14.5),
            child: Image.asset('assets/icon/pd_purple_down.png')),*/
      ],
    );

    final fechasText = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          is_english_txt_enable ? "Choose Date" : "Escoge la fecha",
          //"Peppa Pig",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xff707070),
            fontSize: 17,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    final inputDates = Container(
      margin: EdgeInsets.fromLTRB(0, 15, 0, 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 15),
            child: DropdownButton<String>(
              isExpanded: true,
              value: months[month - 1],
              icon: Image.asset('assets/icon/grey_triangle_down.png'),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) async {
                if (newValue == null) return;
                month = months.indexOf(newValue) + 1;

                await refreshHistoryData();
              },
              items: months.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 55, right: 15),
            child: DropdownButton<int>(
              isExpanded: true,
              value: year,
              icon: Image.asset('assets/icon/grey_triangle_down.png'),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (int? newValue) async {
                if (newValue == null) return;

                year = newValue;

                await refreshHistoryData();
              },
              items: years.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );

    final viajeRecargaSwitch = Container(
      margin: EdgeInsets.only(left: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: GestureDetectorTr(
              analyticsName: "btn_tripHistory",
              onTap: () {
                print("btn_tripHistory clicked");

                setState(() {
                  isShowingTripHistory = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  is_english_txt_enable ? "Trips" : "Viajes",
                  //"Peppa Pig",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: isShowingTripHistory
                        ? Color(0xff741994)
                        : Color(0xff707070),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(7.0),
                color: Color(0xff707070),
              )),
          GestureDetectorTr(
            analyticsName: "btn_rechargeHistory",
            onTap: () {
              print("btn_rechargeHistory clicked");
              setState(() {
                isShowingTripHistory = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                is_english_txt_enable ? "Top ups" : "Recargas",
                //"Peppa Pig",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: !isShowingTripHistory
                      ? Color(0xff741994)
                      : Color(0xff707070),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );

    final box = Container(
        decoration: new BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            verticalSpace(20),
            defPicProfile,
            verticalSpace(10),
            nameProfile,
            verticalSpace(20),
            fechasText,
            inputDates,
            viajeRecargaSwitch,
            verticalSpace(12),
            isShowingTripHistory
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: tripHistoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return tripHistoryList[index];
                    })
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: rechargeHistoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return rechargeHistoryList[index];
                    }),
            verticalSpace(12),
          ],
        ));

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
        color: Color(0xffffffff),
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
                  is_english_txt_enable ? "Trip History" : "Historial",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xff888888),
                    fontSize: 16,
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

    return PageScaffold(
        padding: false,
        boxDecoration: BoxDecoration(
          color: Colors.white,
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

  Widget getHistoryCardWidget(String analyticsName, String title, String body1,
      String body2, AlertHistoryArgs alertArgs, String? tripId) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: GestureDetectorTr(
        analyticsName: analyticsName,
        onTap: () async {
          await Navigator.of(context).pushNamed(
              AlertHistory.routeNameTripHistory,
              arguments: alertArgs) as int?;
        },
        child: Container(
          width: double.infinity,
          // height: 84,
          // white box that covers everything
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(getPadding(12)),
            boxShadow: [
              BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  spreadRadius: 0)
            ],
          ),
          child: Container(
            margin: EdgeInsets.fromLTRB(18, 5, 10, 5),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          verticalSpace(15),
                          Text(title,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xff484848),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                              )),
                          verticalSpace(10),
                          Text(body1,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xff707070),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.normal,
                              )),
                          verticalSpace(13),
                          Text(body2,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xff707070),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                              )),
                          verticalSpace(15),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Text("+",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xff741994),
                            fontSize: 40,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                          )),
                    ),
                  ],
                ),
                !alertArgs.isTripHistory
                    ? Container()
                    : tripId != null
                        ? GestureDetectorTr(
                            analyticsName: "polygonBtn_earn_tokens",
                            onTap: () async {
                              final _prefs = await Prefs.walletAddress();

                              String walletAddress = _prefs.getValue();
                              debugPrint("walletAddress: $walletAddress");
                              if (walletAddress.isEmpty) {
                                await Navigator.of(context)
                                    .pushNamed(PolygonAskWallet.routeName);
                              } else {
                                bool? success = await Navigator.of(context)
                                        .pushNamed(AdScreen.routeName,
                                            arguments: AdArgs(tripId: tripId))
                                    as bool?;

                                if (success == true) {}
                              }
                            },
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: const Color(0xffebb506),
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                                child: Text(
                                  is_english_txt_enable
                                      ? "Claim Tokens"
                                      : 'Ganar Dinero por tu viaje',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: const Color(0xffffffff),
                                    height: 1.7142857142857142,
                                  ),
                                  textAlign: TextAlign.center,
                                  textHeightBehavior: TextHeightBehavior(
                                      applyHeightToFirstAscent: false),
                                )),
                          )
                        : Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD2D2D2),
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: Text(
                              is_english_txt_enable
                                  ? "Token Claimed"
                                  : 'Token ya reclamado',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                color: const Color(0xffffffff),
                                height: 1.7142857142857142,
                              ),
                              textAlign: TextAlign.center,
                              textHeightBehavior: TextHeightBehavior(
                                  applyHeightToFirstAscent: false),
                            )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  loadTripHistory() async {
    final pdTripHistoryResponse =
        await pdStopApiClient.getTripHistory(_user!.uid, year, month);

    if (pdTripHistoryResponse.code == 0 || pdTripHistoryResponse.arr == null) {
      toast("Error al obtener el historial de viajes");
      return;
      //Navigator.of(context).pop();
    }

    tripHistoryList.clear();
    if (pdTripHistoryResponse.arr != null) {
      for (final tripHistory in pdTripHistoryResponse.arr!) {
        var format = DateFormat('d/M/yy');
        var date = DateTime.fromMillisecondsSinceEpoch(
            tripHistory.timestamp!.millisecondsSinceEpoch!);
        final title = (is_english_txt_enable ? "Trip" : "Viaje") +
            " - " +
            format.format(date);
        final body1 = (is_english_txt_enable ? "Route" : "Ruta") +
            ": " +
            (tripHistory.pdUnidad?.ruta ?? "error");
        final tarifa = (tripHistory.tarifa_final?.tarifa == null ||
                tripHistory.tarifa_final!.tarifa == null)
            ? "0"
            : TextUtils.formatPrice(tripHistory.tarifa_final!.tarifa!, false,
                showCurrencySymbol: false, numberOfDecimals: 2);
        String body2 = (is_english_txt_enable ? "Price" : "Tarifa Cobrada") +
            ": S/ " +
            tarifa;

        String tarifaF = "...";

        if (tripHistory.reajuste != null) {
          tarifaF = (tripHistory.tarifa_final?.tarifa == null ||
                  tripHistory.tarifa_final!.tarifa == null)
              ? "0"
              : TextUtils.formatPrice(
                  (tripHistory.tarifa_final?.tarifa ?? 0) -
                      (tripHistory.reajuste?.PENCentsAdded ?? 0),
                  false,
                  showCurrencySymbol: false,
                  numberOfDecimals: 2);
          body2 = "Tarifa Cobrada: " + tarifaF;
        }

        String? dateEnd;
        // var dateEnd =  tripHistory.timestamp_cierre==0
        //     ? "Cierre manual"
        //     : DateFormat('d/M/yy h:mm a').format(DateTime.fromMillisecondsSinceEpoch(tripHistory.timestamp_cierre!));

        if (tripHistory.timestamp_cierre == null)
          dateEnd = "En proceso";
        else if (tripHistory.timestamp_cierre == 0)
          dateEnd = "Cierre manual";
        else
          dateEnd = DateFormat('d/M/yy h:mm a').format(
              DateTime.fromMillisecondsSinceEpoch(
                  tripHistory.timestamp_cierre!));

        final routeInfo =
            await queryRouteInfo(tripHistory.pdUnidad?.ruta ?? "");

        String body = "Empresa: " +
            (routeInfo?.empresaNombre ?? "") +
            "\n\n" +
            "Código de ruta:  " +
            (tripHistory.pdUnidad?.ruta ?? "") +
            "\n\n" +
            "Padrón del bus: " +
            (tripHistory.pdUnidad?.padron ?? "") +
            "\n\n" +
            "Origen de viaje: " +
            (tripHistory.tarifa_final?.partida?.name ?? "") +
            "\n\n" +
            "Fecha y hora de inicio: " +
            DateFormat('d/M/yy h:mm a').format(date) +
            "\n\n" +
            "Destino de viaje: " +
            (tripHistory.paradero_bajada_usuario?.name ?? "") +
            "\n\n" +
            "Fecha y hora de cierre: " +
            dateEnd +
            "\n\n" +
            "Boleto id: " +
            (tripHistory.boleto_id == null
                ? "..."
                : tripHistory.boleto_id.toString()) +
            "\n\n" +
            "Tarifa: " +
            tarifa +
            "\n\n";

        if (tripHistory.reajuste != null) {
          body = body +
              "Reajuste: " +
              ((-1 * (tripHistory.reajuste?.PENCentsAdded ?? 0)).toString() ??
                  "") +
              "\n\n";
          body = body + "Tarifa final: " + tarifaF + "\n";
        }

        String btn1Text = "Entendido";
        String btn1Analytics = "btn_OkAlertTripHistory";

        AlertHistoryArgs alertArgs = AlertHistoryArgs(
            body, btn1Text, btn1Analytics, true, tripHistory.tid);

        bool tripHaveSeen =
            await checkIfTripHaveSeen(tripHistory.tid ?? "null");

        tripHistoryList.add(getHistoryCardWidget(
            "btn_tripHistory_" + (tripHistory.tid ?? "null"),
            title,
            body1,
            body2,
            alertArgs,
            tripHaveSeen ? null : tripHistory.tid));
      }
    }

    setState(() {
      tripHistoryList = tripHistoryList;
    });
  }

  Future<void> loadRechargeHistory() async {
    final pdRechargeHistoryResponse =
        await pdStopApiClient.getRechargeHistory(_user!.uid, year, month);

    if (pdRechargeHistoryResponse.code == 0 ||
        pdRechargeHistoryResponse.arr == null) {
      toast("Error al obtener el historial de recargas");
      return;
      //Navigator.of(context).pop();
    }
    rechargeHistoryList.clear();
    for (final rechargeHistory in pdRechargeHistoryResponse.arr!) {
      var format = DateFormat('d/M/yy');
      var date = DateTime.fromMillisecondsSinceEpoch(
          rechargeHistory.timestamp!.millisecondsSinceEpoch!);
      final title = "Recarga - " + format.format(date);
      final tipo = rechargeHistory.PENCentsAdded != null ? "Tarjeta" : "Yape";
      final body1 = "Tipo: " + tipo;
      final tarifa = TextUtils.formatPrice(
          rechargeHistory.PENCentsAdded ??
              (rechargeHistory.totalAmountInCents ?? 0),
          false,
          showCurrencySymbol: false,
          numberOfDecimals: 2);
      final body2 = "Monto: " + tarifa;

      final body = "Tipo de Operación: " +
          tipo +
          "\n\n" +
          "Nombre y Apellido:  " +
          (_pdProfile?.nombre ?? "") +
          " " +
          (_pdProfile?.apellido ?? "") +
          "\n\n" +
          "Número de celular: " +
          (_pdProfile?.numero ?? "") +
          "\n\n" +
          "Fecha y hora de recarga: " +
          DateFormat('d/M/yy h:mm a').format(date) +
          "\n\n" +
          "Saldo recargado: " +
          tarifa +
          "\n";

      String btn1Text = "Entendido";
      String btn1Analytics = "btn_OkAlertRechargeHistory";

      AlertHistoryArgs alertArgs =
          AlertHistoryArgs(body, btn1Text, btn1Analytics, false, null);

      final analyticsName = "btn_rechargeHistory_" +
          (rechargeHistory.tid ?? rechargeHistory.transactionId ?? "");

      rechargeHistoryList.add(getHistoryCardWidget(
          analyticsName, title, body1, body2, alertArgs, null));
    }

    setState(() {
      isLoading = false;
      rechargeHistoryList = rechargeHistoryList;
    });
  }

  Future<void> refreshHistoryData() async {
    setState(() {
      isLoading = true;
    });
    if (isShowingTripHistory) {
      await loadTripHistory();
      loadRechargeHistory();
    } else {
      loadTripHistory();
      await loadRechargeHistory();
    }
    setState(() {
      isLoading = false;
    });
  }
}

class AdArgs {
  String tripId;
  AdArgs({required this.tripId});
}

/// Check If Document Exists
Future<bool> checkIfTripHaveSeen(String tripId) async {
  try {
    // Get reference to Firestore collection
    var collectionRef =
        FirebaseFirestore.instance.collection(FsUser.polygon_ads_collection);

    var doc = await collectionRef.doc(tripId).get();
    return doc.exists;
  } catch (e, s) {
    logErrorAndCrashlytics("checkIfPolygonAdDocExists", e, s);
    return false;
  }
}
