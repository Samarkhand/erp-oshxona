import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatIchiView.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/form.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class HujjatIchiCont with Controller {
  late HujjatIchiView widget;
  late Hujjat object;
  Hujjat? objectEski;
  Amaliyot? objectAmaliyot;

  late TextEditingController raqamController;
  late TextEditingController izohController;
  Key formKeySelectBolim = const Key('select_bolim');
  Key formKeySelectKontakt = const Key('select_kontakt');
  Key formKeySelectDate = const Key('select_date');
  final formKey = GlobalKey<FormState>();
  Map<Key, FormAlert> formValidator = {};

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
    //Hujjat.obyektlar = await Hujjat.service!.getAll();
    object = widget.hujjat;
    if (widget.yangimi) {
      object.turi = widget.turi;
      await object.yangiRaqam();
    } else {
      objectEski = Hujjat.fromJson(object.toJson());
    }
    raqamController = TextEditingController(text: object.raqami.toString());
    izohController = TextEditingController(text: object.izoh);
    formValidator[formKeySelectBolim] = FormAlert.just();
    formValidator[formKeySelectKontakt] = FormAlert.just();
    formValidator[formKeySelectDate] = FormAlert.just();

    formValidatorAmaliyot[formKeySelectHisob] = FormAlert.just();

    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> save(context) async {
    print('save');
    if (formKey.currentState!.validate()) {
      print('validate');
      showLoading(text: "Saqlanmoqda");
      object.raqami = int.tryParse(raqamController.text) ?? 0;
      object.izoh = izohController.text;
      object.vaqt = DateTime.now().millisecondsSinceEpoch;
      object.vaqtS = object.vaqt;
      if (widget.yangimi) {
        object.tr = await Hujjat.service!.newId(object.turi);
        object.insert();
      } else if (!widget.infomi) {
        object.update(objectEski!, object);
        /*await Hujjat.service!
            .update(object.toJson(), where: " tr='${object.tr}'");*/
        //Hujjat.obyektlar[object.tr] = object;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saqlandi"),
        duration: Duration(seconds: 1),
      ));
      hideLoading();
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => openHujjat(object)!,
          ));
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
    /*SelectDialog.showModal<ABolim>(
      context,
      label: "Bo'lim tanlang",
      selectedValue: ABolim.obyektlar[object.bolim],
      items: ABolim.obyektlar.values
          .where((element) => element.turi == ABolimTur.mahsulot.tr)
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
    );*/
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
          object.trKont = selected.tr;
        });
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
        object.sanaDT;
      });
    }
  }
  
  validate(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Matn kiriting';
    }
    return null;
  }
}
