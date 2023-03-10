import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/View/MahTarqat/partiya_royxat_view.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class HujjatPTRoyxatCont with Controller {
  late HujjatPTRoyxatView widget;
  List<Hujjat> objectList = [];
  late DateTime sanaD;
  late DateTime sanaG;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    sanaD = DateTime(today.year, today.month);
    sanaG = DateTime(today.year, today.month, today.day, 23, 59, 59);
    showLoading(text: "Yuklanmoqda...");
    await loadItems();
    await loadFromGlobal();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> delete(Hujjat element) async {
    await Hujjat.service!.deleteId(element.turi, element.tr);
    Hujjat.obyektlar.remove(element);
    setState(() {
      objectList.remove(element);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("O'chirib yuborildi"),
      duration: Duration(seconds: 5),
    ));
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

  Future<void> loadItems() async {
    var add = " turi=${widget.turi} AND ";
    await Hujjat.service!
        .select(
            where:
                "$add sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)}")
        .then((values) {
      for (var value in values) {
        Hujjat.obyektlar.add(Hujjat.fromJson(value));
      }
    });
    await HujjatPartiya.service!
        .select(
            where:
                " sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)}")
        .then((values) {
      for (var value in values) {
        HujjatPartiya.obyektlar.add(HujjatPartiya.fromJson(value));
      }
    });
  }

  loadFromGlobal() {
    objectList = Hujjat.obyektlar.where((element) => element.turi == widget.turi).toList();
    objectList.sort((a, b) {
      int cmp = -a.sana.compareTo(b.sana);
      if (cmp != 0) return cmp;
      return -a.tr.compareTo(b.tr);
    });
    setState(() => objectList);
  }
}
