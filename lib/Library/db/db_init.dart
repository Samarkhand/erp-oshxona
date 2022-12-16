import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/static/mablag.dart';

class DatabaseInitializer {
  static List hisob = [];
  static List abolim = [];
  static List kbolim = [];

  static Future<void> doQuery() async {
    for (var obj in hisob) {
      await Hisob.service!.insert(obj.toJson());
    }
    for (var obj in kbolim) {
      await KBolim.service!.insert(obj.toJson());
    }
    for (var obj in abolim) {
      await ABolim.service!.insert(obj.toJson());
    }
  }

  static prepareDataUZ() async {
    int trHisob = 0;
    int tartib = 0;
    hisob = <Hisob>[];
    trHisob++;
    tartib++;
    hisob.add(Hisob.bosh()
      ..tr = trHisob
      ..abh = true
      ..active = true
      ..tartib = tartib
      ..saqlashTuri = MablagSaqlashTuri.naqd.tr
      ..turi = 0
      ..nomi = "Hamyon"
      ..icon = Icons.account_balance
      ..color = const Color.fromARGB(255, 91, 122, 103));
    await Sozlash.box.put("tanlanganHisob", trHisob);
    trHisob++;
    tartib++;
    hisob.add(Hisob.bosh()
      ..tr = trHisob++
      ..abh = true
      ..active = true
      ..tartib = tartib
      ..saqlashTuri = MablagSaqlashTuri.naqd.tr
      ..turi = 0
      ..nomi = "Uy"
      ..icon = Icons.attach_money
      ..color = const Color.fromARGB(255, 136, 128, 86));
    trHisob++;
    tartib++;
    hisob.add(Hisob.bosh()
      ..tr = trHisob++
      ..abh = true
      ..active = true
      ..tartib = tartib
      ..saqlashTuri = MablagSaqlashTuri.plastik.tr
      ..turi = 0
      ..nomi = "Bank karta"
      ..icon = Icons.credit_card
      ..color = const Color.fromARGB(255, 230, 138, 0));
    trHisob++;
    tartib++;
    hisob.add(Hisob.bosh()
      ..tr = trHisob++
      ..abh = false
      ..active = true
      ..tartib = tartib
      ..saqlashTuri = MablagSaqlashTuri.bank.tr
      ..turi = 0
      ..nomi = "Bank hisob raqam"
      ..icon = Icons.account_balance
      ..color = const Color.fromARGB(255, 129, 74, 115));
//=======================================
    int trABolim = 0;
    tartib = 0;
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "O'tkazma +"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 17, 17, 17));
    await Sozlash.box.put("abolimTransP", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "O'tkazma -"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 46, 45, 45));
    await Sozlash.box.put("abolimTransM", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "Qarz berish"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 177, 65, 21));
    await Sozlash.box.put("abolimQarzB", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "Qarz olish"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 224, 228, 21));
    await Sozlash.box.put("abolimQarzO", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "Mahsulot uchun"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 224, 228, 21));
    await Sozlash.box.put("abolimMahUchun", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "Komissiya to'lovlari"
      ..icon = Icons.money
      ..color = const Color.fromARGB(255, 177, 21, 156));
    await Sozlash.box.put("abolimTrKomissiya", trABolim);
// =======================================================================
    tartib = 0;
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tushum.tr
      ..tartib = tartib
      ..nomi = "Maosh"
      ..icon = Icons.attach_money
      ..color = const Color.fromARGB(255, 0, 201, 77));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tushum.tr
      ..tartib = tartib
      ..nomi = "Foyda"
      ..icon = Icons.attach_money
      ..color = const Color.fromARGB(255, 21, 177, 125));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tushum.tr
      ..tartib = tartib
      ..nomi = "Xizmat uchun"
      ..icon = Icons.engineering
      ..color = const Color.fromARGB(255, 21, 177, 125));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tushum.tr
      ..tartib = tartib
      ..nomi = "Qarz oldim"
      ..icon = Icons.remove
      ..color = const Color.fromARGB(255, 177, 21, 42));
/* 
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tushum.tr
      ..tartib = tartib
      ..nomi = "Mahsulot uchun"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 21, 177, 29));
    await Sozlash.box.put("abolimTrMahSvdTush", trABolim);*/
// =======================================================================

    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Oziq-ovqat"
      ..icon = Icons.restaurant
      ..color = const Color.fromARGB(255, 158, 59, 59));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Transport"
      ..icon = Icons.emoji_transportation
      ..color = const Color.fromARGB(255, 136, 145, 17));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Kommunal"
      ..icon = Icons.house
      ..color = const Color.fromARGB(255, 158, 59, 59));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Aloqa"
      ..icon = Icons.wifi
      ..color = const Color.fromARGB(255, 59, 94, 158));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Sog'lik"
      ..icon = Icons.health_and_safety
      ..color = const Color.fromARGB(255, 72, 243, 255));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Kafe / Choyxona"
      ..icon = Icons.restaurant_menu
      ..color = const Color.fromARGB(255, 158, 59, 59));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Kiyim kechak"
      ..icon = Icons.wc
      ..color = const Color.fromARGB(255, 158, 59, 59));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Soliq"
      ..icon = Icons.payment
      ..color = const Color.fromARGB(255, 158, 59, 59));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Xizmat uchun"
      ..icon = Icons.engineering
      ..color = const Color.fromARGB(255, 21, 177, 125));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Qarz berdim"
      ..icon = Icons.remove
      ..color = const Color.fromARGB(255, 21, 177, 125));
    /*trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.chiqim.tr
      ..tartib = tartib
      ..nomi = "Mahsulot uchun"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 21, 177, 29));
    await Sozlash.box.put("abolimTrMahKirChiq", trABolim);*/
// =======================================================================
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.mahsulot.tr
      ..tartib = tartib
      ..nomi = "Mahsulot"
      ..icon = Icons.folder
      ..color = const Color.fromARGB(30, 150, 240, 255));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.mahsulot.tr
      ..tartib = tartib
      ..nomi = "Hom ashyo"
      ..icon = Icons.folder
      ..color = const Color.fromARGB(30, 150, 240, 255));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.mahsulot.tr
      ..tartib = tartib
      ..nomi = "Yarim tayyor mahsulot"
      ..icon = Icons.folder
      ..color = const Color.fromARGB(30, 150, 240, 255));
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.mahsulot.tr
      ..tartib = tartib
      ..nomi = "Masalliq"
      ..icon = Icons.folder
      ..color = const Color.fromARGB(30, 150, 240, 255));
// =======================================================================
    int trKBolim = 0;
    tartib = 0;
    trKBolim++;
    tartib++;
    kbolim.add(KBolim()
      ..tr = trKBolim
      ..tartib = tartib
      ..nomi = "Do'st"
      ..icon = Icons.people
      ..color = const Color.fromARGB(255, 30, 150, 240));
    trKBolim++;
    tartib++;
    kbolim.add(KBolim()
      ..tr = ++trKBolim
      ..tartib = tartib
      ..nomi = "Hamkasb"
      ..icon = Icons.people
      ..color = const Color.fromARGB(255, 30, 150, 240));
    trKBolim++;
    tartib++;
    kbolim.add(KBolim()
      ..tr = ++trKBolim
      ..tartib = tartib
      ..nomi = "Mijoz"
      ..icon = Icons.people
      ..color = const Color.fromARGB(255, 30, 150, 240));
    trKBolim++;
    tartib++;
    kbolim.add(KBolim()
      ..tr = ++trKBolim
      ..tartib = tartib
      ..nomi = "Qarindosh"
      ..icon = Icons.people
      ..color = const Color.fromARGB(255, 30, 150, 240));
    trKBolim++;
    tartib++;
    kbolim.add(KBolim()
      ..tr = ++trKBolim
      ..tartib = tartib
      ..nomi = "Hamkor"
      ..icon = Icons.people
      ..color = const Color.fromARGB(255, 30, 150, 240));
    trKBolim++;
    tartib++;
    kbolim.add(KBolim()
      ..tr = ++trKBolim
      ..tartib = tartib
      ..nomi = "Tanish-bilish"
      ..icon = Icons.people
      ..color = const Color.fromARGB(255, 30, 150, 240));
  }
}
