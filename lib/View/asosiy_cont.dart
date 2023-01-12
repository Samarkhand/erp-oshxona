import 'package:erp_oshxona/Library/api_get.dart';
import 'package:erp_oshxona/Library/sorovnoma.dart';
import 'package:erp_oshxona/Model/mahal.dart';
import 'package:erp_oshxona/Model/smena.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/m_artikul.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';
import 'package:erp_oshxona/Model/m_brend.dart';
import 'package:erp_oshxona/Model/m_code.dart';
import 'package:erp_oshxona/Model/m_olchov.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/View/asosiy_view.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class AsosiyCont with Controller {
  late AsosiyView widget;
  bool internetBor = false;

  // view
  num balans = 0;

  static num chiqimSum = 0;
  static num tushumSum = 0;

  List<Amaliyot> songgiAmaliyotlar = [];
  List<AOrder> songgiAOrderlar = [];
  List<AMahsulot> songgiAMahsulotlar = [];
  TextEditingController feedbackController = TextEditingController();

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    songgiAmaliyotlar = [];
    // Bazaga ulan
    showLoading(text: "Bazaga ulanmoqda...");
    //await Future.delayed(const Duration(seconds: 2));
    await Controller.start();
    /*
    String sql = '';
    sql += "";
    await db.execute(sql);
    */
    // News load
    showLoading(text: "Yuklanmoqda...");
    await bazadanMalYukla();
    // FIXME: pastdagi komentni ochib qo'yilsin
    /*
    ikkilamchiMalYukla().then((value) {
      if (Sozlash.tutored &&
          Sozlash.kirVaqt + 24 * 60 * 60 * 1000 <
              DateTime.now().millisecondsSinceEpoch) {
        // 86400000 = 1 sutka
        if ((Sozlash.qoniqdizmiJavobVaqt == 0 && Sozlash.qoniqdizmiKorVaqt == 0) ||
            (Sozlash.qoniqdizmiJavobVaqt == 0 && Sozlash.qoniqdizmiKorVaqt > DateTime.now().millisecondsSinceEpoch + 86400000) ||
            (Sozlash.qoniqdizmiKorVaqt > DateTime.now().millisecondsSinceEpoch + 86400000 && Sozlash.qoniqdizmiJavobVaqt > DateTime.now().millisecondsSinceEpoch + 31 * 86400000)) {
          SorovnomaCont.dialogQoniqdizmi(context);
        } else if ((Sozlash.qoniqdizmiJavobVaqt >=
            DateTime.now().millisecondsSinceEpoch + 24 * 60 * 60 * 1000 && Sozlash.songgiSorovVaqt == 0) || Sozlash.songgiSorovVaqt > DateTime.now().millisecondsSinceEpoch + 120 * 60 * 1000) {
          for(var obj in SorovnomaCont.obyektlar.values){
            if(obj.javobVaqt == 0 &&  obj.key != "qoniqdizmi_yoq" && obj.key != "qoniqdizmi_qisman"){
              SorovnomaCont.dialogFeedback(context, obj);
              break;
            }
          }
        }
      }
      if (Sozlash.sinVaqt <=
              DateTime.now().millisecondsSinceEpoch - 1000 * 3600 * 2) InwareServer.licTekshir(context, asosiymi: true);
    });*/
    kBolimBalansYangila();
    hideLoading();
  }

  bazadanMalYukla() async {
    await kontYukla();
    await mahsulotYukla();
  }

  Future ikkilamchiMalYukla() async {
    await SorovnomaCont.init();
  }
  
  mahsulotYukla() async {
    // load
    showLoading(text: "MOlchov yuklanmoqda...");
    MOlchov.obyektlar = (await MOlchov.service!.select())
        .map((key, value) => MapEntry(key, MOlchov.fromJson(value)));
    // load
    showLoading(text: "MBolim yuklanmoqda...");
    MBolim.obyektlar = (await MBolim.service!.select())
        .map((key, value) => MapEntry(key, MBolim.fromJson(value)));
    // load
    showLoading(text: "MBrend yuklanmoqda...");
    MBrend.obyektlar = (await MBrend.service!.select())
        .map((key, value) => MapEntry(key, MBrend.fromJson(value)));
    // load
    showLoading(text: "Mahsulot yuklanmoqda...");
    Mahsulot.obyektlar = (await Mahsulot.service!.select())
        .map((key, value) => MapEntry(key, Mahsulot.fromJson(value)));
    // load
    showLoading(text: "Mahal yuklanmoqda...");
    Mahal.obyektlar = (await Mahal.service!.select())
        .map((key, value) => MapEntry(key, Mahal.fromJson(value)));
    // load
    showLoading(text: "Smena yuklanmoqda...");
    Smena.obyektlar = (await Smena.service!.select())
        .map((key, value) => MapEntry(key, Smena.fromJson(value)));
    // load
    showLoading(text: "MCode yuklanmoqda...");
    for (var value in (await MCode.service!.select())) {
      var obj = MCode.fromJson(value);
      MCode.obyektlar[obj.code] = obj;
      MCode.kodlar[obj.trMah] == null ? [obj] : MCode.kodlar[obj.code]!.add(obj);
    }
    // load
    showLoading(text: "MArtikul yuklanmoqda...");
    for (var value in (await MArtikul.service!.select())) {
      var obj = MArtikul.fromJson(value);
      MArtikul.obyektlar[obj.trMah] == null ? [obj] : MArtikul.obyektlar[obj.trMah]!.add(obj);
      MArtikul.mahlar[obj.trMah] == null ? [obj] : MArtikul.mahlar[obj.trMah]!.add(obj.mahsulot);
    }
    // load
    showLoading(text: "MahQoldiq yuklanmoqda...");
    MahQoldiq.obyektlar = (await MahQoldiq.service!.select())
        .map((key, value) => MapEntry(key, MahQoldiq.fromJson(value)));
  }

  kontYukla() async {
    // KBolimlar load
    showLoading(text: "Kontakt Bolimlar yuklanmoqda...");
    KBolim.obyektlar =
        (await KBolim.service!.select(where: "tr!='0' ORDER BY tartib ASC"))
            .map((key, value) => MapEntry(key, KBolim.fromJson(value)));
    // Kontlar load
    showLoading(text: "Kontaktlar yuklanmoqda...");
    Kont.obyektlar = (await Kont.service!.select())
        .map((key, value) => MapEntry(key, Kont.fromJson(value)));
  }

  static kBolimBalansYangila() {
    KBolim.obyektlar.forEach((key, value) {
      value.sumQarz = 0;
      value.sumHaq = 0;
    });
    Kont.obyektlar.forEach((key, value) {
      if (value.balans < 0) {
        KBolim.obyektlar[value.bolim]!.sumQarz += value.balans;
      } else {
        KBolim.obyektlar[value.bolim]!.sumHaq += value.balans;
      }
    });
  }

  malumotAlmash() async {
    showLoading(text: "");
    await SyncServer.getData(context);
    hideLoading();
  }
}
