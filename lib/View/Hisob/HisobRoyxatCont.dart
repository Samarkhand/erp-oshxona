import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Hisob/HisobRoyxatView.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class HisobRoyxatCont with Controller {
  late HisobRoyxatView widget;
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

  Future<void> delete(Hisob element) async {
    bool amaliyotBormi = false;
    (await Amaliyot.service!.select(where: " hisob='${element.tr}' LIMIT 0, 1")).forEach((key, value) {
      amaliyotBormi = true;
    });
    
    if(amaliyotBormi || Sozlash.tanlanganHisob.tr == element.tr) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirish mumkin emas. Oldin ishlatilgan"),
        duration: Duration(seconds: 5),
      ));
    } else{
      await Hisob.service!.deleteId(element.tr);
      Hisob.obyektlar.remove(element.tr);
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
    //Hisob.obyektlar = await Hisob.service!.getAll();
    objectList = Hisob.obyektlar.values.toList();
    objectList.sort((a, b) => -b.tartib.compareTo(a.tartib));
  }
}
