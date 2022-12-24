import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart' as global;
import 'package:erp_oshxona/View/Hisobot/hisobot_view.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:intl/intl.dart';

class HisobotCont with Controller {
  late HisobotView widget;
  bool internetBor = false;
  static bool hisobotTayyor = false;

  /// seperator
  static DateTime sanaDaDT = DateTime(global.today.year, global.today.month);
  static DateTime sanaGaDT = DateTime(
      global.today.year, global.today.month, global.today.day, 23, 59, 59);
  static DateTime today =
      DateTime.fromMillisecondsSinceEpoch(global.today.millisecondsSinceEpoch);
  static var duration = 3600 * 24 * 7;

  static int davr = 1;

  /// seperator
  static num mabTushumSum = 0;
  static num mabChiqimSum = 0;
  static num mabQarzBSum = 0;
  static num mabQarzOSum = 0;
  static num mabTransMSum = 0;
  static num mabTransPSum = 0;
  static num mablagQoldiq = 0;

  /// seperator
  static num ordUngaSum = 0;
  static num ordMengaSum = 0;

  /// seperator
  static num mahKirimSum = 0;
  static num mahVozvratKSum = 0;
  static num mahSavdoSum = 0;
  static num mahVozvratCSum = 0;
  static num mahSpisanyaSum = 0;
  static num mahQoldiqSum = 0;
  static num mahFoydaSum = 0;

  /// seperator
  static Map<int, num> abolimMab = {};
  static Map<int, num> abolimOrd = {};
  static Map<int, num> abolimAMahKir = {};
  static Map<int, num> abolimAMahVozK = {};
  static Map<int, num> abolimAMahSav = {};
  static Map<int, num> abolimAMahVozC = {};
  static Map<int, num> abolimAMahSpi = {};

  /// Chart
  static Map<String, Map<String, dynamic>> chartDataMab = {};
  static Map<String, Map<String, dynamic>> chartDataOrd = {};
  static Map<String, Map<String, dynamic>> chartDataMah = {};

  static late DateTime sanaD;
  static late DateTime sanaG;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //await Future.delayed(Duration(seconds: 5));
    if (!hisobotTayyor || true) await hisobotYangila();
    hideLoading();
  }

  hisobotYangila() async {
    showLoading(text: "Yuklanmoqda...");
    sanaD = DateTime(today.year, today.month);
    sanaG = DateTime(today.year, today.month, today.day, 23, 59, 59);
    await hisobotChiqar();
    if (!hisobotTayyor) await Future.delayed(const Duration(milliseconds: 500));
    hisobotTayyor = true;
    hideLoading();
  }

  static hisobotChiqar() async {
    /// seperator
    mabTushumSum = 0;
    mabChiqimSum = 0;
    mabQarzBSum = 0;
    mabQarzOSum = 0;
    mabTransMSum = 0;
    mabTransPSum = 0;
    mablagQoldiq = 0;

    /// seperator
    ordUngaSum = 0;
    ordMengaSum = 0;

    /// seperator
    mahKirimSum = 0;
    mahVozvratKSum = 0;
    mahSavdoSum = 0;
    mahVozvratCSum = 0;
    mahSpisanyaSum = 0;
    mahQoldiqSum = 0;
    mahFoydaSum = 0;
    await bazadanMalYukla((toSecond(sanaD.millisecondsSinceEpoch)),
        toSecond(sanaG.millisecondsSinceEpoch));
  }

  static bazadanMalYukla(int kundan, int kungacha) async {
    // Hisoblar yukla
    Hisob.obyektlar.forEach((key, value) {
      mablagQoldiq += value.balans;
    });
    // Amaliyot load
    chartDataMab.clear();
    abolimMab = {};
    (await Amaliyot.service!
            .select(where: " sana>=$kundan AND sana<=$kungacha"))
        .forEach((key, value) {
      Amaliyot.obyektlar[key] = Amaliyot.fromJson(value);
      var obj = Amaliyot.obyektlar[key]!;
      late String chartDataKey;
      if(davr == 1){
        chartDataKey = DateFormat('dd.MM.yyyy').format(obj.sanaDT);
      }
      else if(davr == 2){
        chartDataKey = DateFormat('E.yyyy').format(obj.sanaDT);
      }
      else if(davr == 3){
        chartDataKey = DateFormat('MM.yyyy').format(obj.sanaDT);
      }
      else if(davr == 4){
        chartDataKey = DateFormat('yyyy').format(obj.sanaDT);
      }
      if (chartDataMab[chartDataKey] == null) {
        chartDataMab[chartDataKey] = {
          "x": chartDataKey,
          "${AmaliyotTur.tushum}": 0.0,
          "${AmaliyotTur.chiqim}": 0.0,
          "${AmaliyotTur.qarzB}": 0.0,
          "${AmaliyotTur.qarzO}": 0.0,
          "${AmaliyotTur.transM}": 0.0,
          "${AmaliyotTur.transP}": 0.0,
          "qoldiq": 0.0,
        };
      }
      chartDataMab[chartDataKey]!["${AmaliyotTur.obyektlar[obj.turi]}"] =
          obj.miqdor +
              chartDataMab[chartDataKey]!["${AmaliyotTur.obyektlar[obj.turi]}"];
      abolimMab[obj.bolim] = obj.miqdor + (abolimMab[obj.bolim] ?? 0);
      if (obj.turi == AmaliyotTur.tushum.tr) {
        mabTushumSum += obj.miqdor;
      } else if (obj.turi == AmaliyotTur.chiqim.tr) {
        mabChiqimSum += obj.miqdor;
      } else if (obj.turi == AmaliyotTur.qarzB.tr) {
        mabQarzBSum += obj.miqdor;
      } else if (obj.turi == AmaliyotTur.qarzO.tr) {
        mabQarzOSum += obj.miqdor;
      } else if (obj.turi == AmaliyotTur.transM.tr) {
        mabTransMSum += obj.miqdor;
      } else if (obj.turi == AmaliyotTur.transP.tr) {
        mabTransPSum += obj.miqdor;
      }
    });
    // AOrder load
    chartDataOrd.clear();
    abolimOrd = {};
    (await AOrder.service!.select(where: " sana>=$kundan AND sana<=$kungacha"))
        .forEach((key, value) {
      AOrder.obyektlar[key] = AOrder.fromJson(value);
      var obj = AOrder.obyektlar[key]!;
      late String chartDataKey;
      if(davr == 1){
        chartDataKey = DateFormat('dd.MM.yyyy').format(obj.sanaDT);
      }
      else if(davr == 2){
        chartDataKey = DateFormat('E.yyyy').format(obj.sanaDT);
      }
      else if(davr == 3){
        chartDataKey = DateFormat('MM.yyyy').format(obj.sanaDT);
      }
      else if(davr == 4){
        chartDataKey = DateFormat('yyyy').format(obj.sanaDT);
      }
      if (chartDataOrd[chartDataKey] == null) {
        chartDataOrd[chartDataKey] = {
          "x": chartDataKey,
          "${AOrderTur.menga.tr}": 0.0,
          "${AOrderTur.unga.tr}": 0.0,
        };
      }
      chartDataOrd[chartDataKey]!["${AOrderTur.obyektlar[obj.turi]}"] =
          obj.miqdor +
              chartDataOrd[chartDataKey]!["${AOrderTur.obyektlar[obj.turi]}"];
      abolimOrd[obj.bolim] = obj.miqdor + (abolimOrd[obj.bolim] ?? 0);
      if (obj.turi == AOrderTur.menga.tr) {
        ordMengaSum += obj.miqdor;
      } else if (obj.turi == AOrderTur.unga.tr) {
        ordUngaSum += obj.miqdor;
      }
    });
    // AMaxsulot load
    chartDataMah.clear();
    abolimAMahKir = {};
    abolimAMahVozK = {};
    abolimAMahSav = {};
    abolimAMahVozC = {};
    abolimAMahSpi = {};
    (await AMahsulot.service!
            .select(where: " sana >= '$kundan' AND sana<=$kungacha"))
        .forEach((key, value) {
      AMahsulot.obyektlar[key] = AMahsulot.fromJson(value);
      var obj = AMahsulot.obyektlar[key]!;
      late String chartDataKey;
      if(davr == 1){
        chartDataKey = DateFormat('dd.MM.yyyy').format(obj.sanaDT);
      }
      else if(davr == 2){
        chartDataKey = DateFormat('E.yyyy').format(obj.sanaDT);
      }
      else if(davr == 3){
        chartDataKey = DateFormat('MM.yyyy').format(obj.sanaDT);
      }
      else if(davr == 4){
        chartDataKey = DateFormat('yyyy').format(obj.sanaDT);
      }
      if (chartDataMah[chartDataKey] == null) {
        chartDataMah[chartDataKey] = {
          "x": chartDataKey,
          "${AMahsulotTur.kirim.tr}": 0.0,
          "${AMahsulotTur.vozvratKir.tr}": 0.0,
          "${AMahsulotTur.vozvratChiq.tr}": 0.0,
          "${AMahsulotTur.spisanya.tr}": 0.0,
          "${AMahsulotTur.savdo.tr}": 0.0,
          "foyda": 0.0,
          "qoldiq": 0.0,
        };
      }
      chartDataMah[chartDataKey]!["${AMahsulotTur.obyektlar[obj.turi]}"] = obj
              .miqdor +
          chartDataMah[chartDataKey]!["${AMahsulotTur.obyektlar[obj.turi]}"];
      if (obj.turi == AMahsulotTur.kirim.tr) {
        mahKirimSum += obj.miqdor;
        abolimAMahKir[obj.bolim] = obj.miqdor + (abolimAMahKir[obj.bolim] ?? 0);
      } else if (obj.turi == AMahsulotTur.vozvratKir.tr) {
        mahVozvratKSum += obj.miqdor;
        abolimAMahVozK[obj.bolim] =
            obj.miqdor + (abolimAMahVozK[obj.bolim] ?? 0);
      } else if (obj.turi == AMahsulotTur.vozvratChiq.tr) {
        mahVozvratCSum += obj.miqdor;
        abolimAMahVozC[obj.bolim] =
            obj.miqdor + (abolimAMahVozC[obj.bolim] ?? 0);
      } else if (obj.turi == AMahsulotTur.spisanya.tr) {
        mahSpisanyaSum += obj.miqdor;
        abolimAMahSpi[obj.bolim] = obj.miqdor + (abolimAMahSpi[obj.bolim] ?? 0);
      } else if (obj.turi == AMahsulotTur.savdo.tr) {
        mahSavdoSum += obj.miqdor;
        abolimAMahSav[obj.bolim] = obj.miqdor + (abolimAMahSav[obj.bolim] ?? 0);
      }
    });
  }

  Future<void> sanaTanlashD(BuildContext context, Function setState) async {
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

  Future<void> sanaTanlashG(BuildContext context, Function setState) async {
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
}
