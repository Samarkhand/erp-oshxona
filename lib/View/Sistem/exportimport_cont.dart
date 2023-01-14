import 'dart:convert';
import 'dart:io';
import 'package:charset/charset.dart';

import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/transfer.dart';
import 'package:erp_oshxona/Model/TransferTemp.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/static/mablag.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/Sistem/exportimport_view.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ExportimportCont with Controller {
  late ExportimportView widget;
  String text = '';

  static String filePrefix = "inware_erp_v1_";

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    await loadView();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> loadView() async {}

  static writeTofile(BuildContext context,
      {required String filename, required List<int> data}) async {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Faylni saqlash uchun ma'lumotlar yetarli emas!",
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.yellowAccent,
      ));
      return;
    }

    String sourceFilePath = "";
    sourceFilePath = (await getApplicationDocumentsDirectory()).path;
    sourceFilePath = "$sourceFilePath/$filename";
    final File file = File(sourceFilePath);
    await file.writeAsBytes(data);

    final String? savedFilePath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(sourceFilePath: sourceFilePath));

    logConsole(savedFilePath);
    if (savedFilePath == null) {
      final dir = Directory(sourceFilePath);
      dir.deleteSync(recursive: true);
      return;
    }
    final dir = Directory(sourceFilePath);
    dir.deleteSync(recursive: true);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "$filename fayli saqlandi",
        style: const TextStyle(color: Colors.black87),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.greenAccent,
    ));
  }

  static readFromFile(BuildContext context) async {
    String sourceFilePath = "";
    final readFilePath = await FlutterFileDialog.pickFile(
        params: const OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
    ));
    if (readFilePath == null) {
      throw Exception("Fayl tanlanmagan");
    }
    final String extension = p.extension(readFilePath);
    logConsole("readFilePath: $readFilePath");
    sourceFilePath = readFilePath;

    final File file = File(sourceFilePath);
    List<int> valueBytes = await file.readAsBytes();

    if (extension == ".json") {
      String value = utf8.decode(valueBytes);
      // ignore: use_build_context_synchronously
      await bazaTozala(context);
      await bazagaSol(value);
    }
    /*else if(extension == ".csv"){
              Utf16Decoder decoder = utf16.decoder;
              String value = decoder.decodeUtf16Le(valueBytes);
              await _cont.bazagaSolCSV(value);
            }*/
    else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Hato: fromat noto'g'ri",
            style: TextStyle(color: Colors.black87),
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
  }

  static bazaTozala(BuildContext context) async {
    await ABolim.service!.delete();
    await AMahsulot.service!.delete();
    await AOrder.service!.delete();
    await Amaliyot.service!.delete();
    await Hisob.service!.delete();
    await KBolim.service!.delete();
    await Kont.service!.delete();
    await Transfer.service!.delete();
    await TransferTemp.service!.delete();
    await Sozlash.box.put("abolimTrKomissiya", 0);
  }

  static bazagaSol(String source) async {
    Map data = jsonDecode(source);
    if (data['hisob'] != null) {
      for (Map json in data['hisob']) {
        await Hisob.service!.insert(Hisob.fromJson(json).toJson());
      }
    }
    if (data['kBolim'] != null) {
      for (Map json in data['kBolim']) {
        await KBolim.service!.insert(KBolim.fromJson(json).toJson());
      }
    }
    if (data['kont'] != null) {
      for (Map json in data['kont']) {
        await Kont.service!.insert(Kont.fromJson(json).toJson());
      }
    }
    if (data['aBolim'] != null) {
      for (Map json in data['aBolim']) {
        await ABolim.service!.insert(ABolim.fromJson(json).toJson());
      }
    }
    if (data['aMahsulot'] != null) {
      for (Map json in data['aMahsulot']) {
        await AMahsulot.service!.insert(AMahsulot.fromJson(json).toJson());
      }
    }
    if (data['aOrder'] != null) {
      for (Map json in data['aOrder']) {
        await AOrder.service!.insert(AOrder.fromJson(json).toJson());
      }
    }
    if (data['amaliyot'] != null) {
      for (Map json in data['amaliyot']) {
        await Amaliyot.service!.insert(Amaliyot.fromJson(json).toJson());
      }
    }
    if (data['transfer'] != null) {
      for (Map json in data['transfer']) {
        await Transfer.service!.insert(Transfer.fromJson(json).toJson());
      }
    }
    if (data['transfertemp'] != null) {
      for (Map json in data['transfertemp']) {
        await TransferTemp.service!
            .insert(TransferTemp.fromJson(json).toJson());
      }
    }
  }

  static Future<String> olBazadanJSON() async {
    String hisobJson = "";
    String kontJson = "";
    String kBolimJson = "";
    String aBolimJson = "";
    String aMahsulotJson = "";
    String aOrderJson = "";
    String amaliyotJson = "";
    String transferJson = "";
    String transfertempJson = "";

    List<dynamic> aBolimList = [];
    List<dynamic> aMahsulotList = [];
    List<dynamic> aOrderList = [];
    List<dynamic> amaliyotList = [];
    List<dynamic> hisobList = [];
    List<dynamic> kBolimList = [];
    List<dynamic> kontList = [];
    List<dynamic> transferList = [];
    List<dynamic> transfertempList = [];

    (await ABolim.service!.select()).forEach((key, value) {
      if (key == 0) return;
      aBolimList.add(ABolim.fromJson(value));
    });
    aBolimJson = json.encode(aBolimList);

    (await AMahsulot.service!.select()).forEach((key, value) {
      if (key == 0) return;
      aMahsulotList.add(AMahsulot.fromJson(value));
    });
    aMahsulotJson = json.encode(aMahsulotList);

    (await AOrder.service!.select()).forEach((key, value) {
      if (key == 0) return;
      aOrderList.add(AOrder.fromJson(value));
    });
    aOrderJson = json.encode(aOrderList);

    (await Amaliyot.service!.select()).forEach((key, value) {
      if (key == 0) return;
      amaliyotList.add(Amaliyot.fromJson(value));
    });
    amaliyotJson = json.encode(amaliyotList);

    (await Hisob.service!.select()).forEach((key, value) {
      if (key == 0) return;
      hisobList.add(Hisob.fromJson(value));
    });
    hisobJson = json.encode(hisobList);

    (await KBolim.service!.select()).forEach((key, value) {
      if (key == 0) return;
      kBolimList.add(KBolim.fromJson(value));
    });
    kBolimJson = json.encode(kBolimList);

    (await Kont.service!.select()).forEach((key, value) {
      if (key == 0) return;
      kontList.add(Kont.fromJson(value));
    });
    kontJson = json.encode(kontList);

    (await Transfer.service!.select()).forEach((key, value) {
      if (key == 0) return;
      transferList.add(Transfer.fromJson(value));
    });
    transferJson = json.encode(transferList);

    for (var value in await TransferTemp.service!.select()) {
      transfertempList.add(TransferTemp.fromJson(value));
    }
    transfertempJson = json.encode(transfertempList);

    String buildNumber = "1";
    if (Platform.isAndroid || Platform.isMacOS) {
      var packageInfo = await PackageInfo.fromPlatform();
      buildNumber = packageInfo.buildNumber;
    }

    int sienceEpoch = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    return """
{
    "app_version": "$buildNumber",

    "db_version": "${DatabaseHelper.version}",

    "sana": "$sienceEpoch",

    "hisob": $hisobJson,
    
    "kBolim": $kBolimJson,
    
    "kont": $kontJson,
    
    "aBolim": $aBolimJson,

    "aMahsulot": $aMahsulotJson,

    "aOrder": $aOrderJson,

    "amaliyot": $amaliyotJson,
    
    "transfer": $transferJson,
    
    "transfertemp": $transfertempJson
}
""";
  }

  static Future<List<int>> olAmaliyotCSVOl(
      {final String cellEnd = "\t", final String rowEnd = "\n"}) async {
    Map<String, String> colKeys = {
      "id": "#",
      "date": "Sana",
      "type": "Toifa",
      "amount": "Miqdor",
      "category": "Bo'lim",
      "account": "Hisob",
      "paymant_type": "To'lov turi",
      "contact": "Kontakt",
      "comment": "Izoh",
      "time": "Vaqt",
    };

    Utf16Encoder encoder = utf16.encoder as Utf16Encoder;

    List<Map<String, String>> rowsCsv = [];
    List<int> retCsv = [];

    // Birinchi qator sarlavhalarini stringga joyla
    colKeys.forEach((String key, String value) {
      retCsv += encoder.encodeUtf16Le(value, true) +
          encoder.encodeUtf16Le(cellEnd, true);
    });
    retCsv += encoder.encodeUtf16Le(rowEnd, true);

    // Bazadan ma'lumotlarni olib, Mapga joyla
    Map<int, Amaliyot> qatorlar = {};
    qatorlar = (await Amaliyot.service!.select())
        .map((key, value) => MapEntry(key, Amaliyot.fromJson(value)));
    qatorlar.forEach((key, Amaliyot value) {
      rowsCsv.add(
        {
          "id": "${value.tr}",
          "date": dateFormat.format(value.sanaDT),
          "type": AmaliyotTur.obyektlar[value.turi]!.nomi,
          "amount": "${value.miqdor}",
          "category": AmaliyotTur.obyektlar[value.turi]!.tr == 5 || AmaliyotTur.obyektlar[value.turi]!.tr == 6 ? '' : ABolim.obyektlar[value.bolim]!.nomi,
          "account": Hisob.obyektlar[value.hisob]!.nomi,
          "paymant_type": MablagSaqlashTuri
              .obyektlar[Hisob.obyektlar[value.hisob]!.saqlashTuri]!.nomi,
          "contact": value.kont != 0 ? Kont.obyektlar[value.kont]!.nomi : "Kontakt tanlanmagan",
          "comment": value.izoh,
          "time":
              "${dateFormat.format(value.vaqtDT)} ${hourMinuteFormat.format(value.vaqtDT)}",
        },
      );
    });

    // Mapga toplangan ma'lumotni stringga o'tkaz
    for (Map<String, String> row in rowsCsv) {
      colKeys.forEach((String key, String value) {
        retCsv += encoder.encodeUtf16Le(row[key]!, true) +
            encoder.encodeUtf16Le(cellEnd, true);
      });
      retCsv += encoder.encodeUtf16Le(rowEnd, true);
    }

    // Stringni qaytar
    return retCsv;
  }

  static Future<List<int>> olXizmatCSVOl(
      {final String cellEnd = "\t", final String rowEnd = "\n"}) async {
    Map<String, String> colKeys = {
      "id": "#",
      "date": "Sana",
      "type": "Toifa",
      "amount": "Miqdor",
      "category": "Bo'lim",
      "contact": "Kontakt",
      "comment": "Izoh",
      "time": "Vaqt",
    };

    Utf16Encoder encoder = utf16.encoder as Utf16Encoder;

    List<Map<String, String>> rowsCsv = [];
    List<int> retCsv = [];

    // Birinchi qator sarlavhalarini stringga joyla
    colKeys.forEach((String key, String value) {
      retCsv += encoder.encodeUtf16Le(value, true) +
          encoder.encodeUtf16Le(cellEnd, true);
    });
    retCsv += encoder.encodeUtf16Le(rowEnd, true);

    // Bazadan ma'lumotlarni olib, Mapga joyla
    Map<int, AOrder> qatorlar = {};
    qatorlar = (await AOrder.service!.select())
        .map((key, value) => MapEntry(key, AOrder.fromJson(value)));
    qatorlar.forEach((key, AOrder value) {
      rowsCsv.add(
        {
          "id": "${value.tr}",
          "date": dateFormat.format(value.sanaDT),
          "type": AOrderTur.obyektlar[value.turi]!.nomi,
          "amount": "${value.miqdor}",
          "category": ABolim.obyektlar[value.bolim]!.nomi,
          "contact": value.kont != 0 ? Kont.obyektlar[value.kont]!.nomi : "Kontakt tanlanmagan",
          "comment": value.izoh,
          "time":
              "${dateFormat.format(value.vaqtDT)} ${hourMinuteFormat.format(value.vaqtDT)}",
        },
      );
    });

    // Mapga toplangan ma'lumotni stringga o'tkaz
    for (Map<String, String> row in rowsCsv) {
      colKeys.forEach((String key, String value) {
        retCsv += encoder.encodeUtf16Le(row[key]!, true) +
            encoder.encodeUtf16Le(cellEnd, true);
      });
      retCsv += encoder.encodeUtf16Le(rowEnd, true);
    }

    // Stringni qaytar
    return retCsv;
  }

  static Future<List<int>> olMahsulotCSVOl(
      {final String cellEnd = "\t", final String rowEnd = "\n"}) async {
    Map<String, String> colKeys = {
      "id": "#",
      "date": "Sana",
      "type": "Toifa",
      "amount": "Miqdor",
      "category": "Bo'lim",
      "contact": "Kontakt",
      "comment": "Izoh",
      "time": "Vaqt",
    };

    Utf16Encoder encoder = utf16.encoder as Utf16Encoder;

    List<Map<String, String>> rowsCsv = [];
    List<int> retCsv = [];

    // Birinchi qator sarlavhalarini stringga joyla
    colKeys.forEach((String key, String value) {
      retCsv += encoder.encodeUtf16Le(value, true) +
          encoder.encodeUtf16Le(cellEnd, true);
    });
    retCsv += encoder.encodeUtf16Le(rowEnd, true);

    // Bazadan ma'lumotlarni olib, Mapga joyla
    Map<int, AMahsulot> qatorlar = {};
    qatorlar = (await AMahsulot.service!.select())
        .map((key, value) => MapEntry(key, AMahsulot.fromJson(value)));
    qatorlar.forEach((key, AMahsulot value) {
      rowsCsv.add(
        {
          "id": "${value.tr}",
          "date": dateFormat.format(value.sanaDT),
          "type": AMahsulotTur.obyektlar[value.turi]!.nomi,
          "amount": "${value.miqdor}",
          "category": ABolim.obyektlar[value.bolim]!.nomi,
          "contact": value.kont != 0 ? Kont.obyektlar[value.kont]!.nomi : "Kontakt tanlanmagan",
          "comment": value.izoh,
          "time":
              "${dateFormat.format(value.vaqtDT)} ${hourMinuteFormat.format(value.vaqtDT)}",
        },
      );
    });

    // Mapga toplangan ma'lumotni stringga o'tkaz
    for (Map<String, String> row in rowsCsv) {
      colKeys.forEach((String key, String value) {
        retCsv += encoder.encodeUtf16Le(row[key]!, true) +
            encoder.encodeUtf16Le(cellEnd, true);
      });
      retCsv += encoder.encodeUtf16Le(rowEnd, true);
    }

    // Stringni qaytar
    return retCsv;
  }

  static Future<List<int>> olKontaktCSVOl(
      {final String cellEnd = "\t", final String rowEnd = "\n"}) async {
    Map<String, String> colKeys = {
      "id": "#",
      "date": "Nomi / Ismi",
      "type": "Bo'lim",
      "amount": "Qarzi",
      "category": "Haqqi",
      "account": "Izoh",
      "paymant_type": "",
      "contact": "",
      "comment": "",
      "time": "",
    };

    Utf16Encoder encoder = utf16.encoder as Utf16Encoder;

    List<Map<String, String>> rowsCsv = [];
    List<int> retCsv = [];

    // Birinchi qator sarlavhalarini stringga joyla
    colKeys.forEach((String key, String value) {
      retCsv += encoder.encodeUtf16Le(value, true) +
          encoder.encodeUtf16Le(cellEnd, true);
    });
    retCsv += encoder.encodeUtf16Le(rowEnd, true);

    // Bazadan ma'lumotlarni olib, Mapga joyla
    Map<int, Kont> qatorlar = {};
    qatorlar = (await Kont.service!.select())
        .map((key, value) => MapEntry(key, Kont.fromJson(value)));
    qatorlar.forEach((key, Kont value) {
      rowsCsv.add(
        {
          "id": "${value.tr}",
          "date": value.nomi,
          "type": KBolim.obyektlar[value.bolim]!.nomi,
          "amount": value.balans < 0 ? "${value.balans}" : "0",
          "category": value.balans > 0 ? "${value.balans}" : "0",
          "account": value.izoh,
          "paymant_type": '',
          "contact": "",
          "comment": "",
          "time": "",
        },
      );
    });

    // Mapga toplangan ma'lumotni stringga o'tkaz
    for (Map<String, String> row in rowsCsv) {
      colKeys.forEach((String key, String value) {
        retCsv += encoder.encodeUtf16Le(row[key]!, true) +
            encoder.encodeUtf16Le(cellEnd, true);
      });
      retCsv += encoder.encodeUtf16Le(rowEnd, true);
    }

    // Stringni qaytar
    return retCsv;
  }
}
