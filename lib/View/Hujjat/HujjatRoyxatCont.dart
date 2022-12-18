import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatRoyxatView.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class HujjatRoyxatCont with Controller {
  late HujjatRoyxatView widget;
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
    loadFromGlobal();
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
    var add = widget.turi != null ? " turi=${widget.turi!} AND " : "";
    (await Hujjat.service!.select(where: "$add sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC, tr DESC")).forEach((key, value) {
      Hujjat.obyektlar.add(Hujjat.fromJson(value));
    });
  }

  loadFromGlobal(){
    objectList = (widget.turi != null ? Hujjat.olList(widget.turi!) : Hujjat.obyektlar).toList();
    objectList.sort((a, b) => -a.sana.compareTo(b.sana));
  }
}
