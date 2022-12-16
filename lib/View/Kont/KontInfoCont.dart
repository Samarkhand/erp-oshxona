import 'package:erp_oshxona/View/Kont/KontInfoView.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class KontInfoCont with Controller {
  late KontInfoView widget;
  List amaliyotList = [];
  List orderList = [];
  List mahsulotList = [];
  late DateTime sanaD;
  late DateTime sanaG;
  late Kont object;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    object = widget.object;
    sanaD = DateTime(today.year, today.month);
    sanaG = DateTime(today.year, today.month, today.day, 23, 59, 59);
    showLoading(text: "Yuklanmoqda...");
    await loadItems();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> loadItems() async {
    
    // amaliyot
    amaliyotList = [];
    (await Amaliyot.service!.select(where: " kont='${object.tr}' AND sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC")).forEach((key, value) {
      var obj = Amaliyot.fromJson(value);
      Amaliyot.obyektlar[key] = obj;
      amaliyotList.add(obj);
    });
    // order
    orderList = [];
    (await AOrder.service!.select(where: " kont='${object.tr}' AND sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC")).forEach((key, value) {
      var obj = AOrder.fromJson(value);
      AOrder.obyektlar[key] = obj;
      orderList.add(obj);
    });
    // mahsulot
    mahsulotList = [];
    (await AMahsulot.service!.select(where: " kont='${object.tr}' AND sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC")).forEach((key, value) {
      var obj = AMahsulot.fromJson(value);
      AMahsulot.obyektlar[key] = obj;
      mahsulotList.add(obj);
    });
    loadFromGlobal();
  }

  loadFromGlobal(){
    //amaliyotList = Amaliyot.obyektlar.values.toList();
    amaliyotList.sort((a, b) => -a.sana.compareTo(b.sana));
    
    //orderList = AOrder.obyektlar.values.toList();
    orderList.sort((a, b) => -a.sana.compareTo(b.sana));
    
    //mahsulotList = AMahsulot.obyektlar.values.toList();
    mahsulotList.sort((a, b) => -a.sana.compareTo(b.sana));
  }

  Future<void> delete(Kont element) async {
    Navigator.of(context).pop();
    await Amaliyot.service!.deleteId(element.tr);
    Amaliyot.obyektlar.remove(element.tr);
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

}
