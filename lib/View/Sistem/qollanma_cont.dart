import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class QollanmaCont with Controller {
  late QollanmaView widget;
  String title = '';
  String text = '';

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

  Future<void> loadView() async {
    await DefaultAssetBundle.of(context).loadString("assets/qollanma/uz.json").then((s) {
      setState(() {
        title = json.decode(s)[widget.sahifa]['title'];
        text = json.decode(s)[widget.sahifa]['text'];
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Hatolik. Qo'llanmani topa olmadim"),
        duration: Duration(seconds: 5),
      ));
      Navigator.pop(context);
      return;
    });
  }
}
