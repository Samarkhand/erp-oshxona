import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Bolimlar/MBolimRoyxatView.dart';
import 'package:erp_oshxona/View/asosiy_cont.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class MBolimRoyxatCont with Controller {
  late MBolimRoyxatView widget;
  List objectList = [];

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    await AsosiyCont.kBolimBalansYangila();
    await loadItems();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> delete(MBolim element) async {
    bool kontBormi = false;
    (await Kont.service!.select(where: " bolim='${element.tr}' LIMIT 0, 1")).forEach((key, value) {
      kontBormi = true;
    });
    
    if(kontBormi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirish mumkin emas. Oldin ishlatilgan"),
        duration: Duration(seconds: 5),
      ));
    } else{
      await MBolim.service!.deleteId(element.tr);
      MBolim.obyektlar.remove(element.tr);
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
    //MBolim.obyektlar = await MBolim.service!.getAll();
    objectList = MBolim.obyektlar.values.toList();
    objectList.sort((a, b) => -b.tartib.compareTo(a.tartib));
  }
}
