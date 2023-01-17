import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';

class MahTarqat  {

  static Set<MahTarqat> obyektlar = {};
  static MahTarqatService? service;

  int trHujjat = 0;
  int tr = 0;
  bool qulf = false;
  bool yoq = false;
  int trKont = 0;
  int trMah = 0;
  int trKirim = 0;
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
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);
  
  MahTarqat();

  MahTarqat.fromJson(Map<String, dynamic> json) {
    trHujjat = int.parse(json['trHujjat'].toString());
    tr = int.parse(json['tr'].toString());
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    trKont = int.parse(json['trKont'].toString());
    trMah = int.parse(json['trMah'].toString());
    trKirim = int.parse(json['trKirim'].toString());
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
        'yoq': yoq ? 1 : 0,
        'qulf': qulf ? 1 : 0,
        'trKont': trKont,
        'trMah': trMah,
        'trKirim': trKirim,
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
  operator == (other) => other is MahTarqat && other.trHujjat == trHujjat && other.tr == tr;

  @override
  int get hashCode => trHujjat.hashCode ^ tr.hashCode;
  
  insert() {
    obyektlar.add(this);
    return service!.insert(toJson());
  }

  delete() {
    obyektlar.remove(this);
    return service!.deleteId(trHujjat, tr);
  }

}

class MahTarqatService extends MahChiqimService {
  @override
  final String tableName = "mah_tarqat";

  MahTarqatService({super.prefix = ''});

  @override
  String get table => "'$prefix$tableName'";

  @override
  String get createTable => """
    CREATE TABLE $table (
      "trHujjat"	INTEGER NOT NULL DEFAULT 0,
      "tr"	INTEGER NOT NULL DEFAULT 0,
      "qulf" INTEGER NOT NULL DEFAULT 0,
      "yoq"	INTEGER NOT NULL DEFAULT 0,
      "trKont"	INTEGER NOT NULL DEFAULT 0,
      "trMah"	INTEGER NOT NULL DEFAULT 0,
      "trKirim"	INTEGER NOT NULL DEFAULT 0,
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
