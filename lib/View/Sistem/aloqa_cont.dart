// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Sistem/aloqa_view.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:http/http.dart';

class AloqaCont with Controller {
  late AloqaView widget;
  String? ism;
  String? litsenziya;
  String? aloqa;
  String? habar;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController matnController = TextEditingController();
  final TextEditingController aloqaController = TextEditingController();

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    await loadView();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> loadView() async {}

  Future send(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      return;
    }

    if (Sozlash.tanishmi) {
      aloqa = Sozlash.tel;
    } else {
      aloqa = aloqaController.text.toString();
    }
    if(Sozlash.ism.isEmpty) {
      ism = 'No`malum Foydalanuvchi';
    }
    else{
      ism = Sozlash.ism;
    }
    if(Sozlash.litsenziya.isEmpty) {
      litsenziya = '';
    }
    else{
      litsenziya = "\nLitsenziya: <pre>${Sozlash.litsenziya}</pre>";
    }
    habar = matnController.text.toString();
    
    if (formKey.currentState!.validate()) {
      Map<String, String> datatopost = {
        "qaydan": "ERP Oshxona v1.0 App",
        "ilova": "ERP Oshxona v1.0 App",
        "habar":
            "\nIsmi:  <b>$ism</b>$litsenziya\nAloqa uchun: <b>$aloqa</b>\n\nHabar:\n<b>$habar</b>",
        "haridor_tr": "1950954022", // 242795268
        "haridor_ism": "erp_kitchen",
        "vaqt_n": DateTime.now().toLocal().toString(),
        "vaqt_s": DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final httpClient = Client();
      Response response = await httpClient.post(
          Uri.parse("https://inware.uz/svc/shabar/index.php"),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8",
            "Auth": "Basic ZmlubWFzdGVyOlMzY3x+bWZxRmswbkFXaH4=",
          },
          body: json.encode(datatopost));
      httpClient.close();

      logConsole("URL: https://inware.uz/svc/shabar/index.php\nREQUEST: $datatopost");
      logConsole("RESPONSE: ${response.body}");
      aloqaController.text = '';
      matnController.text = '';

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Habar jo'natganingiz uchun rahmat! Mutahasislarimiz tez orada javob berishadi"),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.greenAccent,
      ));
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
