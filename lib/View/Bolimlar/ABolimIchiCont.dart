// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Bolimlar/ABolimIchiView.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class ABolimIchiCont with Controller {
  late ABolimIchiView widget;
  late ABolim object;

  late TextEditingController nomiController;
  final formKey = GlobalKey<FormState>();

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //ABolim.obyektlar = await ABolim.service!.getAll();
    if (widget.yangimi) {
      object = ABolim()..turi = widget.turi;
    } else {
      object = ABolim.obyektlar[widget.tr]!;
    }
    nomiController = TextEditingController(text: object.nomi);
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      showLoading(text: "Saqlanmoqda");
      object.nomi = nomiController.text;
      if(widget.yangimi){
        var tr = await ABolim.service!.insert(object.toJson());
        ABolim.obyektlar[tr] = object..tr = tr;
        if(widget.tanlansin && widget.yangimi) {
          hideLoading();
          Navigator.pop(context, tr);
          return;
        }
      }
      else if(!widget.infomi){
        await ABolim.service!.update(object.toJson(), where: " tr='${object.tr}'");
        //ABolim.obyektlar[object.tr] = object;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saqlandi"),
        duration: Duration(seconds: 1),
      ));
      
      hideLoading();
      Navigator.pop(context);
    }
  }

  validate(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Matn kiriting';
    }
    return null;
  }
}
