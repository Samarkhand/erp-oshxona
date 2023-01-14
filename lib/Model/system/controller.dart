import 'dart:io';

import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:erp_oshxona/Model/mah_buyurtma.dart';
import 'package:erp_oshxona/Model/mah_chiqim_ich.dart';
import 'package:erp_oshxona/Model/mah_tarqat.dart';
import 'package:erp_oshxona/Model/mahal.dart';
import 'package:erp_oshxona/Model/smena.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/m_artikul.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';
import 'package:erp_oshxona/Model/m_brend.dart';
import 'package:erp_oshxona/Model/m_code.dart';
import 'package:erp_oshxona/Model/m_olchov.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';

class Controller {
  late Function setState;
  late BuildContext context;

  bool isLoading = true;
  String loadingLabel = '';

  void showLoading({String text = ''}) {
    setState(() {
      isLoading = true;
      loadingLabel = text;
    });
  }

  void hideLoading() {
    setState(() {
      isLoading = false;
    });
    loadingLabel = '';
  }

  static late Directory directory;
  static bool started = false;
  static Future start() async {
    if(started) return;
    /* Mablag' 
    ABolim.service = ABolimService();
    Hisob.service = HisobService();
    Amaliyot.service = AmaliyotService();
    AMahsulot.service = AMahsulotService();
    AOrder.service = AOrderService();
    TransferTemp.service = TransferTempService();
    Transfer.service = TransferService();*/
    KBolim.service = KBolimService();
    Kont.service = KontService();
    /* Mahsulot */
    MOlchov.service = MOlchovService();
    MBolim.service = MBolimService();
    MBrend.service = MBrendService();
    Mahsulot.service = MahsulotService();
    MTarkib.service = MTarkibService();
    MCode.service = MCodeService();
    MArtikul.service = MArtikulService();
    HujjatPartiya.service = HujjatPartiyaService(prefix: "${today.year}_${today.month}_");
    Hujjat.service = HujjatService(prefix: "${today.year}_${today.month}_");
    MahQoldiq.service = MahQoldiqService(prefix: "${today.year}_${today.month}_");
    MahKirim.service = MahKirimService(prefix: "${today.year}_${today.month}_");
    MahChiqim.service = MahChiqimService(prefix: "${today.year}_${today.month}_");
    MahChiqimIch.service = MahChiqimIchService(prefix: "${today.year}_${today.month}_");
    MahBuyurtma.service = MahBuyurtmaService(prefix: "${today.year}_${today.month}_");
    MahTarqat.service = MahTarqatService(prefix: "${today.year}_${today.month}_");
    Mahal.service = MahalService();
    Smena.service = SmenaService();
    /* *** */
    started = true;
    String dbPath = join(directory.path,  "${Global.databases[Global.database]!.faylNomi}.sqlite");
    logConsole("Database path: $dbPath");
    await DatabaseHelper().initDB(dbPath);
  }
}
