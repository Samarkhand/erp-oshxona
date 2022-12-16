import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/View/Amaliyot/AmaliyotIchiView.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

import '../../Model/system/form.dart';

class AmaliyotIchiCont with Controller {
  late AmaliyotIchiView widget;
  late Amaliyot object;
  Amaliyot? objectEski;
  bool qarzmi = false;

  late TextEditingController miqdorController;
  late TextEditingController izohController;
  Key formKeySelectBolim = const Key('select_bolim');
  Key formKeySelectHisob = const Key('select_hisob');
  Key formKeySelectKontakt = const Key('select_kontakt');
  Key formKeySelectDate = const Key('select_date');
  final formKey = GlobalKey<FormState>();
  Map<Key, FormAlert> formValidator = {};

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //Amaliyot.obyektlar = await Amaliyot.service!.getAll();
    if (widget.yangimi) {
      object = Amaliyot.bosh();
      object.turi = widget.turi;
      object.hisob = Sozlash.tanlanganHisob.tr;
    } else {
      object = Amaliyot.obyektlar[widget.tr]!;
      if(object.turi == AmaliyotTur.qarzO.tr || object.turi == AmaliyotTur.qarzB.tr){
        qarzmi = false;
      }
      objectEski = Amaliyot.fromJson(object.toJson());
    }
    miqdorController = TextEditingController(text: object.miqdor == 0 ? "" : object.miqdor.toString());
    izohController = TextEditingController(text: object.izoh);
    formValidator[formKeySelectBolim] = FormAlert.just();
    formValidator[formKeySelectHisob] = FormAlert.just();
    formValidator[formKeySelectKontakt] = FormAlert.just();
    formValidator[formKeySelectDate] = FormAlert.just();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> save(context) async {
    if(object.bolim == 0 && !qarzmi){
      formValidator[formKeySelectBolim]!.type = FormAlertType.danger;
      formValidator[formKeySelectBolim]!.text = "Tanlang";
      setState((){
        formValidator[formKeySelectBolim];
      });
    }
    else if(qarzmi){
      object.turi = object.turi == AmaliyotTur.chiqim.tr ? AmaliyotTur.qarzB.tr : object.turi == AmaliyotTur.tushum.tr ? AmaliyotTur.qarzO.tr : object.turi;
      if(object.turi == AmaliyotTur.qarzB.tr){
        object.bolim = Sozlash.abolimQarzB.tr;
      }
      else if(object.turi == AmaliyotTur.qarzO.tr){
        object.bolim = Sozlash.abolimQarzO.tr;
      }
    }
    else{
      object.turi = object.turi == AmaliyotTur.qarzB.tr ? AmaliyotTur.chiqim.tr : object.turi == AmaliyotTur.qarzO.tr ? AmaliyotTur.tushum.tr : object.turi;
    }

    if(object.hisob == 0){
      formValidator[formKeySelectHisob]!.type = FormAlertType.danger;
      formValidator[formKeySelectHisob]!.text = "Tanlang";
      setState((){
        formValidator[formKeySelectHisob];
      });
    }
    if(object.vaqt == 0){
      formValidator[formKeySelectDate]!.type = FormAlertType.danger;
      formValidator[formKeySelectDate]!.text = "Tanlang";
      setState((){
        formValidator[formKeySelectDate];
      });
    }
    
    if (formKey.currentState!.validate() && object.vaqt !=0 && object.bolim !=0 && object.hisob !=0) {
      showLoading(text: "Saqlanmoqda");
      object.izoh = izohController.text;
      if (widget.yangimi) {
        //var tr = await Amaliyot.service!.insert(object.toJson());
        object.insert();
      } else if (!widget.infomi) {
        object.update(objectEski!, object);
        //Amaliyot.obyektlar[object.tr] = object;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saqlandi"),
        duration: Duration(seconds: 1),
      ));
      hideLoading();
      Navigator.pop(context);
    }
  }

  bolimTanlash(context) {
    SelectDialog.showModal<ABolim>(
      context,
      label: "Bo'lim tanlang",
      selectedValue: ABolim.obyektlar[object.bolim],
      items: ABolim.obyektlar.values
          .where((element) => element.turi == widget.turi)
          .toList(),
      onChange: (selected) {
        setState(() {
          object.bolim = selected.tr;
        });

        formValidator[formKeySelectBolim]!.type = FormAlertType.none;
        formValidator[formKeySelectBolim]!.text = "";

        setState(() => formValidator[formKeySelectBolim]);
        //Navigator.pop(context);
        //hisobTanlash(context);
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }

  hisobTanlash(context) {
    SelectDialog.showModal<Hisob>(
      context,
      label: "Hisob tanlang",
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      selectedValue: Hisob.obyektlar[object.hisob],
      items: Hisob.obyektlar.values.toList(),
      onChange: (selected) {
        setState(() {
          object.hisob = selected.tr;
        });
        logConsole(object.toJson());
      },
      itemBuilder: (context, object, selected) => ListTile(
        title: Text(object.nomi),
        trailing: Text(sumFormat.format(object.balans)),
      ),
    );
  }

  kontTanlash(BuildContext context) {
    SelectDialog.showModal<Kont>(
      context,
      label: "Kontakt tanlang",
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      selectedValue: Kont.obyektlar[object.kont],
      items: Kont.obyektlar.values.toList(),
      onChange: (selected) {
        setState(() {
          object.kont = selected.tr;
        });
        logConsole(object.toJson());
      },
      itemBuilder: (context, object, selected) => ListTile(
        title: Text(object.nomi),
        trailing: Text(sumFormat.format(object.balans)),
      ),
    );
  }

  Future<void> sanaTanlash(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.fromMillisecondsSinceEpoch(object.sana),
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked.millisecondsSinceEpoch != object.sana) {
      setState(() {
        object.sana = picked.millisecondsSinceEpoch;
        object.sanaDT = picked;
      });
    }
  }

  validate(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Matn kiriting';
    }
    return null;
  }

  qarzCheck() {
    setState(() {
      qarzmi = !qarzmi;
    });
  }
}
