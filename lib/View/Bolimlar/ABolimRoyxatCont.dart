import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/View/Bolimlar/ABolimRoyxatView.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class ABolimRoyxatCont with Controller {
  late ABolimRoyxatView widget;
  List objectList = [];

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    await loadItems();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> delete(ABolim element) async {
    bool amaliyotBormi = false;
    bool mahsulotBormi = false;
    bool orderBormi = false;
    (await Amaliyot.service!.select(where: " bolim='${element.tr}' LIMIT 0, 1"))
        .forEach((key, value) {
      amaliyotBormi = true;
    });
    (await AMahsulot.service!
            .select(where: " bolim='${element.tr}' LIMIT 0, 1"))
        .forEach((key, value) {
      mahsulotBormi = true;
    });
    (await AOrder.service!.select(where: " bolim='${element.tr}' LIMIT 0, 1"))
        .forEach((key, value) {
      orderBormi = true;
    });

    if (amaliyotBormi ||
        mahsulotBormi ||
        orderBormi ||
        (Sozlash.abolimKomissiya.tr == element.tr ||
            Sozlash.abolimMahUchun.tr == element.tr ||
            Sozlash.abolimMahUchun.tr == element.tr)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirish mumkin emas. Oldin ishlatilgan"),
        duration: Duration(seconds: 5),
      ));
    } else {
      await ABolim.service!.deleteId(element.tr);
      ABolim.obyektlar.remove(element.tr);
      setState(() {
        objectList.remove(element);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirib yuborildi"),
        duration: Duration(seconds: 5),
      ));
    }
  }

  Future<void> loadItems() async {
    //ABolim.obyektlar = await ABolim.service!.getAll();
    objectList = ABolim.obyektlar.values
        .where(((element) =>
            element.turi == widget.turi && element.trBobo == widget.bobo))
        .toList();
    objectList.sort((a, b) => -b.tartib.compareTo(a.tartib));
  }
}
