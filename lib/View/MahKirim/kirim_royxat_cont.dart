import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/alert.dart';
import 'package:erp_oshxona/View/MahKirim/kirim_royxat_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class KirimRoyxatCont with Controller {
  late KirimRoyxatView widget;
  List objectList = [];

  late final Hujjat hujjat;

  late DateTime sanaD;
  late DateTime sanaG;

  List<Mahsulot> mahsulotList = [];
  List<MahKirim> kirimList = [];

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
    int turi = MahKirimTur.kirim.tr;
    await MahKirim.service!.select(where: "trHujjat=${hujjat.tr} AND turi=$turi").then((values) { 
      for (var value in values.values) {
        var kirim = MahKirim.fromJson(value);
        MahKirim.obyektlar[kirim.tr] = (kirim);
        miqdorCont[kirim.tr] = TextEditingController(text: kirim.miqdori.toStringAsFixed(kirim.mahsulot.kasr));
        tannarxiCont[kirim.tr] = TextEditingController(text: kirim.tannarxi.toStringAsFixed(2));
      }
    });
  }

  loadFromGlobal() async {
    kirimList = MahKirim.obyektlar.values.where((element) => element.trHujjat == hujjat.tr && element.turi == MahKirimTur.kirim.tr).toList();
    kirimList.sort(
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
    for(var kirim in kirimList){
      kirim.qulf = true;
      kirim.qoldi = kirim.miqdori;
      kirim.tannarxiReal = kirim.tannarxi;
      //kirim.sts = HujjatSts.homAshyoPrt.tr;
      kirim.trQoldiq = await MahQoldiq.kopaytirMah(kirim.mahsulot, miqdor: kirim.miqdori, tannarxi: kirim.tannarxiReal, sotnarxi: kirim.sotnarxi);
      
      await MahKirim.service!.update({
        'qulf': kirim.qulf ? 1 : 0,
        'qoldi': kirim.qoldi,
        'tannarxiReal': kirim.tannarxiReal,
        'trQoldiq': kirim.trQoldiq,
        'vaqtS': vaqts,
      }, where: "tr='${kirim.tr}'");
    }
    hujjat.qulf = true;
    hujjat.sts = HujjatSts.homAshyoPrt.tr;

    await Hujjat.service!.update({
      'qulf': hujjat.qulf ? 1 : 0,
      'sts': hujjat.sts,
      'vaqtS': vaqts,
    }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");

    setState((){
      hujjat;
      kirimList;
    });

    hideLoading();
  }

  tarkibQaytarish() async {
    showLoading(text: "Tarkib tuzilmoqda...");
    hideLoading();
  }

  addToList(Mahsulot kirim) async {
    String? value = await inputDialog(context, "");
    if(value != null){
      num miqdori = num.tryParse(value) ?? 0;
      add(kirim, miqdori: miqdori);
    }
  }

  add(Mahsulot mah, {num miqdori = 1}) async {
    var kirim = MahKirim();
    if(kirimList.contains(kirim)){
      return;
    }
    kirim.turi = MahKirimTur.kirim.tr;
    kirim.tr = await MahKirim.service!.newId();
    kirim.trHujjat = hujjat.tr; 
    kirim.trMah = mah.tr; 
    kirim.miqdori = miqdori;
    kirim.sana = hujjat.sana;
    kirim.vaqt = DateTime.now().millisecondsSinceEpoch;
    kirim.vaqtS = kirim.vaqt;
    kirimList.add(kirim);
    miqdorCont[kirim.tr] = TextEditingController(text: kirim.miqdori.toStringAsFixed(kirim.mahsulot.kasr));
    tannarxiCont[kirim.tr] = TextEditingController(text: (kirim.mahsulot.mQoldiq?.qoldi ?? 0.00).toStringAsFixed(2));
    setState(() => kirimList);
    await kirim.insert();
  }

  remove(MahKirim kirim) async {
    try{
      kirim.delete();
      kirimList.remove(kirim);
    }
    catch(e){
      alertDialog(context, e as Alert);
    }
    finally{
      setState(() => kirimList);
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
