import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/AOrder/AOrderRoyxatView.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class AOrderRoyxatCont with Controller {
  late AOrderRoyxatView widget;
  List objectList = [];
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
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> delete(AOrder element) async {
    await AOrder.service!.deleteId(element.tr);
    AOrder.obyektlar.remove(element.tr);
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
    (await AOrder.service!.select(where: "  sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC")).forEach((key, value) {
      AOrder.obyektlar[key] = AOrder.fromJson(value);
    });
    loadFromGlobal();
  }

  loadFromGlobal(){
    objectList = AOrder.obyektlar.values.toList();
    objectList.sort((a, b) => -a.sana.compareTo(b.sana));
  }
}
