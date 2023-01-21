import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/View/Auth/kirish_view.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_chiqim_view.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_kirim_view.dart';
import 'package:erp_oshxona/View/MahKirim/buyurtma_royxat_view.dart';
import 'package:erp_oshxona/View/MahChiqim/chiqim_royxat_view.dart';
import 'package:erp_oshxona/View/MahKirim/kirim_royxat_view.dart';
import 'package:erp_oshxona/View/MahZarar/zarar_royxat_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

import 'package:erp_oshxona/Model/static/mablag.dart';
import 'package:erp_oshxona/View/Auth/qulf_view.dart';
import 'package:erp_oshxona/View/Auth/registratsiya_view.dart';
import 'package:erp_oshxona/Model/static/qulf.dart';
import 'package:erp_oshxona/View/asosiy_view.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:select_dialog/select_dialog.dart';

int toSecond(int millisecond) {
  return (millisecond / 1000).round();
}

int toMilliSecond(int second) {
  return second * 1000;
}

/// bir honali raqamlar oldiga 0 qo'shib beradi
String twoDigit(dynamic num) {
  String ret;

  if (int.parse(num.toString()) < 10) {
    ret = "0$num";
  } else {
    ret = num.toString();
  }
  return ret;
}

Future<Response> apiPost(String url,
    {Map? jsonMap, Map<String, String>? headers}) async {
  final httpClient = Client();
  late Response response;
  Map<String, String> headersSend = {'content-type': 'application/json'};
  headersSend.addAll(headers ?? {});
  try {
    response = await httpClient.post(Uri.parse(url),
        headers: headersSend, body: json.encode(jsonMap));
    httpClient.close();
  } catch (e) {
    rethrow;
  }
  return response;
}

Future<Response> apiGet(String url, {Map<String, String>? headers}) async {
  final httpClient = Client();
  late Response response;
  try {
    response = await httpClient.get(Uri.parse(url), headers: headers);
    httpClient.close();
  } catch (e) {
    rethrow;
  }
  return response;
}

Widget badgeSaqLashTuri(int tr, bool razmer) {
  return razmer
      ? Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color:
                Color(MablagSaqlashTuri.obyektlar[tr]!.color).withOpacity(0.9),
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 16,
          ),
          child: Wrap(
            children: [
              Icon(MablagSaqlashTuri.obyektlar[tr]!.icon,
                  size: 16, color: Colors.white),
              const SizedBox(width: 7.0),
              Text(
                MablagSaqlashTuri.obyektlar[tr]!.nomi,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      : Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color:
                Color(MablagSaqlashTuri.obyektlar[tr]!.color).withOpacity(0.9),
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 12,
          ),
          child: Wrap(
            children: [
              Icon(MablagSaqlashTuri.obyektlar[tr]!.icon,
                  size: 16, color: Colors.white),
              const SizedBox(width: 3.0),
              Text(
                MablagSaqlashTuri.obyektlar[tr]!.nomi,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
}

bool signJWToken(String? auth) {
  final token = (auth ?? "").replaceFirst("Tanish ", "");

  late JWT decoded;
  try {
    //logConsole("JWT.verify($token)");
    // Verify a token
    decoded =
        JWT.verify(token, SecretKey(Global.jwtKey), checkExpiresIn: false);

    logConsole('Payload: ${decoded.payload}');
  } on JWTExpiredError {
    logConsole('jwt expired');
  } // ex: invalid signature
  on JWTError catch (ex) {
    logConsole(ex.message);
    throw "Kirish mumkin emas. Tokenda hatolik. ${ex.message}";
  }

  return true;
}

String checkLicense(String data, String vaqtD, String vaqtG) {
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  String raw = stringToBase64.decode(data);
  String license = raw.split(":")[0];
  String sign = raw.split(":")[1];
  var bytes1 = utf8.encode("$license$vaqtD$vaqtG${Global.licenseSalt}");
  var newSign = sha1.convert(bytes1);
  /*
  logConsole("raw=$raw");
  logConsole("license=$license");
  logConsole("sign=$sign");
  logConsole("newSign=$newSign");*/
  if (newSign.toString() == sign) {
    return license;
  } else {
    throw Exception("Noto'g'ri litsenziya");
  }
}

logConsole(Object? data) {
  if (kDebugMode) {
    print(data);
  }
}

Future writeLog() async {}

getView() {
  // return const KirishView();
  late Widget viewKorsat;

  // sana o'zgargan bo'lsa
  if (DateTime.now().millisecondsSinceEpoch < Sozlash.sdkVaqt) {
    viewKorsat = QulfView(QulfSabab.sanaOzgargan);
  }
  // tanishmas bo'lsa logindan o'tsin
  else if (!Sozlash.tanishmi) {
    viewKorsat = const KirishView();
  }/*
  // litsenziya vaqti tugagan bo'lsa va tanish bo'lsa
  else if (Sozlash.tanishmi &&
      DateTime.now().millisecondsSinceEpoch >
          toMilliSecond(Sozlash.litVaqtGac)) {
    viewKorsat = QulfView(QulfSabab.tolovQiling);
  }*/
  // boshqa sabab bilan bloklanganmi
  else if (Sozlash.blokmi) {
    viewKorsat = QulfView(QulfSabab.obyektlar[Sozlash.blokSabab]!);
  }
  // tanish bo'lsa
  else if (Sozlash.tanishmi) {
    viewKorsat = const AsosiyView();
  }
  // logindan o'tsin
  else {
    viewKorsat = const KirishView();
  }
  if (DateTime.now().millisecondsSinceEpoch > Sozlash.sdkVaqt) {
    Sozlash.box.put("sdkVaqt", DateTime.now().millisecondsSinceEpoch);
  }
  return viewKorsat;
}

Widget? openHujjat(Hujjat object){
  Widget? view;
  logConsole(object.toJson());
  if(HujjatTur.kirim.tr == object.turi){
    view = KirimRoyxatView(object);
  }
  else if(HujjatTur.kirimFil.tr == object.turi){
    view = const SizedBox();
  }
  else if(HujjatTur.qaytibOlish.tr == object.turi){
    view = const SizedBox();
  }
  else if(HujjatTur.qaytibBerish.tr == object.turi){
    view = const SizedBox();
  }
  else if(HujjatTur.zarar.tr == object.turi){
    view = ChiqZararRoyxatView(object);
  }
  else if(HujjatTur.kirimIch.tr == object.turi){
    var partiya = HujjatPartiya.id(object.tr);
    if(object.sts == HujjatSts.tugallanganPrt.tr){
      view = const SizedBox();
    }
    else if(object.sts == HujjatSts.tayyorlashPrt.tr){
      view = const SizedBox();
    }
    else if(object.sts == HujjatSts.homAshyoPrt.tr){
      view = IchiChiqimRoyxatView(partiya);
    }
    else if(object.sts == HujjatSts.ochilgan.tr){
      view = IchKirimRoyxatView(partiya);
    }
  }
  else if(HujjatTur.chiqimIch.tr == object.turi){
    var partiya = HujjatPartiya.id(object.tr);
    view = IchiChiqimRoyxatView(partiya);
  }
  else if(HujjatTur.chiqimFil.tr == object.turi){
    view = const SizedBox();
  }
  else if(HujjatTur.buyurtma.tr == object.turi){
    view = BuyurtmaRoyxatView(object);
  }
  else if(HujjatTur.chiqim.tr == object.turi){
    view = ChiqimRoyxatView(object);
  }
  return view;
}

String twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

num yaxlitla(num summa, {int? yaxlit}) {
  return (summa / (yaxlit ?? Sozlash.yaxlit)).round() *
      (yaxlit ?? Sozlash.yaxlit);
}

Widget check(
    {required Widget title,
    required bool value,
    required ValueChanged<bool> onChanged}) {
  return Card(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    child: ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: title,
      leading: Switch(
        value: value,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(value),
    ),
  );
}

bolimTanlash({
  required BuildContext context,
  required StateSetter setState,
  required String label,
  required List<dynamic> items,
  required dynamic selectedValue,
  required Function onChange,
  String searchHint = 'Saralash...',
}) {
  SelectDialog.showModal(
    context,
    // ignore: deprecated_member_use
    searchHint: searchHint,
    label: label,
    selectedValue: selectedValue,
    items: items,
    onChange: (selected) => onChange(selected),
  );
}

Widget selectWidget({
  required GestureTapCallback onTap,
  required List<Widget> selectValue,
  required GestureTapCallback onTapPlus,
  Color color = Colors.white,
  double borderRadius = 12,
  double padding = 16,
  double betweenPadding = 10,
}) {
  return Row(
    children: [
      Expanded(
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: selectValue,
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: betweenPadding),
      Material(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTapPlus,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.all(padding),
            child: const Icon(Icons.add, size: 16),
          ),
        ),
      ),
    ],
  );
}
