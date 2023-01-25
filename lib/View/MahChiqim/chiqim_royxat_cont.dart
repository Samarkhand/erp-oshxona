import 'dart:collection';

import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/alert.dart';
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
  Map<Mahsulot, num> chiqMahMap = {};
  bool mahYetmaydi = false;

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
        chiqMahMap[tarkib.mahsulot] = (chiqMahMap[tarkib.mahsulot] ?? 0) + tarkib.miqdori;
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
    chiqMahMap[tarkib.mahsulot] = (chiqMahMap[tarkib.mahsulot] ?? 0) + tarkib.miqdori;
    setState(() => tarkibList);
    await tarkib.insert();
  }

  remove(MahChiqim tarkib) async {
    try{
      tarkib.delete();
      tarkibList.remove(tarkib);
      miqdorHisobla(tarkib);
      miqdorOchirsinmi(tarkib);
    }
    on ExceptionIW catch (_, e){
      alertDialog(context, _.alert);
    }
    finally{
      setState(() => tarkibList);
    }
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

  qulfla() async {
    showLoading(text: "Qulflashga tayyorlanmoqda...");
    for(var chiq in tarkibList){
      if(await MahQoldiq.sotiladimi(chiq.mahsulot, chiqMahMap[chiq.mahsulot]!) != null){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Qulflab bo'lmaydi"),
          duration: Duration(seconds: 5),
        ));
        hideLoading();
        return;
      }
    }
    Map chiqimla = {};

    showLoading(text: "Tannarx qo'yilmoqda...");
    for(var mah in chiqMahMap.entries){
      var partiyalari = await MahKirim.chiqar(mah.key, mah.value);
      print(partiyalari);
      chiqimla[mah.key.tr] = partiyalari['partiyalar'];
    }
    hideLoading();
    //return;

    showLoading(text: "Qulflanmoqda...");
    final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);
    hujjat.qulf = true;
    hujjat.sts = HujjatSts.tugallangan.tr;
    hujjat.vaqtS = vaqts;
    await Hujjat.service!.update({
      'qulf': 1,
      'sts': hujjat.sts,
      'vaqtS': vaqts,
    }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");

    showLoading(text: "Qoldiqdan ayrilmoqda...");
    for(var chiq in tarkibList){
      MahQoldiq qoldiq = MahQoldiq.obyektlar[chiq.trMah]!;
      List partiyalar = chiqimla[chiq.trMah]!;
      chiq.qulf = true;
      int yangiTr = 0;

      for(int i = 0; i < partiyalar.length; i++){
        if(i == 0){
          chiq.tannarxi = partiyalar[i]['tannarxi'];
          chiq.miqdori = partiyalar[i]['miqdori'];
          chiq.trKirim = partiyalar[i]['trKirim'];
          await MahChiqim.service!.update({
            'qulf': 1,
            'trKirim': chiq.trKirim,
            'tannarxi': chiq.tannarxi,
            'vaqtS': vaqts,
          }, where: "trHujjat='${hujjat.tr}' AND tr='${chiq.tr}'");
          await qoldiq.ozaytir(chiq.miqdori);
        }
        else{
          var chiqFor = MahChiqim.fromJson(chiq.toJson());
          if(yangiTr == 0){
            yangiTr = await MahChiqim.service!.newId(chiq.trHujjat);
          }
          else {
            yangiTr++;
          }
          chiqFor.tr = yangiTr;
          chiqFor.tannarxi = partiyalar[i]['tannarxi'];
          chiqFor.miqdori = partiyalar[i]['miqdori'];
          chiqFor.trKirim = partiyalar[i]['trKirim'];
          chiqFor.vaqt = vaqts*1000;
          chiqFor.vaqtS = vaqts*1000;
          await MahChiqim.service!.insert(chiqFor.toJson());
          await qoldiq.ozaytir(chiqFor.miqdori);
        }
      }
    }
    hideLoading();
  }

  miqdorHisobla(MahChiqim chiqim){
    chiqMahMap[chiqim.mahsulot] = 0;
    for(var chiq in tarkibList.where((element) => element.mahsulot == chiqim.mahsulot)){
      chiqMahMap[chiq.mahsulot] = chiqMahMap[chiq.mahsulot]! + chiq.miqdori;
    }
    setState(() => chiqMahMap[chiqim.mahsulot]);
  }
  miqdorOchirsinmi(MahChiqim chiqim){
    var tarkibla = tarkibList.where((element) => element.mahsulot == chiqim.mahsulot);
    if(tarkibla.isEmpty){
      chiqMahMap.remove(chiqim.mahsulot);
    }
  }

  qulfOch() async {
    showLoading(text: "Qulfdan ochilmoqda");
    final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);
    hujjat.qulf = false;
    hujjat.sts = HujjatSts.ochilgan.tr;
    await Hujjat.service!.update({
      'qulf': hujjat.qulf ? 1 : 0,
      'sts': hujjat.sts,
      'vaqtS': vaqts,
    }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");
    for(var mah in tarkibList){
      MahQoldiq qoldiq = MahQoldiq.obyektlar[mah.trMah]!;
      await qoldiq.kopaytir(mah.miqdori);
      await MahChiqim.service!.update({
        'qulf': hujjat.qulf ? 1 : 0,
        'vaqtS': vaqts,
      }, where: "trHujjat='${hujjat.tr}' AND tr='${mah.tr}'");
    }
    hideLoading();
  }
}
