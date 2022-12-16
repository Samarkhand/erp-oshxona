import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/helpers.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/View/Auth/registratsiya_view.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class RegistratsiyaCont with Controller {
  late RegistratsiyaView widget;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? ism;
  PhoneNumber? tel;
  String? parol;
  bool ofertaTasdiq = true;
  late Map<dynamic, dynamic>? result;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    //await Controller.start();
    showLoading(text: "Yuklanmoqda...");
    await loadView();
    hideLoading();
  }

  Future<void> loadView() async {}

  Future<void> save(context) async {
    showLoading(text: "Ma'lumotlar saqlanmoqda");
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
    if(!ofertaTasdiq){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Ommaviy oferta shartlari bilan tanishib chiqing va qabul qiling"),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.redAccent,
      ));
    }
    else if (formKey.currentState!.validate() && ofertaTasdiq) {
      (formKey.currentState!.save());
      showLoading(text: "Login parol tekshirilmoqda");

      Map<dynamic, dynamic> userdetails = {
        'user': {
          'ism': ism,
          'tel': tel!.completeNumber,
          'parol': parol,
        },
      };
      var deviceInfo = await Global.deviceInfo();
      userdetails.addAll(deviceInfo);

      const url = InwareServer.urlReg;
      Response reply = await apiPost(url, jsonMap: userdetails);
      logConsole("POST URL: $url");
      logConsole("REQUEST body: $userdetails");
      logConsole("RESPONSE head: (${reply.statusCode}) ${reply.headers}");
      logConsole("RESPONSE body: ${reply.body}");
      result = jsonDecode(reply.body);

      if (reply.statusCode == 200 && result != null) {
        if (!signJWToken(result!['token'])) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Tokenda hatolik. Ilovani yangilang yoki muallifga murojaat qiling"),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.redAccent,
          ));
          hideLoading();
          return;
        }
        try{
          result!['license'] = checkLicense(result!['license'], result!['lic_vaqt_dan'].toString(), result!['lic_vaqt_gac'].toString());
        }
        catch(e){
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
        await Sozlash.box.put("token", result!['token']);
        await Sozlash.box.put("regVaqt", DateTime.now().millisecondsSinceEpoch);
        await Sozlash.box.put("autVaqt", DateTime.now().millisecondsSinceEpoch);
        // license data
        await Sozlash.box.put("litsenziya", result!['license']);
        await Sozlash.box.put("litVaqtDan", int.parse(result!['lic_vaqt_dan'].toString()));
        await Sozlash.box.put("litVaqtGac", int.parse(result!['lic_vaqt_gac'].toString()));
        // user data
        await Sozlash.box.put("tr", int.parse(result!['user']['id'].toString()));
        await Sozlash.box.put("ism", result!['user']['ism']);
        await Sozlash.box.put("tel", tel!.completeNumber);
        await Sozlash.box.put("davKod", tel!.countryISOCode);
        await Sozlash.box.put("telKod", tel!.countryCode);
        
        await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => getView(),
            ));
      }

      if (result == null || result!['alert'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
          duration: const Duration(seconds: 2),
          backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "${reply.statusCode} ${result!['alert']['title']}. ${result!['alert']['description']}"),
          duration: const Duration(seconds: 2),
          backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
        ));
      }

      hideLoading();
      //Navigator.pop(context);
    }
  }

  Future<String> ofertaOl(context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      throw Exception();
    }
      logConsole("GET URL: ${InwareServer.linkOferta}");
      Response reply = await apiGet(InwareServer.linkOferta);
      return reply.body;
  }

  validate(String? value,
      {bool required = false, String nomi = 'Matn kiriting'}) {
    if (required && (value == null || value.isEmpty)) {
      return nomi;
    }
    return null;
  }

  validateParol(String? value,
      {bool required = false, String nomi = 'Matn kiriting'}) {
    
    if (value == null || value.isEmpty) {
      return "Parolni kiriting";
    } else {
      if (value.length >= 6) {
        if (isNumeric(value)) {
          nomi = "Parolda harflar ham ishlating";
        }
        else {
          return null;
        }
      } else {
        nomi = "Parol 6ta belgidan kam bo'lmasligi kerak";
      }
    }

    if (required) {
      return nomi;
    }
    return null;
  }
}
