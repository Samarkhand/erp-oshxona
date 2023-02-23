import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/hujjat_tarqat.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mah_tarqat.dart';
import 'package:erp_oshxona/View/MahTarqat/tarqat_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:select_dialog/select_dialog.dart';

class TarqatishCont with Controller {
  late TarqatishView widget;
  List objectList = [];

  late final Hujjat hujjat;
  late final HujjatPartiya partiya;

  Kont? hodim;
  List<HujjatTarqat> tarqatilganlar = [];
  List<MahKirim> taomnoma = [];
  Map<int, double> taomnomaMiqdor = {};
  Map<int, TextEditingController> taomnomaCont = {};

  TextEditingController tagInputCont = TextEditingController();
  FocusNode tagInputFN = FocusNode();
  FocusNode keyListenerFN = FocusNode();
  FocusNode kontAddFN = FocusNode();

  Map<int, int> ikkinchiHujjat = {};

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

  Future<void> loadItems() async {
    await HujjatTarqat.service!.select().then((values) {
      for (var value in values) {
        var hujjatTarqat = HujjatTarqat.fromJson(value);
        ikkinchiHujjat[hujjatTarqat.trKont] = (ikkinchiHujjat[hujjatTarqat.trKont] ?? 0) + 1;
        tarqatilganlar.add(hujjatTarqat);
        HujjatTarqat.obyektlar.add(hujjatTarqat);
      }
    });
  }

  loadFromGlobal() async {
    int turi = MahKirimTur.kirimIch.tr;
    for (var ent in MahKirim.obyektlar.entries.where((element) => element.value.trHujjat==partiya.trHujjat && element.value.turi==turi)){
      var kirim = ent.value;
      taomnoma.add(kirim);
      taomnomaCont[kirim.tr] = TextEditingController(text: /*kirim.miqdori*/1.toStringAsFixed(kirim.mahsulot.kasr));
    }
  }

  addToList(Kont kont) async {
    String? value = await inputDialog(context, "");
    if(value != null){
      await add(kont, taomnoma);
    }
  }

  bool kontLoading = false;

  add(Kont? kont, List<MahKirim> mahsulotlar, {String izoh = ''}) async {
    var ikh = false;
    kontLoading = true;
    var tarqatish = HujjatTarqat();
    tarqatish.trHujjat = hujjat.tr;
    tarqatish.qulf = true;
    if(kont != null){
      tarqatish.trKont = kont.tr;
      tarqatish.kodi = kont.tag;
      var list = tarqatilganlar.where((element) => element.trKont == kont.tr);
      ikkinchiHujjat[kont.tr] = list.length + 1;
      if(list.isNotEmpty){}
    }
    tarqatish.sana = partiya.sana;
    tarqatish.vaqt = DateTime.now().millisecondsSinceEpoch;
    tarqatish.vaqtS = tarqatish.vaqt;
    tarqatish.izoh = izoh;

    tarqatilganlar.add(tarqatish);
    setState(() {tarqatilganlar;hodim = null;});
    tarqatish.tr = await tarqatish.insert();

    var tr = await MahTarqat.service!.newId(tarqatish.tr);
    for(var kirim in taomnoma){
      var mahTarqat = MahTarqat();
      mahTarqat.trHujjat = tarqatish.tr;
      mahTarqat.tr = tr;
      mahTarqat.qulf = true;
      mahTarqat.trKont = (kont != null) ? kont.tr : 0;
      mahTarqat.trMah = kirim.trMah;
      mahTarqat.trKirim = kirim.tr;
      mahTarqat.miqdori = taomnomaMiqdor[kirim.tr]!;
      mahTarqat.tannarxi = kirim.tannarxiReal;
      mahTarqat.sana = tarqatish.sana;
      mahTarqat.vaqt = tarqatish.vaqt;
      mahTarqat.vaqtS = tarqatish.vaqt;
      mahTarqat.nomi = mahTarqat.mahsulot.nomi;
      mahTarqat.kodi = tarqatish.kodi;
      mahTarqat.izoh = izoh;
      await mahTarqat.insert();
      await kirim.ozaytir(mahTarqat.miqdori);
      await mahTarqat.mahsulot.mQoldiq!.ozaytir(mahTarqat.miqdori);
      tr++;
    }
    setState((){
      taomnoma;
    });
    await Future.delayed(const Duration(seconds: 2));
    kontLoading = false;
  }

  remove(HujjatTarqat tarqatish) async {
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

  Future<String?> izohSora() async {
    String? qiymat = '';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Izoh kiriting"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Izoh"),
            onChanged: ((value) => qiymat = value),
            onSubmitted: (value) {
              qiymat = value;
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Bekor', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                qiymat = null;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Saqlash'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
      return qiymat;
  }

  saqlashTuriTanlash(context) {
    SelectDialog.showModal<MahQoldiq>(
      context,
      label: "Menyuga qo'shgani maxsulot tanlang",
      items: MahQoldiq.obyektlar.values.where((element) => element.qoldi > 0)
          .toList(),
      onChange: (selected) {
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      itemBuilder: (context, item, isSelected) {
        return ListTile(
          title: Text(item.mahsulot!.nomi),
          subtitle: Text("${item.qoldi.toStringAsFixed(item.mahsulot!.kasr)} ${item.mOlchov.nomi}"),
        );
      },
    );
  }
  
}
