import 'package:erp_oshxona/Model/system/turi.dart';
import 'package:flutter/material.dart';

import 'hujjat.dart';

class HujjatTur extends Tur {
  static HujjatTur kirim = HujjatTur(1, "Kirim");
  static HujjatTur kirimFil = HujjatTur(2, "Filialdan Kirim"); 
  static HujjatTur qaytibOlish = HujjatTur(3, "Qaytib olish");
  static HujjatTur qaytibBerish = HujjatTur(4, "Qaytib berish");
  static HujjatTur zarar = HujjatTur(5, "Qoldiqdan o'chirish");
  static HujjatTur kirimIch = HujjatTur(6, "Ishlab chiqarish");
  static HujjatTur chiqimIch = HujjatTur(7, "Ishlab chiqarish uchun harajat");
  static HujjatTur chiqimFil = HujjatTur(8, "Filialdan Kirim");
  static HujjatTur chiqim = HujjatTur(9, "Chiqim");
  static HujjatTur buyurtmaKeldi = HujjatTur(10, "Bizga buyurtma");
  static HujjatTur buyurtma = HujjatTur(11, "Buyurtma");
  static HujjatTur tarqatish = HujjatTur(12, "Chiqim");

  static final Map<int, HujjatTur> obyektlar = {
    kirim.tr: kirim,
    kirimFil.tr: kirimFil,
    qaytibOlish.tr: qaytibOlish,
    qaytibBerish.tr: qaytibBerish,
    zarar.tr: zarar,
    kirimIch.tr: kirimIch,
    chiqimIch.tr: chiqimIch,
    chiqimFil.tr: chiqimFil,
    chiqim.tr: chiqim,
    buyurtma.tr: buyurtma,
  };

  HujjatTur(super.tr, super.nomi);

  get olHujjatlar => Hujjat.obyektlar.where((element) => element.turi == tr).toList();
}

class HujjatSts extends Tur {
  HujjatSts(super.tr, super.nomi, {super.ranggi = const Color(0x00000000), super.icon = const IconData(0)});

  static final Map<int, Map<int, HujjatSts>> obyektlar = {
    HujjatTur.kirim.tr: oddiyHujjatSts,
    HujjatTur.qaytibOlish.tr: oddiyHujjatSts,
    HujjatTur.qaytibBerish.tr: oddiyHujjatSts,
    HujjatTur.zarar.tr: oddiyHujjatSts,
    HujjatTur.chiqim.tr: oddiyHujjatSts,
    HujjatTur.kirimIch.tr: {
      HujjatSts.homAshyoPrt.tr: homAshyoPrt,
      HujjatSts.tayyorlashPrt.tr: tayyorlashPrt,
      HujjatSts.tugallanganPrt.tr: tugallanganPrt,
    },
    HujjatTur.buyurtma.tr: {
      ochilgan.tr: ochilgan,
      jonatilganBrtm.tr: jonatilganBrtm,
      tugallanganBrtm.tr: tugallanganBrtm,
    },
  };
  
  static final Map<int, HujjatSts> oddiyHujjatSts = {
    ochilgan.tr: ochilgan,
    tugallangan.tr: tugallangan,
  };

  static HujjatSts ochilgan = HujjatSts(0, "Ochilgan", ranggi: Colors.orange.shade800);
  static HujjatSts tugallangan = HujjatSts(1, "Tugallangan", ranggi: Colors.blue.shade800);

  /// Buyurtma uchun
  static HujjatSts jonatilganBrtm = HujjatSts(1, "Jo'natilgan", ranggi: Colors.green.shade800);
  /// Buyurtma uchun
  static HujjatSts tugallanganBrtm = HujjatSts(2, "Tugallangan", ranggi: Colors.blue.shade800);

  /// ishlab chiqarish partiyasi uchun
  static HujjatSts homAshyoPrt = HujjatSts(1, "Masalliqlar tanlanmoqda", ranggi:  Colors.orange.shade800);
  /// ishlab chiqarish partiyasi uchun
  static HujjatSts tayyorlashPrt = HujjatSts(2, "Tayyorlanmoqda", ranggi: Colors.green.shade800);
  /// Buyurtma uchun
  static HujjatSts tugallanganPrt = HujjatSts(3, "Tugallangan", ranggi: Colors.blue.shade800);
}
/*
    const STS_YANGI = 0;
    const STS_OCHILDI = 1; // Ochiladi
    const STS_MENU = 2; // Taomlar tanlanadi, planlashtiriladi //kirim table ichiga kiritiladi. Kirim hujjati ochiladi. tr_fil oshxonaga
    const STS_BUYURTMA_JON = 3; // Omborga buyurtma jonatiladi // tr_fil ombordan boshqa omborhonaga buyurtma jo'natiladi 
    const STS_BUYURTMA_KIR = 4; // Kelganini qabul qilinadi yo qaytaradi // ombordan kirim tr_fil ombordan
    const STS_TAYYORLANYAPTI = 5; // Tayyorlash tugmasini bosadi, chunki tayyor // ombordan masalliqlar chiqadi, oshxonaga taomlar kiradi
    const STS_TAYYOR = 6; // Tarqatiladi // tarqatishlar kiritiladi. tr_fil oshxonadan taom chiqim bo'ladi, tarqatish tablesiga yozilib boradi
    const STS_QULF = 7; // Statistika ko'radi. Qancha odam yedi, qancha qoldi. Va qulflaydi
    
 */