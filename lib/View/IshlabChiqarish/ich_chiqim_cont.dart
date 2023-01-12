import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
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
  List<MahChiqim> chiqimList = [];

  Map<int, TextEditingController> buyurtmaCont = {};

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
    await MahChiqim.service!.select(where: "trHujjat=${hujjat.tr} ORDER BY tr DESC").then((values) { 
      for (var value in values) {
        var buyurtma = MahChiqim.fromJson(value);
        MahChiqim.obyektlar.add(buyurtma);
        buyurtmaCont[buyurtma.tr] = TextEditingController(text: buyurtma.miqdori.toStringAsFixed(buyurtma.mahsulot.kasr));
      }
    });
  }

  loadFromGlobal(){
    mahsulotList = Mahsulot.obyektlar.values.where((element) => element.turi == MTuri.homAshyo.tr).toList();
    mahsulotList.sort((a, b) => -b.nomi.compareTo(a.nomi));
  }

  chiqimFromAtribute(){
    chiqimList = MahChiqim.obyektlar.where((element) => element.trHujjat == hujjat.tr).toList();
    chiqimList.sort(
      (a, b) => -a.tr.compareTo(b.tr),
    );
  }
  
  chiqimFromGlobal(){
    chiqimList = MahChiqim.obyektlar.where((element) => element.trHujjat == hujjat.tr).toList();
    chiqimList.sort(
      (a, b) => -a.tr.compareTo(b.tr),
    );
  }
  
  tarkibTuzish() async {
    showLoading(text: "Tarkib tuzilmoqda...");
    List<MTarkib>? barchaTarkib = [];
    for(var obj in chiqimList){
      obj.trMah;
      var tarkiblar = MTarkib.obyektlar[obj.trMah];
      if(tarkiblar != null){
        for(var tarkibMah in tarkiblar){
          barchaTarkib.add(tarkibMah);
        }
      }
    }

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
      add(buyurtma, miqdori: miqdori);
    }
  }

  add(Mahsulot mah, {num miqdori = 1}) async {
    var buyurtma = MahChiqim()..trHujjat=hujjat.tr ..trMah=mah.tr ..miqdori=miqdori;
    if(chiqimList.contains(buyurtma)){
      return;
    }
    buyurtma.sana = hujjat.sana;
    buyurtma.vaqt = DateTime.now().millisecondsSinceEpoch;
    buyurtma.vaqtS = buyurtma.vaqt;
    buyurtma.tr = await MahChiqim.service!.newId(buyurtma.trHujjat);
    chiqimList.add(buyurtma);
    buyurtmaCont[buyurtma.tr] = TextEditingController(text: buyurtma.miqdori.toStringAsFixed(buyurtma.mahsulot.kasr));
    setState(() => chiqimList);
    await buyurtma.insert();
  }

  remove(MahChiqim buyurtma) async {
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
