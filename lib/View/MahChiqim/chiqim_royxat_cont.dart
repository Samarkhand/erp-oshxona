import 'dart:collection';

import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/View/MahChiqim/chiqim_royxat_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class ChiqimRoyxatCont with Controller {
  late ChiqimRoyxatView widget;
  List objectList = [];

  late final Hujjat hujjat;

  late DateTime sanaD;
  late DateTime sanaG;

  List<Mahsulot> mahsulotList = [];
  Set<MahChiqim> tarkibList = {};

  Map<int, TextEditingController> tarkibCont = {};

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;

    hujjat = widget.hujjat;
    showLoading(text: "Yuklanmoqda...");
    await loadItems();
    await loadFromGlobal();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> delete(KBolim element) async {
    bool kontBormi = false;
    (await Kont.service!.select(where: " bolim='${element.tr}' LIMIT 0, 1"))
        .forEach((key, value) {
      kontBormi = true;
    });

    if (kontBormi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirish mumkin emas. Oldin ishlatilgan"),
        duration: Duration(seconds: 5),
      ));
    } else {
      await KBolim.service!.deleteId(element.tr);
      KBolim.obyektlar.remove(element.tr);
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
    await MahChiqim.service!
        .select(where: "trHujjat=${hujjat.tr} ORDER BY tr DESC")
        .then((values) {
      for (var value in values) {
        var tarkib = MahChiqim.fromJson(value);
        MahChiqim.obyektlar.add(tarkib);
        tarkibCont[tarkib.tr] = TextEditingController(
            text: tarkib.miqdori.toStringAsFixed(tarkib.mahsulot.kasr));
      }
    });
  }

  loadFromGlobal() {
    tarkibList = MahChiqim.obyektlar
        .where((element) => element.trHujjat == hujjat.tr)
        .toSet();
    tarkibList = SplayTreeSet.from(
      tarkibList,
      // Comparison function not necessary here, but shown for demonstrative purposes
      (a, b) => -a.tr.compareTo(b.tr),
    );
    mahsulotList = Mahsulot.obyektlar.values
        .where((element) => element.turi == MTuri.homAshyo.tr && element.mQoldiq != null && element.mQoldiq!.qoldi != 0)
        .toList();
    mahsulotList.sort((a, b) => -b.nomi.compareTo(a.nomi));
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

  addToList(Mahsulot tarkib) async {
    String? value = await inputDialog(context, "");
    if (value != null) {
      num miqdori = num.tryParse(value) ?? 0;
      add(tarkib, miqdori: miqdori);
    }
  }

  add(Mahsulot mah, {num miqdori = 1}) async {
    var tarkib = MahChiqim()
      ..trHujjat = hujjat.tr
      ..trMah = mah.tr
      ..miqdori = miqdori;
    if (tarkibList.contains(tarkib)) {
      return;
    }
    tarkib.sana = hujjat.sana;
    tarkib.vaqt = DateTime.now().millisecondsSinceEpoch;
    tarkib.vaqtS = tarkib.vaqt;
    tarkib.tr = await MahChiqim.service!.newId(tarkib.trHujjat);
    tarkibList.add(tarkib);
    tarkibCont[tarkib.tr] = TextEditingController(
        text: tarkib.miqdori.toStringAsFixed(tarkib.mahsulot.kasr));
    setState(() => tarkibList);
    await tarkib.insert();
  }

  remove(MahChiqim tarkib) async {
    tarkibList.remove(tarkib);
    setState(() => tarkibList);
    tarkib.delete();
  }

  mahIzlash(String value) {
    loadFromGlobal();
    setState(() {
      mahsulotList = mahsulotList
          .where((element) => element.turi == MTuri.homAshyo.tr &&
              element.nomi.toLowerCase().contains(value.toLowerCase()) &&
              element.mQoldiq != null
            )
          .toList();
    });
  }

  qulfla() {
    final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);
    hujjat.qulf = true;
    hujjat.sts = HujjatSts.tugallangan.tr;
    Hujjat.service!.update({
      'qulf': hujjat.qulf ? 1 : 0,
      'sts': hujjat.sts,
      'vaqtS': vaqts,
    }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");
    for(var mah in tarkibList){
      MahQoldiq qoldiq = MahQoldiq.obyektlar[mah.trMah]!;
      qoldiq.ozaytir(mah.miqdori);
      MahChiqim.service!.update({
        'qulf': hujjat.qulf ? 1 : 0,
        'vaqtS': vaqts,
      }, where: "trHujjat='${hujjat.tr}' AND tr='${mah.tr}'");
    }
    setState(() => hujjat);
  }
}
