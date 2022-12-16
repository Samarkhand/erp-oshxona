import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Auth/qulf_view.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class QulfCont with Controller {
  late QulfView widget;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

}
