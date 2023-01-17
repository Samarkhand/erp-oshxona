import 'package:erp_oshxona/Model/system/turi.dart';
import 'package:flutter/material.dart';

import 'hujjat.dart';

class HujjatTur extends Tur {
  static final HujjatTur kirim = HujjatTur(1, "Kirim(Xarid)");
  static final HujjatTur kirimFil = HujjatTur(2, "Filialdan kirim"); 
  static final HujjatTur qaytibOlish = HujjatTur(3, "Qaytib olish");
  static final HujjatTur qaytibBerish = HujjatTur(4, "Qaytib berish");
  static final HujjatTur zarar = HujjatTur(5, "Qoldiqdan o'chirish");
  static final HujjatTur kirimIch = HujjatTur(6, "Taom tayyorlash");
  static final HujjatTur chiqimIch = HujjatTur(7, "Tayyorlash uchun chiqim");
  static final HujjatTur chiqimFil = HujjatTur(8, "Filialga chiqim");
  static final HujjatTur chiqim = HujjatTur(9, "Chiqim(Savdo)");
  static final HujjatTur buyurtmaKeldi = HujjatTur(10, "Bizga buyurtma");
  static final HujjatTur buyurtma = HujjatTur(11, "Buyurtma(Xarid)");
  static final HujjatTur tarqatish = HujjatTur(12, "Taom tarqatish");

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
    tarqatish.tr: tarqatish,
  };

  HujjatTur(super.tr, super.nomi);

  get olHujjatlar => Hujjat.obyektlar.where((element) => element.turi == tr).toList();
}

class HujjatSts extends Tur {
  HujjatSts(super.tr, super.nomi, {super.ranggi = const Color(0x00000000), super.icon = const IconData(0)});

  static final Map<int, Map<int, HujjatSts>> obyektlar = {
    HujjatTur.kirim.tr: oddiyHujjatSts,
    HujjatTur.kirimFil.tr: oddiyHujjatSts,
    HujjatTur.qaytibOlish.tr: oddiyHujjatSts,
    HujjatTur.qaytibBerish.tr: oddiyHujjatSts,
    HujjatTur.zarar.tr: oddiyHujjatSts,
    HujjatTur.chiqimIch.tr: oddiyHujjatSts,
    HujjatTur.chiqim.tr: oddiyHujjatSts,
    HujjatTur.tarqatish.tr: oddiyHujjatSts,
    HujjatTur.kirimIch.tr: {
      ochilgan.tr: ochilgan,
      homAshyoPrt.tr: homAshyoPrt,
      tayyorlashPrt.tr: tayyorlashPrt,
      tugallanganPrt.tr: tugallanganPrt,
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

  static final HujjatSts ochilgan = HujjatSts(0, "Ochilgan", ranggi: Colors.orange.shade800);
  static final HujjatSts tugallangan = HujjatSts(1, "Tugallangan", ranggi: Colors.blue.shade800);

  /// Buyurtma uchun
  static final HujjatSts jonatilganBrtm = HujjatSts(1, "Jo'natilgan", ranggi: Colors.green.shade800);
  /// Buyurtma uchun
  static final HujjatSts tasdiqKutBrtm = HujjatSts(2, "Tasdiqni kutmoqda", ranggi: Colors.red.shade800);
  /// Buyurtma uchun
  static final HujjatSts tugallanganBrtm = HujjatSts(3, "Tugallangan", ranggi: Colors.blue.shade800);

  /// ishlab chiqarish partiyasi uchun
  static final HujjatSts homAshyoPrt = HujjatSts(1, "Masalliqlar tanlanmoqda", ranggi:  Colors.orange.shade800);
  /// ishlab chiqarish partiyasi uchun
  static final HujjatSts tayyorlashPrt = HujjatSts(2, "Tayyorlanmoqda", ranggi: Colors.green.shade800);
  /// Buyurtma uchun
  static final HujjatSts tugallanganPrt = HujjatSts(3, "Tugallangan", ranggi: Colors.blue.shade800);
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
