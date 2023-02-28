import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mah_buyurtma.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_chiqim_zar.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_tarqat.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatRoyxatView.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class HujjatRoyxatCont with Controller {
  late HujjatRoyxatView widget;
  List objectList = [];
  Map<int, Map<String, num>> objectListSummaAndMiqdori = {};
  late DateTime sanaD;
  late DateTime sanaG;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    sanaD = DateTime(today.year, today.month);
    sanaG = DateTime(today.year, today.month, today.day, 23, 59, 59);
    showLoading(text: "Yuklanmoqda...");
    await getSummaAndNechtaMahsulot();
    await loadItems();
    await loadFromGlobal();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> delete(Hujjat element) async {
    await Hujjat.service!.deleteId(element.turi, element.tr);
    Hujjat.obyektlar.remove(element);
    setState(() {
      objectList.remove(element);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("O'chirib yuborildi"),
      duration: Duration(seconds: 5),
    ));
  }

  Future<void> sanaTanlashD(BuildContext context, StateSetter setState) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sanaD,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != sanaD) {
      setState(() => sanaD = picked);
    }
  }

  Future<void> sanaTanlashG(BuildContext context, StateSetter setState) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sanaG,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != sanaG) {
      setState(() => sanaG = picked);
    }
  }

  Future<void> loadItems() async {
    var add = widget.turi != null ? " turi=${widget.turi!.tr} AND " : "";
    var values = await Hujjat.service!.select(
        where:
            "$add sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC, tr DESC");
    for (var value in values) {
      objectListSummaAndMiqdori[value['tr']] = {
        'summa': objectListSummaAndMiqdori[value['tr']] != null
            ? objectListSummaAndMiqdori[value['tr']]!['summa']!
            : 0,
        'miqdori': objectListSummaAndMiqdori[value['tr']] != null
            ? objectListSummaAndMiqdori[value['tr']]!['miqdori']!
            : 0,
      };
      
      Hujjat.obyektlar.add(Hujjat.fromJson(value));
    }
  }

  loadFromGlobal() {
    objectList =
        (widget.turi != null ? Hujjat.olList(widget.turi!) : Hujjat.obyektlar)
            .toList();
    objectList.sort((a, b) {
      int cmp = -a.sana.compareTo(b.sana);
      if (cmp != 0) return cmp;
      return -a.tr.compareTo(b.tr);
    });
    setState(() => objectList);
  }

  Future<Map<int, Map<String, num>>> getSummaAndNechtaMahsulot() async {
    if (HujjatTur.zarar.tr == widget.turi!.tr) {
      await MahChiqimZar.service!.select().then((values) {
        for (var value in values) {
          objectListSummaAndMiqdori[value['trHujjat']] = {
            'summa': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['summa']! +
                    (value['tannarxi'] * value['miqdori']))
                : value['tannarxi'] * value['miqdori'],
            'miqdori': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['miqdori']! +
                    value['miqdori'])
                : value['miqdori'],
          };
        }
      });
    }
    else if (HujjatTur.kirim.tr == widget.turi!.tr || HujjatTur.kirimFil.tr == widget.turi!.tr || HujjatTur.kirimIch.tr == widget.turi!.tr) {
      await MahKirim.service!.select(where: "turi='${widget.turi!.tr}'").then((values) {
        for (var value in values.values) {
          objectListSummaAndMiqdori[value['trHujjat']] = {
            'summa': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['summa']! +
                    (value['tannarxi'] * value['miqdori']))
                : value['tannarxi'] * value['miqdori'],
            'miqdori': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['miqdori']! +
                    value['miqdori'])
                : value['miqdori'],
          };
        }
      });
    }
    else if (HujjatTur.chiqim.tr == widget.turi!.tr) {
      await MahChiqim.service!.select().then((values) {
        for (var value in values) {
          objectListSummaAndMiqdori[value['trHujjat']] = {
            'summa': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['summa']! +
                    (value['sotnarxiReal'] * value['miqdori']))
                : value['sotnarxiReal'] * value['miqdori'],
            'miqdori': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['miqdori']! +
                    value['miqdori'])
                : value['miqdori'],
          };
        }
      });
    }
    else if (HujjatTur.chiqimIch.tr == widget.turi!.tr) {
      await MahChiqim.service!.select(where: "turi='${widget.turi!.tr}'").then((values) {
        for (var value in values) {
          objectListSummaAndMiqdori[value['trHujjat']] = {
            'summa': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['summa']! +
                    (value['chiqnarxiReal'] * value['miqdori']))
                : value['chiqnarxiReal'] * value['miqdori'],
            'miqdori': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['miqdori']! +
                    value['miqdori'])
                : value['miqdori'],
          };
        }
      });
    }
    else if (HujjatTur.buyurtma.tr == widget.turi!.tr) {
      await MahBuyurtma.service!.select(where: "turi='${widget.turi!.tr}'").then((values) {
        for (var value in values) {
          objectListSummaAndMiqdori[value['trHujjat']] = {
            'summa': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['summa']! +
                    (value['narxi'] * value['miqdori']))
                : value['narxi'] * value['miqdori'],
            'miqdori': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['miqdori']! +
                    value['miqdori'])
                : value['miqdori'],
          };
        }
      });
    }
    else if (HujjatTur.tarqatish.tr == widget.turi!.tr) {
      await MahTarqat.service.select(where: "turi='${widget.turi!.tr}'").then((values) {
        for (var value in values) {
          objectListSummaAndMiqdori[value['trHujjat']] = {
            'summa': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['summa']! +
                    (value['chiqnarxiReal'] * value['miqdori']))
                : value['chiqnarxiReal'] * value['miqdori'],
            'miqdori': objectListSummaAndMiqdori[value['trHujjat']] != null
                ? (objectListSummaAndMiqdori[value['trHujjat']]!['miqdori']! +
                    value['miqdori'])
                : value['miqdori'],
          };
        }
      });
    }
      //logConsole(objectListSummaAndMiqdori);
    
    return objectListSummaAndMiqdori;
  }
}
