import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
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
import 'package:select_dialog/select_dialog.dart';

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
  List<MahKirim> kirimList = [];

  Map<int, TextEditingController> chiqimCont = {};

  Map<Mahsulot, num> mahChiqim = {};
  Map<Mahsulot, num> mahQoldiq = {};

  Map<Mahsulot, num> chiqMahMap = {};

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;

    //hujjat = widget.partiya.hujjatChiq!;
    partiya = widget.partiya;
    barchaTarkib = widget.barchaTarkib;

    showLoading(text: "Yuklanmoqda...");
    await Hujjat.service!
        .select(where: "turi='7' AND tr='${partiya.trChiqim}'")
        .then((values) {
      for (var value in values) {
        hujjat = Hujjat.fromJson(value);
        Hujjat.obyektlar.add(hujjat);
      }
    });
    if (barchaTarkib.isEmpty) {
      await loadItems();
      await chiqimFromGlobal();
    } else {
      await chiqimFromAtribute();
    }
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
    await MahChiqimIch.service!
        .select(where: "trHujjat=${hujjat.tr} ORDER BY tr DESC")
        .then((values) {
      for (var value in values) {
        var chiqim = MahChiqimIch.fromJson(value);
        chiqMahMap[chiqim.mahsulot] =
            (chiqMahMap[chiqim.mahsulot] ?? 0) + chiqim.miqdori;
        MahChiqimIch.obyektlar.add(chiqim);
        chiqimCont[chiqim.tr] =
            TextEditingController(text: chiqim.miqdori.toStringAsFixed(3));
      }
    });
  }

  loadFromGlobal() {
    mahsulotList = Mahsulot.obyektlar.values
        .where((element) => element.turi == MTuri.homAshyo.tr)
        .toList();
    mahsulotList.sort((a, b) => -b.nomi.compareTo(a.nomi));

    kirimList = MahKirim.obyektlar.values
        .where((element) =>
            element.trHujjat == partiya.trHujjat &&
            element.turi == MahKirimTur.kirimIch.tr)
        .toList();
    kirimList.sort(
      (a, b) => -a.tr.compareTo(b.tr),
    );
  }

  chiqimFromAtribute() async {
    chiqimList = [];
    for (var map in barchaTarkib) {
      await add(Mahsulot.obyektlar[map['mahTarkib']]!, map['miqdoriChiq'],
          map['trKirim']);
    }
    chiqimList.sort(
      (a, b) => -a.tr.compareTo(b.tr),
    );
  }

  chiqimFromGlobal() {
    chiqimList = MahChiqimIch.obyektlar
        .where((element) => element.trHujjat == hujjat.tr)
        .toList();
    chiqimList.sort(
      (a, b) => -a.tr.compareTo(b.tr),
    );
  }

  qulflash() async {
    showLoading(text: "Qulflashga tayyorlanmoqda...");
    for (var mah in chiqMahMap.entries) {
      // Qoldiq bormi, chiqarsa bo'ladimi, tekshiriladi
      if (await MahQoldiq.sotiladimi(
              mah.key, chiqMahMap[mah.key]!) !=
          null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Qulflab bo'lmaydi"),
          duration: Duration(seconds: 5),
        ));
        hideLoading();
        return;
      }
    }

    showLoading(text: "Tannarx qo'yilmoqda...");
    int vaqts = DateTime.now().millisecondsSinceEpoch;
    List<MahChiqimIch> chiqimQosh = [];
    // Har bir maxsulotni tekshiradi
    for (var chiqim in chiqimList) {
      // Tannarx oladi, kirim jadvalidan qoldiqni ozaytiradi
      var partiyalari = await MahKirim.chiqar(chiqim.mahsulot, chiqim.miqdori);

      // Tannarx oladi, kirim jadvalidan qoldiqni ozaytiradi
      await chiqim.mahsulot.mQoldiq!.ozaytir(chiqim.miqdori);

      /*
        'trKirim'
        'miqdori'
        'tannarxi'
      */
      var i = 0;
      for (var partiya in partiyalari['partiyalar']) {
        i++;
        if(i == 1){
          chiqim.qulf = true;
          chiqim.trKirim = partiya['trKirim'];
          chiqim.miqdori = partiya['miqdori'];
          chiqim.tannarxi = partiya['tannarxi'];
          chiqim.trKont = hujjat.trKont;
          chiqim.sana = hujjat.sana;
          chiqim.vaqt = vaqts;
          chiqim.vaqtS = vaqts;
          chiqim.nomi = chiqim.mahsulot.nomi;
          await MahChiqimIch.service!.update({
            'qulf': 1,
            'trKirim': chiqim.trKirim,
            'miqdori': chiqim.miqdori,
            'tannarxi': chiqim.tannarxi,
            'sana': toSecond(hujjat.sana),
            'vaqt': toSecond(vaqts),
            'vaqtS': toSecond(vaqts),
            'nomi': chiqim.mahsulot.nomi,
          },
          where: " trHujjat='${chiqim.trHujjat}' AND tr='${chiqim.tr}'");
        }
        else{
          var chiqim2 = MahChiqimIch.fromJson(chiqim.toJson());
          chiqim2.tr = await MahChiqimIch.service!.newId(chiqim2.trHujjat);
          chiqim2.trKirim = partiya['trKirim'];
          chiqim2.miqdori = partiya['miqdori'];
          chiqim2.tannarxi = partiya['tannarxi'];
          MahChiqimIch.obyektlar.add(chiqim2);
          chiqimQosh.add(chiqim2);
          await MahChiqimIch.service!.insert(chiqim2.toJson());
        }
      }
    }
    chiqimList.addAll(chiqimQosh);
    hideLoading();
    //return;

    showLoading(text: "Tarkib tuzilmoqda...");

    //int turi = MahKirimTur.kirimIch.tr;
    for (var kirim in kirimList) {
      kirim.qulf = true;
      kirim.qoldi = kirim.miqdori;
      kirim.tannarxiReal = kirim.tannarxi;
      kirim.trQoldiq = await MahQoldiq.kopaytirMah(kirim.mahsulot,
          miqdor: kirim.miqdori, tannarxi: kirim.tannarxiReal);

      await MahKirim.service!.update({
        'qulf': kirim.qulf ? 1 : 0,
        'qoldi': kirim.qoldi,
        'tannarxi': kirim.tannarxiReal,
        'tannarxiReal': kirim.tannarxiReal,
        'trQoldiq': kirim.trQoldiq,
        'vaqtS': vaqts,
        'nomi': kirim.mahsulot.nomi,
      }, where: "tr='${kirim.tr}'");
    }

    vaqts = DateTime.now().millisecondsSinceEpoch;
    
    // Chiqim hujjati qulflanyapti
    hujjat.qulf = true;
    hujjat.sts = HujjatSts.tugallangan.tr;
    await Hujjat.service!.update({
      'qulf': hujjat.qulf ? 1 : 0,
      'sts': hujjat.sts,
      'vaqtS': vaqts,
    }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");

    // Kirim hujjati qulflanyapti
    partiya.hujjat.qulf = true;
    partiya.hujjat.sts = HujjatSts.tugallanganPrt.tr;
    await Hujjat.service!.update({
      'qulf': partiya.hujjat.qulf ? 1 : 0,
      'sts': partiya.hujjat.sts,
      'vaqtS': vaqts,
    }, where: "turi='${partiya.hujjat.turi}' AND tr='${partiya.hujjat.tr}'");

    // Tarqatish hujjati ochilyapti
    var hujjatTarqat = Hujjat(HujjatTur.tarqatish.tr);
    hujjatTarqat.tr = await Hujjat.service!.newId(hujjatTarqat.turi);
    hujjatTarqat.qulf = false;
    hujjatTarqat.trHujjat = partiya.trHujjat;
    hujjatTarqat.sana = partiya.sana;
    hujjatTarqat.vaqt = vaqts;
    hujjatTarqat.vaqtS = vaqts;
    await hujjatTarqat.insert();

    setState((){
      chiqimList;

    });

    hideLoading();
  }

  tarkibQaytarish() async {
    showLoading(text: "Tarkib tuzilmoqda...");
    hideLoading();
  }

  addToList(Mahsulot chiqim) async {
    String? value = await inputDialog(context, "");
    if (value != null) {
      num miqdori = num.tryParse(value) ?? 0;
      await add(chiqim, miqdori);
    }
  }

  add(Mahsulot mah, [num miqdori = 1, int trKirimUCh = 0]) async {
    var chiqim = MahChiqimIch();
    chiqim.trHujjat = partiya.trChiqim;
    chiqim.tr = await MahChiqimIch.service!.newId(chiqim.trHujjat);
    chiqim.trMah = mah.tr;
    chiqim.miqdori = miqdori;
    chiqim.trKirimUch = trKirimUCh;
    chiqim.sana = partiya.sana;
    chiqim.vaqt = DateTime.now().millisecondsSinceEpoch;
    chiqim.vaqtS = chiqim.vaqt;
    chiqimList.add(chiqim);
    chiqMahMap[chiqim.mahsulot] =
        (chiqMahMap[chiqim.mahsulot] ?? 0) + chiqim.miqdori;
    chiqimCont[chiqim.tr] =
        TextEditingController(text: chiqim.miqdori.toStringAsFixed(3));
    setState(() => chiqimList);
    await chiqim.insert();
  }

  miqdorHisobla(MahChiqimIch chiqim) {
    chiqMahMap[chiqim.mahsulot] = 0;
    for (var chiq
        in chiqimList.where((element) => element.mahsulot == chiqim.mahsulot)) {
      chiqMahMap[chiq.mahsulot] = chiqMahMap[chiq.mahsulot]! + chiq.miqdori;
    }
    setState(() => chiqMahMap[chiqim.mahsulot]);
  }

  miqdorOchirsinmi(MahChiqimIch chiqim) {
    var tarkibla =
        chiqimList.where((element) => element.mahsulot == chiqim.mahsulot);
    if (tarkibla.isEmpty) {
      chiqMahMap.remove(chiqim.mahsulot);
    }
  }

  remove(MahChiqimIch chiqim) async {
    try {
      chiqim.delete();
      chiqimList.remove(chiqim);
      miqdorHisobla(chiqim);
      miqdorOchirsinmi(chiqim);
    } on ExceptionIW catch (_) {
      alertDialog(context, _.alert);
    } finally {
      setState(() => chiqimList);
    }
  }

  kirimUchTanla(context, MahChiqimIch chiqim) {
    SelectDialog.showModal<MahKirim>(
      context,
      label: "Masalliq qaysi taom uchun?",
      selectedValue: chiqim.kirimUch,
      items: kirimList,
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      onChange: (selected) {
        setState(() {
          chiqim.trKirimUch = selected.tr;
        });
      },
      itemBuilder: ((context, item, isSelected) {
        return ListTile(
          title: Text(item.mahsulot.nomi),
          subtitle: Text("${item.miqdori} ${item.mahsulot.mOlchov.nomi}"),
        );
      }),
      okButtonBuilder: (context, onPressed) {
        return TextButton(
          onPressed: (){
            setState(() {
              chiqim.trKirimUch = 0;
            });
            onPressed();
          },
          child: const Text('Bekor qilish'),
        );
      },
    );
  }

  mahIzlash(String value) {
    loadFromGlobal();
    setState(() {
      mahsulotList = mahsulotList
          .where((element) =>
              element.nomi.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }
}
