import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Auth/kirish_view.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:process_run/shell.dart';

class KirishCont with Controller {
  late KirishView widget;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PhoneNumber? telephone;
  String? password;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //await Controller.start();
    await loadView();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> loadView() async {}

  Future<void> save(context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      hideLoading();
      return;
    }
    if (formKey.currentState!.validate()) {
      showLoading(text: "Qurilma o'rganilmoqda");
      Map<String, dynamic> deviceInfo = await Global.deviceInfo();

      showLoading(text: "Login Parol tekshirilmoqda");
      (formKey.currentState!.save());
      Map<String, dynamic> userdetails = {};
      userdetails["login"] = telephone?.completeNumber;
      userdetails["password"] = password;
      userdetails.addAll(deviceInfo);

      var url = InwareServer.urlKir;
      Response reply = await apiPost(url, jsonMap: userdetails);
      logConsole("POST URL: $url");
      logConsole("REQUEST body: $userdetails");
      logConsole("RESPONSE head: (${reply.statusCode}) ${reply.headers}");
      logConsole("RESPONSE body: ${reply.body}");
      Map<dynamic, dynamic>? result = jsonDecode(reply.body);

      if (reply.statusCode == 200) {
        if (!signJWToken(result!['token'])) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Tokenda hatolik. Ilovani yangilang va muallifga murojaat qiling"),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.redAccent,
          ));
          hideLoading();
          return;
        }

        try {
          result['license'] = checkLicense(
              result['license'],
              result['lic_vaqt_dan'].toString(),
              result['lic_vaqt_gac'].toString());
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Litsenziya olishda hatolik. Ilovani yangilang va muallifga murojaat qiling"),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.redAccent,
          ));
          hideLoading();
          return;
        }

        await Sozlash.box.put("tanishmi", true);
        await Sozlash.box.put("token", result['token']);
        await Sozlash.box.put("regVaqt", DateTime.now().millisecondsSinceEpoch);
        await Sozlash.box.put("autVaqt", DateTime.now().millisecondsSinceEpoch);
        // license data
        await Sozlash.box.put("litsenziya", result['license']);
        await Sozlash.box.put("litVaqtDan", int.parse(result['lic_vaqt_dan']));
        await Sozlash.box.put("litVaqtGac", int.parse(result['lic_vaqt_gac']));
        // user data
        await Sozlash.box.put("tr", int.parse(result['user']['id'].toString()));
        await Sozlash.box.put("ism", result['user']['ism']);
        await Sozlash.box.put("tel", telephone!.completeNumber);
        await Sozlash.box.put("davKod", telephone!.countryISOCode);
        await Sozlash.box.put("telKod", telephone!.countryCode);
        // pin code
        await Sozlash.box.put("pinCode", "");
        await Sozlash.box.put("pinCodeBormi", false);

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => getView(),
          ),
        );
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

      hideLoading();
    }
  }

  validate(String? value,
      {bool required = false, String nomi = 'Matn kiriting'}) {
    if (required && (value == null || value.isEmpty)) {
      return nomi;
    }
    return null;
  }
}
