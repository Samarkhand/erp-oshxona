import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';

class MahChiqimIch  {

  insert() {
    obyektlar.add(this);
    return service!.insert(toJson());
  }

  delete() {
    obyektlar.remove(this);
    return service!.deleteId(trHujjat, tr);
  }

  static Set<MahChiqimIch> obyektlar = {};
  static MahChiqimIchService? service;

  int trHujjat = 0;
  int tr = 0;
  int turi = 0;
  bool qulf = false;
  bool yoq = false;
  int trKont = 0;
  int trMah = 0;
  int trKirim = 0;
  int trKirimUch = 0;
  int sana = 0;
  int vaqtS = 0;
  int vaqt = 0;
  num miqdori = 0;
  num tannarxi = 0;
  num chiqnarxi = 0;
  num chiqnarxiReal = 0;
  String nomi = '';
  String kodi = "";
  String izoh = "";

  Mahsulot get mahsulot => Mahsulot.obyektlar[trMah]!;
  Kont? get kont => trKont == 0 ? null : Kont.obyektlar[trKont];
  MahKirim? get kirim => trKirim == 0 ? null : MahKirim.obyektlar[trKirim];
  MahKirim? get kirimUch => trKirimUch == 0 ? null : MahKirim.obyektlar[trKirimUch];
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);
  
  MahChiqimIch();

  MahChiqimIch.fromJson(Map<String, dynamic> json) {
    trHujjat = int.parse(json['trHujjat'].toString());
    tr = int.parse(json['tr'].toString());
    turi = int.parse(json['turi'].toString());
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    trKont = int.parse(json['trKont'].toString());
    trMah = int.parse(json['trMah'].toString());
    trKirim = int.parse(json['trKirim'].toString());
    trKirimUch = int.parse(json['trKirimUch'].toString());
    sana = int.parse(json['sana'].toString()) * 1000;
    vaqtS = int.parse(json['vaqtS'].toString()) * 1000;
    vaqt = int.parse(json['vaqt'].toString()) * 1000;
    miqdori = num.parse(json['miqdori'].toString());
    tannarxi = num.parse(json['tannarxi'].toString());
    chiqnarxi = num.parse(json['chiqnarxi'].toString());
    chiqnarxiReal = num.parse(json['chiqnarxiReal'].toString());
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
        'trKirim': trKirim,
        'trKirimUch': trKirimUch,
        'sana': toSecond(sana),
        'vaqtS': toSecond(vaqtS),
        'vaqt': toSecond(vaqt),
        'miqdori': miqdori,
        'tannarxi': tannarxi,
        'chiqnarxi': chiqnarxi,
        'chiqnarxiReal': chiqnarxiReal,
        'nomi': nomi,
        'kodi': kodi,
        'izoh': izoh,
      };

  @override
  operator == (other) => other is MahChiqimIch && other.trHujjat == trHujjat && other.tr == tr;

  @override
  int get hashCode => trHujjat.hashCode ^ tr.hashCode;
}

class MahChiqimIchService extends MahChiqimService {
  @override
  final String tableName = "mah_chiqim_ich";

  MahChiqimIchService({super.prefix = ''});

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
      "trKirim"	INTEGER NOT NULL DEFAULT 0,
      "trKirimUch"	INTEGER NOT NULL DEFAULT 0,
      "sana"	INTEGER NOT NULL DEFAULT 0,
      "vaqtS"	INTEGER NOT NULL DEFAULT 0,
      "vaqt"	INTEGER NOT NULL DEFAULT 0,
      "miqdori"	NUMERIC NOT NULL DEFAULT 0,
      "tannarxi"	NUMERIC NOT NULL DEFAULT 0,
      "chiqnarxi"	NUMERIC NOT NULL DEFAULT 0,
      "chiqnarxiReal"	NUMERIC NOT NULL DEFAULT 0,
      "nomi"	TEXT NOT NULL DEFAULT '',
      "kodi"	TEXT NOT NULL DEFAULT '',
      "izoh"	TEXT NOT NULL DEFAULT '',
      PRIMARY KEY("trHujjat","tr")
    );
  """;

}
