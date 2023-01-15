import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/alert.dart';

class MahBuyurtma {
  static Set<MahBuyurtma> obyektlar = {};
  static MahBuyurtmaService? service;

  int trHujjat = 0;
  int tr = 0;
  int turi = 0;
  bool qulf = false;
  bool yoq = false;
  int trKont = 0;
  int trMah = 0;
  int trKirim = 0;
  int sana = 0;
  int vaqtS = 0;
  int vaqt = 0;
  num miqdori = 0;
  num narxi = 0;
  int trChiqHujjat = 0;
  int trKirHujjat = 0;
  String nomi = '';
  String kodi = "";
  String izoh = "";

  Mahsulot get mahsulot => Mahsulot.obyektlar[trMah]!;
  MahKirim? get kirim => trKirim == 0 ? null : MahKirim.obyektlar[trKirim];
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);
  
  MahBuyurtma();

  MahBuyurtma.fromJson(Map<String, dynamic> json) {
    trHujjat = int.parse(json['trHujjat'].toString());
    tr = int.parse(json['tr'].toString());
    turi = int.parse(json['turi'].toString());
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    trKont = int.parse(json['trKont'].toString());
    trMah = int.parse(json['trMah'].toString());
    trMah = int.parse(json['trMah'].toString());
    sana = int.parse(json['sana'].toString()) * 1000;
    vaqtS = int.parse(json['vaqtS'].toString()) * 1000;
    vaqt = int.parse(json['vaqt'].toString()) * 1000;
    miqdori = num.parse(json['miqdori'].toString());
    narxi = num.parse(json['narxi'].toString());
    trChiqHujjat = int.parse(json['trChiqHujjat'].toString());
    trKirHujjat = int.parse(json['trKirHujjat'].toString());
    nomi = json['nomi'];
    kodi = json['kodi'];
    izoh = json['izoh'];
  }

  Map<String, dynamic> toJson() => {
        'trHujjat': trHujjat,
        'tr': tr,
        'turi': turi,
        'yoq': yoq ? 1 : 0,
        'qulf': qulf ? 1 : 0,
        'trKont': trKont,
        'trMah': trMah,
        'trMah': trMah,
        'sana': toSecond(sana),
        'vaqtS': toSecond(vaqtS),
        'vaqt': toSecond(vaqt),
        'miqdori': miqdori,
        'narxi': narxi,
        'trChiqHujjat': trChiqHujjat,
        'trKirHujjat': trKirHujjat,
        'nomi': nomi,
        'kodi': kodi,
        'izoh': izoh,
      };

  @override
  operator == (other) => other is MahBuyurtma && other.trHujjat == trHujjat && other.tr == tr;

  @override
  int get hashCode => trHujjat.hashCode ^ tr.hashCode;
  
  insert() async {
    obyektlar.add(this);
    await service!.insert(toJson());
  }

  delete() async {
    if(qulf){
      throw ExceptionIW(
        Alert(
          AlertType.error, 
          "O'chirish mumkun emas",
          desc: "Ushbu ma'lumot kirim uchun asos sifatida saqlanadi",
        ),
      );
    }
    else {
      await service!.deleteId(trHujjat, tr);
    }
    obyektlar.remove(this);
  }

}

class MahBuyurtmaService extends MahChiqimService{
  @override
  final String tableName = "mah_buyurtma";

  MahBuyurtmaService({super.prefix = ''});

  @override
  String get table => "'$prefix$tableName'";

  @override
  String get createTable => """
    CREATE TABLE $table (
      "trHujjat"	INTEGER NOT NULL DEFAULT 0,
      "tr"	INTEGER NOT NULL DEFAULT 0,
      "turi"	INTEGER NOT NULL DEFAULT 0,
      "qulf" INTEGER NOT NULL DEFAULT 0,
      "yoq"	INTEGER NOT NULL DEFAULT 0,
      "trKont"	INTEGER NOT NULL DEFAULT 0,
      "trMah"	INTEGER NOT NULL DEFAULT 0,
      "trMah"	INTEGER NOT NULL DEFAULT 0,
      "sana"	INTEGER NOT NULL DEFAULT 0,
      "vaqtS"	INTEGER NOT NULL DEFAULT 0,
      "vaqt"	INTEGER NOT NULL DEFAULT 0,
      "miqdori"	NUMERIC NOT NULL DEFAULT 0,
      "narxi"	NUMERIC NOT NULL DEFAULT 0,
      "trChiqHujjat"	INTEGER NOT NULL DEFAULT 0,
      "trKirHujjat"	INTEGER NOT NULL DEFAULT 0,
      "nomi"	TEXT NOT NULL DEFAULT '',
      "kodi"	TEXT NOT NULL DEFAULT '',
      "izoh"	TEXT NOT NULL DEFAULT '',
      PRIMARY KEY("trHujjat","tr")
    );
  """;
}
