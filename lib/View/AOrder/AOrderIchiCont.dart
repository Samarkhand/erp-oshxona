import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/View/AOrder/AOrderIchiView.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/form.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class AOrderIchiCont with Controller {
  late AOrderIchiView widget;
  late AOrder object;
  AOrder? objectEski;
  Amaliyot? objectAmaliyot;

  final formKey = GlobalKey<FormState>();
  Map<Key, FormAlert> formValidator = {};
  late TextEditingController miqdorController;
  late TextEditingController izohController;

  Key formKeySelectBolim = const Key('select_bolim');
  Key formKeySelectKontakt = const Key('select_kontakt');
  Key formKeySelectDate = const Key('select_date');

  Map<Key, FormAlert> formValidatorAmaliyot = {};
  final formKeyAmaliyot = GlobalKey<FormState>();
  Key formKeySelectHisob = const Key('select_hisob');

  late TextEditingController miqdorAmaliyotController;
  bool amaliyotBormi = false;
  num miqdor = 0;
  int hisob = 0;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //AOrder.obyektlar = await AOrder.service!.getAll();
    if (widget.yangimi) {
      object = AOrder.bosh();
      object.turi = widget.turi;
    } else {
      object = AOrder.obyektlar[widget.tr]!;
      objectEski = AOrder.fromJson(object.toJson());
    }

    miqdorController = TextEditingController(
        text: object.miqdor == 0 ? "" : object.miqdor.toString());
    izohController = TextEditingController(text: object.izoh);
    formValidator[formKeySelectBolim] = FormAlert.just();
    formValidator[formKeySelectKontakt] = FormAlert.just();
    formValidator[formKeySelectDate] = FormAlert.just();

    formValidatorAmaliyot[formKeySelectHisob] = FormAlert.just();
    miqdorAmaliyotController = TextEditingController(
        text: object.miqdor == 0 ? "" : object.miqdor.toString());

    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> save(context) async {
    if (object.bolim == 0) {
      formValidator[formKeySelectBolim]!.type = FormAlertType.danger;
      formValidator[formKeySelectBolim]!.text = "Tanlang";
      setState(() {
        formValidator[formKeySelectBolim];
      });
    }
    if (object.vaqt == 0) {
      formValidator[formKeySelectDate]!.type = FormAlertType.danger;
      formValidator[formKeySelectDate]!.text = "Tanlang";
      setState(() {
        formValidator[formKeySelectDate];
      });
    }

    if (formKey.currentState!.validate() &&
        object.vaqt != 0 &&
        object.bolim != 0) {
      showLoading(text: "Saqlanmoqda");
      object.izoh = izohController.text;
      if (widget.yangimi) {
        /*var tr = await AOrder.service!.insert(object.toJson());
        AOrder.obyektlar[tr] = object..tr = tr;*/
        object.vaqt = DateTime.now().millisecondsSinceEpoch;
        object.insert();
        if (amaliyotBormi) {
          objectAmaliyot!.turi = object.turi == AOrderTur.menga.tr
              ? AmaliyotTur.chiqim.tr
              : AmaliyotTur.tushum.tr;
          objectAmaliyot!.kont = object.kont;
          objectAmaliyot!.bolim = object.bolim;
          objectAmaliyot!.hisob = hisob;
          objectAmaliyot!.miqdor = miqdor;
          objectAmaliyot!.izoh = object.izoh;
          objectAmaliyot!.sana = object.sana;
          objectAmaliyot!.vaqt = object.vaqt;
          objectAmaliyot!.insert();
        }
      } else if (!widget.infomi) {
        object.update(objectEski!, object);

        /*await AOrder.service!
            .update(object.toJson(), where: " tr='${object.tr}'");*/
        //AOrder.obyektlar[object.tr] = object;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saqlandi"),
        duration: Duration(seconds: 1),
      ));
      hideLoading();
      Navigator.pop(context);
    }
  }

  Future<void> saveAmaliyot(BuildContext context, StateSetter setState) async {
    if (hisob == 0) {
      formValidatorAmaliyot[formKeySelectHisob]!.type = FormAlertType.danger;
      formValidatorAmaliyot[formKeySelectHisob]!.text = "Tanlang";
      setState(() {
        formValidatorAmaliyot[formKeySelectHisob];
      });
    }

    if (formKeyAmaliyot.currentState!.validate() &&
        miqdorAmaliyotController.text.isNotEmpty &&
        hisob != 0) {
      showLoading(text: "Saqlanmoqda");
      miqdor = num.parse(miqdorAmaliyotController.text);
      if (widget.yangimi) {
        setState(() {
          amaliyotBormi = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saqlandi"),
        duration: Duration(seconds: 1),
      ));
      hideLoading();
      Navigator.pop(context);
    }
  }

  hisobTanlash(BuildContext context, StateSetter setState) {
    SelectDialog.showModal<Hisob>(
      context,
      label: "Hisob tanlang",
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      selectedValue: Hisob.obyektlar[hisob],
      items: Hisob.obyektlar.values.toList(),
      onChange: (selected) {
        setState(() => hisob = selected.tr);

        formValidatorAmaliyot[formKeySelectHisob]!.type = FormAlertType.none;
        formValidatorAmaliyot[formKeySelectHisob]!.text = "";

        setState(() => formValidatorAmaliyot[formKeySelectHisob]);
      },
      itemBuilder: (context, object, selected) => ListTile(
        title: Text(object.nomi),
        trailing: Text(sumFormat.format(object.balans)),
      ),
    );
  }

  bolimTanlash(context) {
    int turi = (object.turi == AOrderTur.menga.tr)
        ? ABolimTur.chiqim.tr
        : ABolimTur.tushum.tr;
    SelectDialog.showModal<ABolim>(
      context,
      label: "Bo'lim tanlang",
      selectedValue: ABolim.obyektlar[object.bolim],
      items: ABolim.obyektlar.values
          .where((element) => element.turi == turi)
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

  Future<void> kontTanlash(BuildContext context) async {
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
        formValidator[formKeySelectKontakt]!.type = FormAlertType.none;
        formValidator[formKeySelectKontakt]!.text = "";

        setState(() => formValidator[formKeySelectKontakt]);
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
      formValidator[formKeySelectDate]!.type = FormAlertType.none;
      formValidator[formKeySelectDate]!.text = "";

      setState(() => formValidator[formKeySelectDate]);
    }
  }

  validate(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Matn kiriting';
    }
    return null;
  }
}
