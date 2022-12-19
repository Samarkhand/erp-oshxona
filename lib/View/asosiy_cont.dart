// ignore_for_file: use_build_context_synchronously
import 'package:erp_oshxona/Library/sorovnoma.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
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
import 'package:erp_oshxona/Model/hisob.dart';
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
    showLoading(text: "MCode yuklanmoqda...");
    (await MCode.service!.select()).forEach((key, value) {
      var obj = MCode.fromJson(value);
      MCode.obyektlar[key] = obj;
      MCode.kodlar[obj.trMah] == null ? [obj] : MCode.kodlar[key]!.add(obj);
    });
    // load
    showLoading(text: "MArtikul yuklanmoqda...");
    (await MArtikul.service!.select()).forEach((key, value) {
      var obj = MArtikul.fromJson(value);
      MArtikul.obyektlar[key] == null ? [obj] : MArtikul.obyektlar[key]!.add(obj);
      MArtikul.mahlar[key] == null ? [obj] : MArtikul.mahlar[key]!.add(obj.mahsulot);
    });
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

  static final DateTime today = DateTime.now();
  static const int sutka = 1000 * 60 * 60 * 24;

  /// in Seconds
  int kundan = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

  /// in Seconds
  int kungacha = DateTime(today.year, today.month, today.day, 23, 59, 59, 999)
          .millisecondsSinceEpoch;

  songgiAmaliyotYukla() async {
    songgiAmaliyotlar = [];

    //var list = Amaliyot.obyektlar.values.where((element) => element.sana >= toMilliSecond(kundan)).toList();

    chiqimSum = 0;
    tushumSum = 0;
    (await Amaliyot.service!
            .select(where: " sana>=${toSecond(kundan)} AND sana<='${toSecond(kungacha)}'"))
        .forEach((key, value) {
      var obj = Amaliyot.fromJson(value);
      Amaliyot.obyektlar[key] = obj;
      songgiAmaliyotlar.add(obj);
      if (obj.turi == AmaliyotTur.chiqim.tr) {
        chiqimSum += obj.miqdor;
      } else if (obj.turi == AmaliyotTur.tushum.tr) {
        tushumSum += obj.miqdor;
      }
    });

    songgiAmaliyotlar.sort(((a, b) {
      return -a.vaqt.compareTo(b.vaqt);
    }));

    setState(() {
      songgiAmaliyotlar;
    });
  }

  songgiAmaliyotYangila() {
    songgiAmaliyotlar = [];
    chiqimSum = 0;
    tushumSum = 0;
    for (var obj in Amaliyot.obyektlar.values.where(
        (element) => element.sana >= kundan && element.sana <= kungacha)) {
      songgiAmaliyotlar.add(obj);
      if (obj.turi == AmaliyotTur.chiqim.tr) {
        chiqimSum += obj.miqdor;
      } else if (obj.turi == AmaliyotTur.tushum.tr) {
        tushumSum += obj.miqdor;
      }
    }
    songgiAmaliyotlar.sort(((a, b) {
      return -a.vaqt.compareTo(b.vaqt);
    }));

    setState(() {
      chiqimSum;
      tushumSum;
      songgiAmaliyotlar;
    });
  }

  songgiAOrderYukla() async {
    songgiAOrderlar = [];

    //var list = AMahsulot.obyektlar.values.where((element) => element.sana >= toMilliSecond(kundan)).toList();

    (await AOrder.service!
            .select(where: " sana>=${toSecond(kundan)} AND sana<='${toSecond(kungacha)}'"))
        .forEach((key, value) {
      AOrder.obyektlar[key] = AOrder.fromJson(value);
      songgiAOrderlar.add(AOrder.obyektlar[key]!);
    });

    songgiAOrderlar.sort(((a, b) {
      return -a.vaqt.compareTo(b.vaqt);
    }));

    setState(() {
      songgiAOrderlar;
    });
  }

  songgiAOrderYangila() {
    songgiAOrderlar = [];
    for (var obj in AOrder.obyektlar.values.where(
        (element) => element.sana >= kundan && element.sana <= kungacha)) {
      songgiAOrderlar.add(obj);
    }
    songgiAOrderlar.sort(((a, b) {
      return -a.vaqt.compareTo(b.vaqt);
    }));

    setState(() {
      songgiAOrderlar;
    });
  }

  songgiAMahsulotYukla() async {
    songgiAMahsulotlar = [];

    //var list = AMahsulot.obyektlar.values.where((element) => element.sana >= toMilliSecond(kundan)).toList();

    (await AMahsulot.service!
            .select(where: " sana>=${toSecond(kundan)} AND sana<='${toSecond(kungacha)}'"))
        .forEach((key, value) {
      AMahsulot.obyektlar[key] = AMahsulot.fromJson(value);
      songgiAMahsulotlar.add(AMahsulot.obyektlar[key]!);
    });

    songgiAMahsulotlar.sort(((a, b) {
      return -a.vaqt.compareTo(b.vaqt);
    }));

    setState(() {
      songgiAMahsulotlar;
    });
  }

  songgiAMahsulotYangila() {
    songgiAMahsulotlar = [];
    for (var obj in AMahsulot.obyektlar.values.where(
        (element) => element.sana >= kundan && element.sana <= kungacha)) {
      songgiAMahsulotlar.add(obj);
    }
    songgiAMahsulotlar.sort(((a, b) {
      return -a.vaqt.compareTo(b.vaqt);
    }));

    setState(() {
      songgiAMahsulotlar;
    });
  }

  deleteAMah(BuildContext context, AMahsulot element) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O`chirilsinmi?'),
        content: const Text(
            'O`chirmoqchi bo`lgan elementingizni qayta tiklab bo`lmaydi'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BEKOR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              showLoading();
              await element.delete();
              setState((() {
                songgiAMahsulotlar.remove(element);
                AMahsulot.obyektlar.remove(element.tr);
              }));
              hideLoading();
            },
            child: const Text('O`CHIRILSIN'),
          ),
        ],
      ),
    );
  }

  deleteAOrder(BuildContext context, AOrder element) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O`chirilsinmi?'),
        content: const Text(
            'O`chirmoqchi bo`lgan elementingizni qayta tiklab bo`lmaydi'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BEKOR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              showLoading();
              await element.delete();
              setState((() {
                songgiAOrderlar.remove(element);
                AOrder.obyektlar.remove(element.tr);
                AsosiyCont.tushumSum;
                AsosiyCont.chiqimSum;
              }));
              hideLoading();
            },
            child: const Text('O`CHIRILSIN'),
          ),
        ],
      ),
    );
  }

  deleteAmaliyot(BuildContext context, Amaliyot element) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O`chirilsinmi?'),
        content: const Text(
            'O`chirmoqchi bo`lgan elementingizni qayta tiklab bo`lmaydi'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BEKOR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              showLoading();
              await element.delete();
              setState((() {
                songgiAmaliyotlar.remove(element);
                Hisob.obyektlar[element.hisob];
                if (element.turi == AmaliyotTur.tushum.tr) {
                  AsosiyCont.tushumSum -= element.miqdor;
                } else if (element.turi == AmaliyotTur.chiqim.tr) {
                  AsosiyCont.chiqimSum -= element.miqdor;
                }
              }));
              hideLoading();
            },
            child: const Text('O`CHIRILSIN'),
          ),
        ],
      ),
    );
  }
}
