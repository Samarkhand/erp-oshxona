import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Amaliyot/AmaliyotRoyxatView.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class AmaliyotRoyxatCont with Controller {
  late AmaliyotRoyxatView widget;
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

  Future<void> delete(Amaliyot element) async {
    await Amaliyot.service!.deleteId(element.tr);
    Amaliyot.obyektlar.remove(element.tr);

    if (element.hisob != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[element.hisob]!;
      if (AmaliyotTur.tushum.tr == element.turi) {
        ushbuHisob.balansOzaytir(element.miqdor);
      } else if (AmaliyotTur.chiqim.tr == element.turi) {
        ushbuHisob.balansKopaytir(element.miqdor);
      } else if (AmaliyotTur.transP.tr == element.turi) {
        ushbuHisob.balansOzaytir(element.miqdor);
      } else if (AmaliyotTur.transM.tr == element.turi) {
        ushbuHisob.balansKopaytir(element.miqdor);
      }
    } else {
      throw Exception("Hisob tanlanmagan. Hisob tanlang");
    }
    
    if (element.kont != 0) {
      Kont ushbuKont = Kont.obyektlar[element.kont]!;
      if (AmaliyotTur.tushum.tr == element.turi) {
        ushbuKont.balansOzaytir(element.miqdor);
      } else if (AmaliyotTur.chiqim.tr == element.turi) {
        ushbuKont.balansKopaytir(element.miqdor);
      }
    }

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
    (await Amaliyot.service!.select(where: " sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC")).forEach((key, value) {
      Amaliyot.obyektlar[key] = Amaliyot.fromJson(value);
    });
    loadFromGlobal();
  }

  loadFromGlobal(){
    objectList = Amaliyot.obyektlar.values.toList();
    objectList.sort((a, b) => -a.sana.compareTo(b.sana));
  }
}
