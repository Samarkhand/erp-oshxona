import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:erp_oshxona/Model/mah_chiqim_zar.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
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

  List<Mahsulot> mahsulotList = [];
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
    int turi = HujjatTur.zarar.tr;
    await MahChiqimZar.service!.select(where: "trHujjat=${hujjat.tr}").then((values) { 
      for (var value in values) {
        var chiqim = MahChiqimZar.fromJson(value);
        MahChiqimZar.obyektlar.add(chiqim);
        miqdorCont[chiqim.tr] = TextEditingController(text: chiqim.miqdori.toStringAsFixed(chiqim.mahsulot.kasr));
        tannarxiCont[chiqim.tr] = TextEditingController(text: chiqim.tannarxi.toStringAsFixed(2));
      }
    });
  }

  loadFromGlobal() async {
    chiqimList = MahChiqimZar.obyektlar.where((element) => element.trHujjat == hujjat.tr).toList();
    chiqimList.sort(
      (a, b) => -a.tr.compareTo(b.tr), 
    );
    mahsulotList = Mahsulot.obyektlar.values.where((element) => element.turi == mahTuri).toList();
    mahsulotList.sort((a, b) => -b.nomi.compareTo(a.nomi));
    for(var mah in mahsulotList){
      await MTarkib.loadToGlobal(mah.tr);
    }
  }

  qulflash() async {
    final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);

    showLoading(text: "Tarkib tuzilmoqda...");
    for(var chiqim in chiqimList){
      chiqim.qulf = true;
      chiqim.tannarxi = chiqim.tannarxi;
      await MahQoldiq.ozaytirMah(chiqim.mahsulot, miqdor: chiqim.miqdori);
      
      await MahChiqimZar.service!.update({
        'qulf': chiqim.qulf ? 1 : 0,
        'tannarxi': chiqim.tannarxi,
        'trKirim': chiqim.trKirim,
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

  addToList(Mahsulot chiqim) async {
    String? value = await inputDialog(context, "");
    if(value != null){
      num miqdori = num.tryParse(value) ?? 0;
      add(chiqim, miqdori: miqdori);
    }
  }

  add(Mahsulot mah, {num miqdori = 1}) async {
    var chiqim = MahChiqimZar();
    if(chiqimList.contains(chiqim)){
      return;
    }
    //chiqim.turi = HujjatTur.zarar.tr;
    chiqim.tr = await MahChiqimZar.service!.newId(hujjat.tr);
    chiqim.trHujjat = hujjat.tr; 
    chiqim.trMah = mah.tr; 
    chiqim.miqdori = miqdori;
    chiqim.tannarxi = mah.mQoldiq!.tannarxi != 0 ? mah.mQoldiq!.tannarxi : 0;
    chiqim.sana = hujjat.sana;
    chiqim.vaqt = DateTime.now().millisecondsSinceEpoch;
    chiqim.vaqtS = chiqim.vaqt;
    chiqimList.add(chiqim);
    miqdorCont[chiqim.tr] = TextEditingController(text: chiqim.miqdori.toStringAsFixed(chiqim.mahsulot.kasr));
    tannarxiCont[chiqim.tr] = TextEditingController(text: (mah.mQoldiq?.tannarxi ?? 0.00).toStringAsFixed(2));
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
              element.nomi.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

}
