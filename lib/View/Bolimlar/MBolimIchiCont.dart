import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Bolimlar/MBolimIchiView.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class MBolimIchiCont with Controller {
  late MBolimIchiView widget;
  late MBolim object;

  late TextEditingController nomiController;
  final formKey = GlobalKey<FormState>();

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //MBolim.obyektlar = await MBolim.service!.getAll();
    if (widget.yangimi){
      object = MBolim()..turi = widget.turi;
    }
    else {
      object = MBolim.obyektlar[widget.tr]!;
    }
    nomiController = TextEditingController(text: object.nomi);
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      showLoading(text: "Saqlanmoqda");
      object.nomi = nomiController.text;
      if (widget.yangimi) {
        var tr = await MBolim.service!.insert(object.toJson());
        MBolim.obyektlar[tr] = object..tr = tr;
        if(widget.tanlansin) {
          hideLoading();
          Navigator.pop(context, tr);
          return;
        }
      } else if (!widget.infomi) {
        await MBolim.service!.update(object.toJson(), where: " tr='${object.tr}'");
        //MBolim.obyektlar[object.tr] = object;
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
