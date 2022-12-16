import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/Mahsulot/MahsulotIchiView.dart';

class MahsulotIchiCont with Controller {
  late MahsulotIchiView widget;
  late Mahsulot object;

  final formKey = GlobalKey<FormState>();
  late TextEditingController nomiController;
  late TextEditingController obController;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Loading...");
    if (widget.yangimi) {
      object = Mahsulot();
      nomiController = TextEditingController();
      obController = TextEditingController();
    } else {
      object = Mahsulot.obyektlar[widget.tr]!;
      nomiController = TextEditingController(text: object.nomi);
      obController = TextEditingController(text: object.mOlchov.nomi);
    }
    hideLoading();
  }

  Future<void> save(context) async {
    if (formKey.currentState!.validate()) {
      showLoading(text: "Saqlanmoqda");
      object.nomi = nomiController.text;
      if (widget.yangimi) {
        var tr = await Mahsulot.service!.insert(object.toJson());
        Mahsulot.obyektlar[tr] = object..tr = tr;
      } else if (!widget.infomi) {
        await Mahsulot.service!
            .update(object.toJson(), where: " tr='${object.tr}'");
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saqlandi"),
        duration: Duration(seconds: 1),
      ));
      hideLoading();
      Navigator.pop(context);
    }
  }
}
