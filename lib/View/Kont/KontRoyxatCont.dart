import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Kont/KontRoyxatView.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class KontRoyxatCont with Controller {
  late KontRoyxatView widget;
  List objectList = [];
  Map<String, Map<String, String>> validated = {};

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

  Future<void> delete(Kont element) async {
    bool amaliyotBormi = false;
    bool mahsulotBormi = false;
    bool orderBormi = false;
    (await Amaliyot.service!.select(where: " kont='${element.tr}' LIMIT 0, 1")).forEach((key, value) {
      amaliyotBormi = true;
    });
    (await AMahsulot.service!.select(where: " kont='${element.tr}' LIMIT 0, 1")).forEach((key, value) {
      mahsulotBormi = true;
    });
    (await AOrder.service!.select(where: " kont='${element.tr}' LIMIT 0, 1")).forEach((key, value) {
      orderBormi = true;
    });
    
    if(amaliyotBormi || mahsulotBormi || orderBormi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirish mumkin emas. Oldin ishlatilgan"),
        duration: Duration(seconds: 5),
      ));
    } else{
      await Kont.service!.deleteId(element.tr);
      Kont.obyektlar.remove(element.tr);
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
    //Kont.obyektlar = await Kont.service!.getAll();
    objectList = Kont.obyektlar.values.toList();
  }
}
