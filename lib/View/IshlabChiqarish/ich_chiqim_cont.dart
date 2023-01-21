import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:erp_oshxona/Model/mah_chiqim_ich.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/alert.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_chiqim_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class IchiChiqimRoyxatCont with Controller {
  late IchiChiqimRoyxatView widget;
  List objectList = [];

  late final Hujjat hujjat;
  late final HujjatPartiya partiya;
  late List<Map> barchaTarkib;

  late DateTime sanaD;
  late DateTime sanaG;

  List<Mahsulot> mahsulotList = [];
  List<MahChiqimIch> chiqimList = [];

  Map<int, TextEditingController> buyurtmaCont = {};

  Map<Mahsulot, num> mahChiqim = {};
  Map<Mahsulot, num> mahQoldiq = {};

  Future<void> init(widget, Function setState, {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;

    hujjat = widget.partiya.hujjat;
    partiya = widget.partiya;
    barchaTarkib = widget.barchaTarkib;

    showLoading(text: "Yuklanmoqda...");
    if(barchaTarkib.isEmpty){
      await loadItems();
      await chiqimFromGlobal();
    }
    else {
      await chiqimFromAtribute();
    }
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
    await MahChiqimIch.service!.select(where: "trHujjat=${hujjat.tr} ORDER BY tr DESC").then((values) { 
      for (var value in values) {
        var buyurtma = MahChiqimIch.fromJson(value);
        MahChiqimIch.obyektlar.add(buyurtma);
        buyurtmaCont[buyurtma.tr] = TextEditingController(text: buyurtma.miqdori.toStringAsFixed(3));
      }
    });
  }

  loadFromGlobal(){
    mahsulotList = Mahsulot.obyektlar.values.where((element) => element.turi == MTuri.homAshyo.tr).toList();
    mahsulotList.sort((a, b) => -b.nomi.compareTo(a.nomi));
  }

  chiqimFromAtribute() async {
    chiqimList = [];
    for(var map in barchaTarkib){
      await add(Mahsulot.obyektlar[map['mahTarkib']]!, map['miqdoriChiq']);
    }
    chiqimList.sort(
      (a, b) => -a.tr.compareTo(b.tr),
    );
  }

  chiqimFromGlobal(){
    chiqimList = MahChiqimIch.obyektlar.where((element) => element.trHujjat == hujjat.tr).toList();
    chiqimList.sort(
      (a, b) => -a.tr.compareTo(b.tr),
    );
  }

  qulflash() async {
    final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);
    showLoading(text: "Tarkib tuzilmoqda...");
    for(var chiqim in chiqimList){
      try{
        await MahQoldiq.ozaytirMah(chiqim.mahsulot, miqdor: chiqim.miqdori);
      }
      on ExceptionIW catch (e){
        alertDialog(context, e.alert);
      }
    }

    int turi = MahKirimTur.kirimIch.tr;
    var kirimla = await MahKirim.service!.select(where: "trHujjat=${hujjat.tr} AND turi=$turi");
    for (var value in kirimla.values) {
      var kirim = MahKirim.fromJson(value);
      
      kirim.qulf = true;
      kirim.qoldi = kirim.miqdori;
      kirim.tannarxiReal = kirim.tannarxi;
      kirim.trQoldiq = await MahQoldiq.kopaytirMah(kirim.mahsulot, miqdor: kirim.miqdori, tannarxi: kirim.tannarxiReal);
      
      await MahKirim.service!.update({
        'qulf': kirim.qulf ? 1 : 0,
        'qoldi': kirim.qoldi,
        'tannarxiReal': kirim.tannarxiReal,
        'trQoldiq': kirim.trQoldiq,
        'vaqtS': vaqts,
      }, where: "tr='${kirim.tr}'");
    }

    var hujjatTarqat = Hujjat(HujjatTur.tarqatish.tr);
    hujjatTarqat.tr = await Hujjat.service!.newId(hujjatTarqat.turi);
    hujjatTarqat.qulf = false;
    hujjatTarqat.trHujjat = partiya.hujjat.tr;
    hujjatTarqat.sana = partiya.sana;
    hujjatTarqat.vaqt = vaqts;
    hujjatTarqat.vaqtS = vaqts;
    await hujjatTarqat.insert();
    hideLoading();
  }

  tarkibQaytarish() async {
    showLoading(text: "Tarkib tuzilmoqda...");
    hideLoading();
  }

  addToList(Mahsulot buyurtma) async {
    String? value = await inputDialog(context, "");
    if(value != null){
      num miqdori = num.tryParse(value) ?? 0;
      await add(buyurtma, miqdori);
    }
  }

  add(Mahsulot mah, [num miqdori = 1]) async {
    var chiqim = MahChiqimIch();
    chiqim.trHujjat = partiya.trChiqim;
    chiqim.tr = await MahChiqimIch.service!.newId(chiqim.trHujjat);
    chiqim.trMah = mah.tr;
    chiqim.miqdori = miqdori;
    chiqim.sana = partiya.sana;
    chiqim.vaqt = DateTime.now().millisecondsSinceEpoch;
    chiqim.vaqtS = chiqim.vaqt;
    chiqimList.add(chiqim);
    buyurtmaCont[chiqim.tr] = TextEditingController(text: chiqim.miqdori.toStringAsFixed(3));
    setState(() => chiqimList);
    await chiqim.insert();
  }

  remove(MahChiqimIch buyurtma) async {
    chiqimList.remove(buyurtma);
    setState(() => chiqimList);
    buyurtma.delete();
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

  Map _brtmJonatganiMalumot(){
    return {
      'hujjat': hujjat.toJson(),
      'mahsulotlar': chiqimList.map((e) => e.toJson()).toList(),
    };
  }
}
