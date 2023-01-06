// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/sorovnoma.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/View/Auth/kirish_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class InwareServer {
  static String accountUrl = Sozlash.server;
  static const String siteUrl = "https://inware.uz";

  static String get urlReg => '${Sozlash.server}/?a=service/reg';
  static String get urlKir => '${Sozlash.server}/?a=service/auth';
  static String get urlChiq => '${Sozlash.server}/?a=service/logout';
  static String get urlGetAuthKey => '${Sozlash.server}/?a=service/getAuthKey';
  static String get urlGetPaymentKey => "${Sozlash.server}/?a=service/getAuthKey&payment=1";
  static String get urlGetInfo => '${Sozlash.server}/?a=service/data';
  static String get urlTarmoqTek =>
      '${Sozlash.server}/?a=service/checkBot&group=1&channel=1';
  static String get urlDeviceReg => '${Sozlash.server}/?a=service/deviceReg';
  static String get urlSorovJavob => "${Sozlash.server}/?a=service/sorovnoma";
  static String get urlBuyurtma => "${Sozlash.server}/?a=service/order";
  static String get linkGetAuth => '$accountUrl/?authKey=';
  static const String linkOferta = '$siteUrl/ommaviyTak.php';
  static const String linkYangiliklar = 'https://t.me/finmasterapp';
  static const String linkTelegramMuallif = 'inware_admin';
  static const String linkEmailMuallif = 'support@inware.uz';
  static const String telegramBot = "InwareBot";
  static const String telegramKanal = "inwareorg";
  static const String telegramGroup = "inware_chat";
  static const String linkBotAzo = 'https://t.me/$telegramBot?start=';
  static const String linkGooglePlay =
      'https://play.google.com/store/apps/details?id=uz.inware.erp_oshxona';


  static azoBoldimiBotga(BuildContext context) async {
    if (!Sozlash.tanishmi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Avval ro'yxatdan o'ting"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amber,
      ));
      return;
    }
    if (await (Connectivity().checkConnectivity()) == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      return;
    }
    var url = InwareServer.urlTarmoqTek;
    Map<String, String> headers = {"Auth": Sozlash.token};
    Response reply = await apiGet(url, headers: headers);
    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("RESPONSE head: ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if (reply.statusCode == 200) {
      bool tamoqAzosimi = true;
      if (result!['bot']['status']) {
        if (!result['channel']['status']) {
          tamoqAzosimi = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['channel']['title']),
            duration: const Duration(seconds: 2),
            backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
          ));
        }

        if (!result['group']['status']) {
          tamoqAzosimi = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['group']['title']),
            duration: const Duration(seconds: 2),
            backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
          ));
        }

        if (tamoqAzosimi) await Sozlash.box.put("tarmoqAzosimi", true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['bot']['title']),
          duration: const Duration(seconds: 2),
          backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
        ));
      }
      await Sozlash.box.put("tarmoqTBotAzosimi", result['bot']['status']);
      await Sozlash.box.put("tarmoqTBotAzosimiTas", result['bot']['status']);
      await Sozlash.box.put("tarmoqTKnlAzosimi", result['channel']['status']);
      await Sozlash.box.put("tarmoqTGrpAzosimi", result['group']['status']);
    }
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    } else {}
  }

  static Future botAzoBol(BuildContext context) async {
    if (!Sozlash.tanishmi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Avval ro'yxatdan o'ting"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amber,
      ));
      return;
    }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      return;
    }
    var url = InwareServer.urlGetAuthKey;
    Map<String, String> headers = {"Auth": Sozlash.token};
    Response reply = await apiGet(url, headers: headers);
    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("RESPONSE head: ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if (reply.statusCode == 200) {
      String key = result!['authKey'];
      String url = "${InwareServer.linkBotAzo}$key";
      logConsole("URL Launch: $url");
      Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch url';
      }
    }
    if (result == null || result['alert'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${reply.statusCode} ${result['alert']['title']}. ${result['alert']['description']}"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
  }

  static Future logout(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      return;
    }
    var deviceInfo = await Global.deviceInfo();

    var url = InwareServer.urlChiq;
    Map<String, String> headers = {"Auth": Sozlash.token};
    Response reply = await apiPost(url, jsonMap: deviceInfo, headers: headers);
    logConsole("URL: $url");
    logConsole("REQUEST body: $deviceInfo");
    logConsole("RESPONSE head: (${reply.statusCode}) ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);
// reply.statusCode == 200
    if (true) {
      await Sozlash.initValues();
      await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const KirishView(),
          ));
    }

    if (result == null || result['alert'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${reply.statusCode} ${result['alert']['title']}. ${result['alert']['description']}"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
  }

  static Future lichka(BuildContext context) async {
    if (!Sozlash.tanishmi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Avval ro'yxatdan o'ting"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amber,
      ));
      return;
    }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      return;
    }
    var url = InwareServer.urlGetAuthKey;
    Map<String, String> headers = {"Auth": Sozlash.token};
    Response reply = await apiGet(url, headers: headers);
    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("RESPONSE head: ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if (reply.statusCode == 200) {
      String key = result!['authKey'];
      String url = "${InwareServer.linkGetAuth}$key";
      logConsole("URL Launch: $url");
      Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch url';
      }
    }
    if (result == null || result['alert'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${reply.statusCode} ${result['alert']['title']}. ${result['alert']['description']}"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
  }

  static Future lichkaTarif(BuildContext context) async {
    if (!Sozlash.tanishmi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Avval ro'yxatdan o'ting"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amber,
      ));
      return;
    }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      return;
    }
    var url = InwareServer.urlGetPaymentKey;
    Map<String, String> headers = {"Auth": Sozlash.token};
    Response reply = await apiGet(url, headers: headers);
    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("RESPONSE head: ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if (reply.statusCode == 200) {
      String key = result!['authKey'];
      String url = "${InwareServer.linkGetAuth}$key";
      logConsole("URL Launch: $url");
      Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch url';
      }
    }
    if (result == null || result['alert'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${reply.statusCode} ${result['alert']['title']}. ${result['alert']['description']}"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
  }

  static Future licTekshir(BuildContext context, {bool asosiymi = false}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (!asosiymi) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Internetga ulaning"),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.amberAccent,
        ));
      }
      return;
    }
    var url = InwareServer.urlGetInfo;
    Map<String, String>? headers;
    Map<dynamic, dynamic> bodyMap = {};

    List sorovnomaList = [];
    for(var value in SorovnomaCont.obyektlar.values){
      if(value.jonatganVaqt != 0 || value.javob == '') continue;
      sorovnomaList.add(value.toServer());
    }
    if (Sozlash.tanishmi) {
      headers = {"Auth": Sozlash.token};
      bodyMap = {
        "license": Sozlash.litsenziya,
        "lic_vaqt_dan": (Sozlash.litVaqtDan),
        "lic_vaqt_gac": (Sozlash.litVaqtGac),
        "sorovnoma": sorovnomaList,
      };
    } else {
      var deviceInfo = await Global.deviceInfo();
      bodyMap.addAll(deviceInfo);
      bodyMap["sorovnoma"] = sorovnomaList;
    }
    Response reply = await apiPost(url, jsonMap: bodyMap, headers: headers);
    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("REQUEST body: $bodyMap");
    logConsole("RESPONSE head: (${reply.statusCode}) ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if(reply.statusCode == 200){
      for(Map value in sorovnomaList){
        SorovnomaCont.obyektlar[value['sorov_key']]!.jonatganVaqt = DateTime.now().millisecondsSinceEpoch;
        await SorovnomaCont.box.put(value['sorov_key'], SorovnomaCont.obyektlar[value['sorov_key']]!.toJson());
      }
      if(result!['sorovnoma'] != null && (result['sorovnoma'] as List).isNotEmpty ){
        for(Map value in result['sorovnoma']){
          if(SorovnomaCont.obyektlar[value['sorov_key']] != null){
            await SorovnomaCont.box.put(value['sorov_key'],  SorovnomaCont.obyektlar[value['sorov_key']]!.fromServer(value).toJson());
          }
          else {
            await SorovnomaCont.box.put(value['sorov_key'], Sorovnoma.bosh().fromServer(value).toJson());
          }
        }
      }
    }

    if (reply.statusCode == 200 && result != null && result['token'] != null) {
      Sozlash.box.put("sinVaqt", DateTime.now().millisecondsSinceEpoch);
      Sozlash.box.put("token", result['token']);
      if (Sozlash.tanishmi) {
        checkLicense(
            result['license'].toString(),
            result['lic_vaqt_dan'].toString(),
            result['lic_vaqt_gac'].toString());
        await Sozlash.box
            .put("litVaqtDan", int.parse(result['lic_vaqt_dan'].toString()));
        await Sozlash.box
            .put("litVaqtGac", int.parse(result['lic_vaqt_gac'].toString()));
        if (DateTime.now().millisecondsSinceEpoch >
            toMilliSecond(int.parse(result['lic_vaqt_gac'].toString()))) {
          if (asosiymi) {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => getView(),
              ),
            );
          }
          return;
        } else if (!asosiymi) {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => getView(),
            ),
          );
          return;
        }
      }
    }
    if (result == null || result['alert'] == null) {
    } else if (Sozlash.tanishmi || reply.statusCode != 401) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${reply.statusCode} ${result['alert']['title']}. ${result['alert']['description']}"),
        duration: const Duration(seconds: 6),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
  }

  static Future deviceRegister() async {
    if (Sozlash.deviceRegBolganmi) {
      return;
    }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }
    var url = InwareServer.urlDeviceReg;
    var deviceInfo = await Global.deviceInfo();
    Response reply = await apiPost(url, jsonMap: deviceInfo);
    logConsole("GET URL: $url");
    logConsole("REQUEST body: $deviceInfo");
    logConsole("RESPONSE head: (${reply.statusCode}) ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if (reply.statusCode == 200 && result != null) {
      if (result['time'] != null) {
        Sozlash.box.put("kirVaqt", int.parse(result['time'].toString()) * 1000);
      }
      Sozlash.box.put("deviceRegBolganmi", true);
    }
  }

  static Future sorovJavob(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      return;
    }
    var body = {
      "til": "uz",
      "sorov_key": "qoniqdizmi_qisman",
      "javob": "SMS habarnoma qo'shsak yaxshi bo'lar edi"
    };

    var url = InwareServer.urlChiq;
    Map<String, String> headers = {"Auth": Sozlash.token};
    Response reply = await apiPost(url, jsonMap: body, headers: headers);
    logConsole("URL: $url");
    logConsole("REQUEST body: $body");
    logConsole("RESPONSE head: (${reply.statusCode}) ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);
    if (reply.statusCode == 200) {}

    if (result == null || result['alert'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${reply.statusCode} ${result['alert']['title']}. ${result['alert']['description']}"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
  }
}
