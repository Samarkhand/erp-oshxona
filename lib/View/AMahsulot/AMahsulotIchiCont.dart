import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/View/AMahsulot/AMahsulotIchiView.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/form.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class AMahsulotIchiCont with Controller {
  late AMahsulotIchiView widget;
  late AMahsulot object;
  AMahsulot? objectEski;
  Amaliyot? objectAmaliyot;

  late TextEditingController miqdorController;
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
    //AMahsulot.obyektlar = await AMahsulot.service!.getAll();
    if (widget.yangimi) {
      object = AMahsulot.bosh();
      object.turi = widget.turi;
    } else {
      object = AMahsulot.obyektlar[widget.tr]!;
      objectEski = AMahsulot.fromJson(object.toJson());
    }
    miqdorController = TextEditingController(text: object.miqdor == 0 ? "" : object.miqdor.toString());
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
    if(object.bolim == 0){
      formValidator[formKeySelectBolim]!.type = FormAlertType.danger;
      formValidator[formKeySelectBolim]!.text = "Tanlang";
      setState((){
        formValidator[formKeySelectBolim];
      });
    }
    if(object.vaqt == 0){
      formValidator[formKeySelectDate]!.type = FormAlertType.danger;
      formValidator[formKeySelectDate]!.text = "Tanlang";
      setState((){
        formValidator[formKeySelectDate];
      });
    }

    if (formKey.currentState!.validate() && object.vaqt !=0 && object.bolim !=0) {
      showLoading(text: "Saqlanmoqda");
      object.izoh = izohController.text;
      if (widget.yangimi) {
        object.insert();
        if (amaliyotBormi) {
          objectAmaliyot!.turi = object.turi == AMahsulotTur.savdo.tr || object.turi == AMahsulotTur.vozvratChiq.tr
              ? AmaliyotTur.tushum.tr
              : AmaliyotTur.chiqim.tr;
          objectAmaliyot!.kont = object.kont;
          objectAmaliyot!.bolim = object.turi == AMahsulotTur.savdo.tr || object.turi == AMahsulotTur.vozvratChiq.tr
              ? Sozlash.abolimMahUchun.tr
              : Sozlash.abolimMahUchun.tr;
          objectAmaliyot!.hisob = hisob;
          objectAmaliyot!.miqdor = miqdor;
          objectAmaliyot!.izoh = object.izoh;
          objectAmaliyot!.sana = object.sana;
          objectAmaliyot!.vaqt = object.vaqt;
          objectAmaliyot!.insert();
        }
      } else if (!widget.infomi) {
        object.update(objectEski!, object);
        /*await AMahsulot.service!
            .update(object.toJson(), where: " tr='${object.tr}'");*/
        //AMahsulot.obyektlar[object.tr] = object;
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
    SelectDialog.showModal<ABolim>(
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
}
