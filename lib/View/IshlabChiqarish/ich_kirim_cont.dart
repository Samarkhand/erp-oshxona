import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_chiqim_view.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_kirim_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class IchKirimRoyxatCont with Controller {
  late IchKirimRoyxatView widget;
  List objectList = [];

  late final Hujjat hujjat;
  late final HujjatPartiya partiya;

  late DateTime sanaD;
  late DateTime sanaG;

  List<Mahsulot> mahsulotList = [];
  List<MahKirim> kirimList = [];

  Map<int, TextEditingController> miqdorCont = {};

  Future<void> init(widget, Function setState, {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;

    hujjat = widget.partiya.hujjat;
    partiya = widget.partiya;

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
    await MahKirim.service!.select(where: "trHujjat=${hujjat.tr} ORDER BY tr DESC").then((values) { 
      for (var value in values.values) {
        var kirim = MahKirim.fromJson(value);
        MahKirim.obyektlar[kirim.tr] = (kirim);
        miqdorCont[kirim.tr] = TextEditingController(text: kirim.miqdori.toStringAsFixed(kirim.mahsulot.kasr));
      }
    });
  }

  loadFromGlobal(){
    kirimList = MahKirim.obyektlar.values.where((element) => element.trHujjat == hujjat.tr).toList();
    kirimList.sort(
      // Comparison function not necessary here, but shown for demonstrative purposes 
      (a, b) => -a.tr.compareTo(b.tr), 
    );
    mahsulotList = Mahsulot.obyektlar.values.where((element) => element.turi == MTuri.mahsulot.tr).toList();
    mahsulotList.sort((a, b) => -b.nomi.compareTo(a.nomi));
  }
  
  tarkibTuzish() async {
    showLoading(text: "Tarkib tuzilmoqda...");
    List<Map>? barchaTarkib = [];
    for(var obj in kirimList){
      obj.trMah;
      var tarkiblar = MTarkib.obyektlar[obj.trMah];
      if(tarkiblar != null){
        for(var tarkibMah in tarkiblar){
          barchaTarkib.add({
            'mah' : tarkibMah.trMah,
            'mahTarkib' : tarkibMah.trMahTarkib,
            'miqdori' : tarkibMah.miqdori,
            'miqdoriChiq' : tarkibMah.miqdori * obj.miqdori,
          });
        }
      }
    }
    final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);
    //hujjat.qulf = true;
    hujjat.sts = HujjatSts.homAshyoPrt.tr;
    Hujjat.service!.update({
      'qulf': hujjat.qulf ? 1 : 0,
      'sts': hujjat.sts,
      'vaqtS': vaqts,
    }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");

    var hujjatKir = Hujjat(HujjatTur.kirimIch.tr);
    hujjatKir.tr = await Hujjat.service!.newId(hujjatKir.turi);
    hujjatKir.qulf = true;
    //hujjatKir.sts = 0;
    hujjatKir.trHujjat = hujjat.tr;
    hujjatKir.sana = vaqts;
    hujjatKir.vaqt = vaqts;
    hujjatKir.vaqtS = vaqts;
    await hujjatKir.insert();

    var hujjatChiq = Hujjat.fromJson(hujjatKir.toJson());
    hujjatChiq.turi = HujjatTur.chiqimIch.tr;
    hujjatChiq.tr = await Hujjat.service!.newId(hujjatChiq.turi);
    hujjatChiq.qulf = false;
    await hujjatChiq.insert();

    partiya.trKirim = hujjatKir.tr;
    partiya.trChiqim = hujjatChiq.tr;
    partiya.update();

    // ignore: use_build_context_synchronously
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IchiChiqimRoyxatView(partiya, barchaTarkib),
      ),
    );

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
    kirim.turi=MahKirimTur.kirimIch.tr;
    kirim.tr = await MahKirim.service!.newId();
    kirim.trHujjat=hujjat.tr; 
    kirim.trMah=mah.tr; 
    kirim.miqdori=miqdori;
    kirim.sana = hujjat.sana;
    kirim.vaqt = DateTime.now().millisecondsSinceEpoch;
    kirim.vaqtS = kirim.vaqt;
    kirimList.add(kirim);
    miqdorCont[kirim.tr] = TextEditingController(text: kirim.miqdori.toStringAsFixed(kirim.mahsulot.kasr));
    setState(() => kirimList);
    await kirim.insert();
  }

  remove(MahKirim kirim) async {
    kirimList.remove(kirim);
    setState(() => kirimList);
    kirim.delete();
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
