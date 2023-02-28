import 'package:erp_oshxona/Library/api_string.dart';
import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/hujjat_tarqat.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mah_tarqat.dart';
import 'package:erp_oshxona/View/MahTarqat/tarqat_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
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
  Map<int, TextEditingController> taomnomaCont = {};
  Set<MahQoldiq> qoshimcha = {};
  Map<int, TextEditingController> qoshimchaCont = {};

  TextEditingController tagInputCont = TextEditingController();
  FocusNode tagInputFN = FocusNode();
  FocusNode keyListenerFN = FocusNode();
  FocusNode kontAddFN = FocusNode();

  Map<int, int> ikkinchiHujjat = {};

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
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

  Future<void> loadItems() async {
    await HujjatTarqat.service!.select().then((values) {
      for (var value in values) {
        var hujjatTarqat = HujjatTarqat.fromJson(value);
        ikkinchiHujjat[hujjatTarqat.trKont] =
            (ikkinchiHujjat[hujjatTarqat.trKont] ?? 0) + 1;
        tarqatilganlar.add(hujjatTarqat);
        HujjatTarqat.obyektlar.add(hujjatTarqat);
      }
    });
  }

  loadFromGlobal() async {
    int turi = MahKirimTur.kirimIch.tr;
    for (var ent in MahKirim.obyektlar.entries.where((element) =>
        element.value.trHujjat == partiya.trHujjat &&
        element.value.turi == turi)) {
      var kirim = ent.value;
      taomnoma.add(kirim);
      taomnomaCont[kirim.tr] = TextEditingController(
          text: /*kirim.miqdori*/ 1.toStringAsFixed(kirim.mahsulot.kasr));
    }
  }

  addToList(Kont kont) async {
    String? value = await inputDialog(context, "");
    if (value != null) {
      await add(kont, taomnoma);
    }
  }

  bool kontLoading = false;

  add(Kont? kont, List<MahKirim> mahsulotlar, {String izoh = ''}) async {
    kontLoading = true;
    var tarqatish = HujjatTarqat();
    tarqatish.trHujjat = hujjat.tr;
    tarqatish.qulf = true;
    if (kont != null) {
      tarqatish.trKont = kont.tr;
      tarqatish.kodi = kont.tag;
      var list = tarqatilganlar.where((element) => element.trKont == kont.tr);
      ikkinchiHujjat[tarqatish.trKont] = list.length + 1;
      if (list.isNotEmpty) {}
    }
    tarqatish.sana = partiya.sana;
    tarqatish.vaqt = DateTime.now().millisecondsSinceEpoch;
    tarqatish.vaqtS = tarqatish.vaqt;
    tarqatish.izoh = izoh;

    tarqatilganlar.add(tarqatish);
    setState(() {
      tarqatilganlar;
      hodim = null;
    });
    tarqatish.tr = await tarqatish.insert();

    var tr = await MahTarqat.service.newId(tarqatish.tr);
    for (var kirim in taomnoma) {
      var mahTarqat = MahTarqat();
      mahTarqat.trHujjat = tarqatish.tr;
      mahTarqat.tr = tr;
      mahTarqat.qulf = true;
      mahTarqat.trKont = (kont != null) ? kont.tr : 0;
      mahTarqat.trMah = kirim.trMah;
      mahTarqat.trKirim = kirim.tr;
      mahTarqat.miqdori = taomnomaCont[kirim.tr]!.text.parseNum();
      mahTarqat.tannarxi = kirim.tannarxiReal;
      mahTarqat.chiqnarxi = kirim.tannarxiReal;
      mahTarqat.chiqnarxiReal = mahTarqat.chiqnarxi;
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

    for (var qoldiq in qoshimcha) {
      var partiyalar = (await MahKirim.chiqar(qoldiq.mahsulot!))["partiyalar"];
      for (var partiya in partiyalar) {
        var kirim = MahKirim.obyektlar[partiya['trKirim']]!;
        var mahTarqat = MahTarqat();
        mahTarqat.trHujjat = tarqatish.tr;
        mahTarqat.tr = tr;
        mahTarqat.qulf = true;
        mahTarqat.trKont = (kont != null) ? kont.tr : 0;
        mahTarqat.trMah = qoldiq.tr;
        mahTarqat.trKirim = kirim.tr;
        mahTarqat.miqdori = qoshimchaCont[qoldiq.tr]!.text.parseNum();
        mahTarqat.tannarxi = kirim.tannarxiReal;
        mahTarqat.chiqnarxi = kirim.tannarxiReal;
        mahTarqat.chiqnarxiReal = mahTarqat.chiqnarxi;
        mahTarqat.sana = tarqatish.sana;
        mahTarqat.vaqt = tarqatish.vaqt;
        mahTarqat.vaqtS = tarqatish.vaqt;
        mahTarqat.nomi = mahTarqat.mahsulot.nomi;
        mahTarqat.kodi = tarqatish.kodi;
        mahTarqat.izoh = izoh;
        await mahTarqat.insert();
        await mahTarqat.mahsulot.mQoldiq!.ozaytir(mahTarqat.miqdori);
        tr++;
      }
    }
    //await Future.delayed(const Duration(seconds: 2));
    setState(() {
      taomnoma;
      kontLoading = false;
    });
  }

  remove(HujjatTarqat tarqatish) async {
    tarqatilganlar.remove(tarqatish);
    ikkinchiHujjat[tarqatish.trKont] = ikkinchiHujjat[tarqatish.trKont]! - 1;
    setState(() => tarqatilganlar);
    for (var mahTarqat in MahTarqat.obyektlar
        .where((element) => element.trHujjat == tarqatish.tr)) {
      await mahTarqat.kirim!.kopaytir(mahTarqat.miqdori);
      await mahTarqat.mahsulot.mQoldiq!.kopaytir(mahTarqat.miqdori);
      await mahTarqat.delete();
    }
    // await MahTarqat.service.delete(where: " trHujjat=${tarqatish.tr}");
    // MahTarqat.obyektlar.removeWhere((element) => element.trHujjat == tarqatish.tr);
    await tarqatish.delete();
  }

  kontTop(String tag) {
    tagInputCont.text = '';
    try {
      MapEntry<int, Kont> varvar = Kont.obyektlar.entries
          .firstWhere((element) => element.value.tag == tag);
      setState(() => hodim = varvar.value);
      kontAddFN.requestFocus();
    } catch (e) {
      setState(() => hodim = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Hodim topilmadi"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.redAccent,
      ));
      tagInputFN.requestFocus();
    }
  }

  Future<void> tarqatishHujjati(HujjatTarqat hujjatTarqat) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: _TarqatHujjatIchi(hujjatTarqat));
      },
    );
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
                child:
                    const Text('Bekor', style: TextStyle(color: Colors.grey)),
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
      items: MahQoldiq.obyektlar.values
          .where((element) => element.qoldi > 0)
          .toList(),
      onChange: (selected) {
        qoshimcha.add(selected);
        qoshimchaCont[selected.tr] = TextEditingController(text: "1");
        setState(() {
          qoshimcha;
        });
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      itemBuilder: (context, item, isSelected) {
        return ListTile(
          title: Text(item.mahsulot!.nomi),
          subtitle: Text(
              "${item.qoldi.toStringAsFixed(item.mahsulot!.kasr)} ${item.mOlchov.nomi}"),
        );
      },
    );
  }
}

class _TarqatHujjatIchi extends StatelessWidget {
  _TarqatHujjatIchi(this.hujjatTarqat, {Key? key}) : super(key: key);

  late HujjatTarqat hujjatTarqat;

  @override
  Widget build(BuildContext context) {
    List<Widget> mahlarWL = [];
    for (MahTarqat tarqat in MahTarqat.obyektlar
        .where((element) => element.trHujjat == hujjatTarqat.tr)) {
      mahlarWL.add(ListTile(
        title: Text(tarqat.nomi),
        subtitle: Text(
            "${tarqat.miqdori.toStringAsFixed(tarqat.mahsulot.kasr)} ${tarqat.mahsulot.mOlchov.nomi}"),
      ));
    }
    mahlarWL = [
      StreamBuilder<dynamic>(
          stream: db.watch("SELECT * FROM ${MahTarqat.service.table}",
              tables: [MahTarqat.service.tableName],
              fromMap: MahTarqat.fromJson),
          builder: ((context, snapshot) {
            print("connectionState: ${snapshot.connectionState}");
            print("snapshot.data: ${snapshot.data}");
            print("=================");
            if (snapshot.hasData && !snapshot.hasError) {
              //var tarqat = MahTarqat.fromJson((snapshot.data! as ResultSet).asMap());
              return Text("nechidur");
              /*return ListTile(
                title: Text(tarqat.nomi),
                subtitle: Text("${tarqat.miqdori.toStringAsFixed(tarqat.mahsulot.kasr)} ${tarqat.mahsulot.mOlchov.nomi}"),
              );*/
            } else {
              return const SizedBox();
            }
          })),
    ];
    return SizedBox(
        width: 500,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          child: Column(
            children: <Widget>[
                  Text(
                      "${hujjatTarqat.trKont == 0 ? "" : hujjatTarqat.kont!.nomi} (${hujjatTarqat.tr}-hujjat)"),
                ] +
                mahlarWL,
          ),
        ));
  }
}
