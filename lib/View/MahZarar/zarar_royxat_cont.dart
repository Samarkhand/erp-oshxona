import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:erp_oshxona/Model/mah_chiqim_zar.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/alert.dart';
import 'package:erp_oshxona/View/MahZarar/zarar_royxat_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class ChiqZararRoyxatCont with Controller {
  late ChiqZararRoyxatView widget;
  List objectList = [];

  late final Hujjat hujjat;

  late DateTime sanaD;
  late DateTime sanaG;

  List<MahKirim> mahsulotList = [];
  List<MahChiqimZar> chiqimList = [];

  Map<int, TextEditingController> miqdorCont = {};
  Map<int, TextEditingController> tannarxiCont = {};

  int mahTuri = MTuri.homAshyo.tr;

  Future<void> init(widget, Function setState, {required BuildContext context}) async {
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
    (await Kont.service!.select(where: " bolim='${element.tr}' LIMIT 0, 1")).forEach((key, value) {
      kontBormi = true;
    });
    
    if(kontBormi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirish mumkin emas. Oldin ishlatilgan"),
        duration: Duration(seconds: 5),
      ));
    } else{
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
    await MahChiqimZar.service!.select(where: "trHujjat=${hujjat.tr}").then((values) { 
      for (var value in values) {
        var chiqim = MahChiqimZar.fromJson(value);
        MahChiqimZar.obyektlar.add(chiqim);
        miqdorCont[chiqim.tr] = TextEditingController(text: chiqim.miqdori.toStringAsFixed(chiqim.mahsulot.kasr));
        //tannarxiCont[chiqim.tr] = TextEditingController(text: chiqim.tannarxi.toStringAsFixed(2));
      }
    });
  }

  loadFromGlobal() async {
    chiqimList = MahChiqimZar.obyektlar.where((element) => element.trHujjat == hujjat.tr).toList();
    chiqimList.sort(
      (a, b) => -a.tr.compareTo(b.tr), 
    );
    mahsulotList = MahKirim.obyektlar.values.where((element) => element.qulf && element.qoldi > 0 && element.mahsulot.turi == mahTuri).toList();
    mahsulotList.sort((a, b) => -b.mahsulot.nomi.compareTo(a.mahsulot.nomi));
    for(var mah in mahsulotList){
      await MTarkib.loadToGlobal(mah.tr);
    }
  }

  qulflash() async {
    showLoading(text: "Qulflashga tayyorlanmoqda...");
    for(var chiq in chiqimList){
      var alert = await MahKirim.qoldimi(chiq.kirim, chiq.miqdori);
      if(alert != null){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Qulflab bo'lmaydi"),
          duration: Duration(seconds: 5),
        ));
        return;
      }
    }
    final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);

    showLoading(text: "Qulflanmoqda...");
    for(var chiqim in chiqimList){
      await MahKirim.obyektlar[chiqim.trKirim]!.ozaytir(chiqim.miqdori);
      await chiqim.mahsulot.mQoldiq!.ozaytir(chiqim.miqdori);
      
      chiqim.qulf = true;
      await MahChiqimZar.service!.update({
        'qulf': chiqim.qulf ? 1 : 0,
        'vaqtS': vaqts,
      }, where: "tr='${chiqim.tr}'");
    }

    hujjat.qulf = true;
    hujjat.sts = HujjatSts.tugallangan.tr;

    await Hujjat.service!.update({
      'qulf': hujjat.qulf ? 1 : 0,
      'sts': hujjat.sts,
      'vaqtS': vaqts,
    }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");

    setState((){
      hujjat;
      chiqimList;
    });

    hideLoading();
  }

  addToList(MahKirim mah) async {
    String? value = await inputDialog(context, "");
    if(value != null){
      num miqdori = num.tryParse(value) ?? 0;
      add(mah, miqdori: miqdori);
    }
  }

  add(MahKirim mah, {num miqdori = 1}) async {
    var chiqim = MahChiqimZar();
    if(chiqimList.contains(chiqim)){
      return;
    }
    //chiqim.turi = HujjatTur.zarar.tr;
    chiqim.tr = await MahChiqimZar.service!.newId(hujjat.tr);
    chiqim.trHujjat = hujjat.tr; 
    chiqim.trMah = mah.trMah; 
    chiqim.trKirim = mah.tr; 
    chiqim.miqdori = miqdori;
    chiqim.tannarxi = mah.tannarxi;
    chiqim.sana = hujjat.sana;
    chiqim.vaqt = DateTime.now().millisecondsSinceEpoch;
    chiqim.vaqtS = chiqim.vaqt;
    chiqimList.add(chiqim);
    miqdorCont[chiqim.tr] = TextEditingController(text: chiqim.miqdori.toStringAsFixed(chiqim.mahsulot.kasr));
    tannarxiCont[chiqim.tr] = TextEditingController(text: mah.tannarxi.toStringAsFixed(2));
    setState(() => chiqimList);
    await chiqim.insert();
  }

  remove(MahChiqimZar chiqim) async {
    try{
      await chiqim.delete();
      chiqimList.remove(chiqim);
    }
    on ExceptionIW catch (_, e){
      alertDialog(context, _.alert);
    }
    finally{
      setState(() => chiqimList);
    }
  }

  mahIzlash(String value){
    loadFromGlobal();
    setState(() {
      mahsulotList = mahsulotList
          .where((element) =>
              element.mahsulot.nomi.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

}
