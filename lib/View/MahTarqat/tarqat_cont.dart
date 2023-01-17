import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/mah_chiqim_ich.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/View/MahTarqat/tarqat_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class TarqatishCont with Controller {
  late TarqatishView widget;
  List objectList = [];

  late final Hujjat hujjat;
  late final HujjatPartiya partiya;

  Kont? hodim;
  List<Hujjat> tarqatilganlar = [];
  List<MahKirim> taomnoma = [];
  Map<int, double> taomnomaMiqdor = {};
  Map<int, TextEditingController> taomnomaCont = {};

  TextEditingController tagInputCont = TextEditingController();
  FocusNode tagInputFN = FocusNode();

  Future<void> init(widget, Function setState, {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;

    hujjat = widget.hujjat;
    partiya = HujjatPartiya.ol(hujjat.trHujjat)!;

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

  Future<void> loadItems() async {}

  loadFromGlobal(){
    int turi = MahKirimTur.kirimIch.tr;
    for (var ent in MahKirim.obyektlar.entries.where((element) => element.value.trHujjat==partiya.trHujjat && element.value.turi==turi)){
      var kirim = ent.value;
      taomnoma.add(kirim);
      taomnomaCont[kirim.tr] = TextEditingController(text: kirim.miqdori.toStringAsFixed(kirim.mahsulot.kasr));
    }
  }

  addToList(Kont kont) async {
    String? value = await inputDialog(context, "");
    if(value != null){
      await add(kont, taomnoma);
    }
  }

  add(Kont kont, List<MahKirim> mahsulotlar) async {
    var tarqatish = Hujjat(HujjatTur.tarqatish.tr);
    tarqatish.trHujjat = partiya.trChiqim;
    tarqatish.tr = await MahChiqimIch.service!.newId(tarqatish.trHujjat);
    tarqatish.trHujjat = hujjat.tr;
    tarqatish.sana = partiya.sana;
    tarqatish.vaqt = DateTime.now().millisecondsSinceEpoch;
    tarqatish.vaqtS = tarqatish.vaqt;
    tarqatilganlar.add(tarqatish);
    setState(() => tarqatilganlar);
    await tarqatish.insert();
  }

  remove(Hujjat tarqatish) async {
    tarqatilganlar.remove(tarqatish);
    setState(() => tarqatilganlar);
  }

  kontTop(String tag){
    try{
      MapEntry<int, Kont> varvar = Kont.obyektlar.entries.firstWhere((element) => element.value.tag == tag);
      setState(() => hodim = varvar.value);
    }
    catch(e){
      setState(() => hodim = null);
    }
  }
}
