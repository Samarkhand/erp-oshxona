import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Hisob/HisobIchiView.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/static/mablag.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:select_dialog/select_dialog.dart';

class HisobIchiCont with Controller {
  late HisobIchiView widget;
  late Hisob object;
  List amaliyotList = [];
  List amaliyotListT = [];
  late DateTime sanaD;
  late DateTime sanaG;

  late TextEditingController nomiController;
  final formKey = GlobalKey<FormState>();

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //Hisob.obyektlar = await Hisob.service!.getAll();
    if (widget.yangimi) {
      object = Hisob.bosh();
      object.turi = widget.turi;
    } else if (widget.infomi) {
      sanaD = DateTime(today.year, today.month);
      sanaG = DateTime(today.year, today.month, today.day, 23, 59, 59);
      object = Hisob.obyektlar[widget.tr]!;
      await loadItems();
    } else {
      object = Hisob.obyektlar[widget.tr]!;
    }
    nomiController = TextEditingController(text: object.nomi);
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  saqlashTuriTanlash(context) {
    SelectDialog.showModal<MablagSaqlashTuri>(
      context,
      label: "Bo'lim tanlang",
      selectedValue: MablagSaqlashTuri.obyektlar[object.saqlashTuri],
      items: MablagSaqlashTuri.obyektlar.values
          .where((element) => element.tr != 0)
          .toList(),
      onChange: (selected) {
        setState(() {
          object.saqlashTuri = selected.tr;
        });
        //Navigator.pop(context);
        //hisobTanlash(context);
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      showLoading(text: "Saqlanmoqda");
      object.nomi = nomiController.text;
      if (widget.yangimi) {
        var tr = await Hisob.service!.insert(object.toJson());
        Hisob.obyektlar[tr] = object..tr = tr;
      } else if (!widget.infomi) {
        await Hisob.service!
            .update(object.toJson(), where: " tr='${object.tr}'");
        //Hisob.obyektlar[object.tr] = object;
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

  Future<void> loadItems() async {
    // amaliyot
    amaliyotList = [];
    amaliyotListT = [];
    (await Amaliyot.service!.select(
            where:
                " hisob='${object.tr}' AND sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC"))
        .forEach((key, value) {
      var obj = Amaliyot.fromJson(value);
      Amaliyot.obyektlar[key] = obj;
      amaliyotList.add(obj);
      amaliyotListT.add(obj);
    });
    loadFromGlobal();
  }

  loadFromGlobal() {
    amaliyotList = amaliyotList
        .where((element) =>
            element.hisob == object.tr &&
            (element.turi != AmaliyotTur.transM.tr &&
                element.turi != AmaliyotTur.transP.tr))
        .toList();
    amaliyotList.sort((a, b) => -a.sana.compareTo(b.sana));

    amaliyotListT = amaliyotListT
        .where((element) =>
            element.hisob == object.tr &&
            (element.turi == AmaliyotTur.transM.tr ||
                element.turi == AmaliyotTur.transP.tr))
        .toList();
    amaliyotListT.sort((a, b) => -a.sana.compareTo(b.sana));
  }

  Future<void> sanaTanlashD(BuildContext context, StateSetter setState) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sanaD,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != sanaD) {
      setState(() => sanaD = picked);
    }
  }

  Future<void> sanaTanlashG(BuildContext context, StateSetter setState) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sanaG,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != sanaG) {
      setState(() => sanaG = picked);
    }
  }
}
