// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Kont/KontIchiView.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/Model/system/form.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:select_dialog/select_dialog.dart';

class KontIchiCont with Controller {
  late KontIchiView widget;
  late Kont object;

  late TextEditingController nomiController;
  late TextEditingController balansController;
  late TextEditingController balansqController;
  late TextEditingController izohController;
  Key formKeySelectBolim = const Key('select_bolim');
  final formKey = GlobalKey<FormState>();
  Map<Key, FormAlert> formValidator = {};
  PhoneNumber? tel;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //Kont.obyektlar = await Kont.service!.getAll();
    if (widget.yangimi){
      object = Kont();
      object.davKod = Sozlash.davKod;
      balansController = TextEditingController(text: '');
      balansqController = TextEditingController(text: '');
    }
    else {
      object = Kont.obyektlar[widget.tr]!;
      balansController = TextEditingController(text: object.balans.toStringAsFixed(2));
      balansqController = TextEditingController(text: '');
    }
    nomiController = TextEditingController(text: object.nomi);
    izohController = TextEditingController(text: object.izoh);
    formValidator[formKeySelectBolim] = FormAlert.just();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> save() async {
    if(object.bolim == 0){
      formValidator[formKeySelectBolim]!.type = FormAlertType.danger;
      formValidator[formKeySelectBolim]!.text = "Tanlang";
      setState((){
        formValidator[formKeySelectBolim];
      });
    }
    
    if (formKey.currentState!.validate() && object.bolim !=0) {
      formKey.currentState!.save();
      showLoading(text: "Saqlanmoqda");
      object.nomi = nomiController.text;
      object.izoh = izohController.text;
      object.davKod = tel!.countryISOCode;
      object.telKod = tel!.countryCode;
      object.tel = tel!.number;
      object.balans = num.parse(balansController.text != '' ? balansController.text : "0");
      if (widget.yangimi) {
        object.balans = object.balans - num.parse(balansqController.text != '' ? balansqController.text : "0");
        object.boshBalans = object.balans;
        object.vaqt = DateTime.now();
        var tr = await Kont.service!.insert(object.toJson());
        Kont.obyektlar[tr] = object..tr = tr;
        if(widget.tanlansin) {
          hideLoading();
          Navigator.pop(context, tr);
          return;
        }
      } else if (!widget.infomi) {
        await Kont.service!.update(object.toJson(), where: " tr='${object.tr}'");
        //Kont.obyektlar[object.tr] = object;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saqlandi"),
        duration: Duration(seconds: 1),
      ));

      hideLoading();
      Navigator.pop(context);
    }
  }
  
  saqlashTuriTanlash(context) {
    SelectDialog.showModal<KBolim>(
      context,
      label: "Bo'lim tanlang",
      selectedValue: KBolim.obyektlar[object.bolim],
      items: KBolim.obyektlar.values
          .toList(),
      onChange: (selected) {
        setState(() {
          object.bolim = selected.tr;
        });

        formValidator[formKeySelectBolim]!.type = FormAlertType.none;
        formValidator[formKeySelectBolim]!.text = "";

        setState(() => formValidator[formKeySelectBolim]);
        //Navigator.pop(context);
        //kontTanlash(context);
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }
  
  validate(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Matn kiriting';
    }
    return null;
  }
}
