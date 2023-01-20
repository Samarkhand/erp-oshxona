import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/kont.dart';

class HujjatTarqat {
  static HujjatTarqatService? service;
  static final Set<HujjatTarqat> obyektlar = {};
  static HujjatTarqat? ol(int tr) => obyektlar.firstWhere((element) => element.tr == tr);

  int tr = 0;
  bool qulf =  false;
  bool yoq = false;
  int sana = 0;
  int vaqtS = 0;
  int vaqt = 0;
  int trKont = 0;
  int trHujjat = 0;
  int raqami = 0;
  String izoh = "";
  String kodi = "";

  num get summa => summaNum ??  yaxlitla(summaOl());
  Kont? get kont => trKont == 0 ? null : Kont.obyektlar[trKont];
  Hujjat? get hujjat => trHujjat == 0 ? null : Hujjat.ol(HujjatTur.kirimIch, trHujjat);
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);
  
  HujjatTarqat();

  HujjatTarqat.fromJson(Map<String, dynamic> json) {
    tr = json['tr'];
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    sana = int.parse(json['sana'].toString()) * 1000;
    vaqtS = int.parse(json['vaqtS'].toString()) * 1000;
    vaqt = int.parse(json['vaqt'].toString()) * 1000;
    trKont = json['trKont'];
    trHujjat = json['trHujjat'];
    raqami = json['raqami'];
    izoh = json['izoh'];
    kodi = json['kodi'];
  }

  Map<String, dynamic> toJson() => {
        'tr': tr,
        'qulf': qulf ? 1 : 0,
        'yoq': yoq ? 1 : 0,
        'sana': toSecond(sana),
        'vaqtS': toSecond(vaqtS),
        'vaqt': toSecond(vaqt),
        'trKont': trKont,
        'trHujjat': trHujjat,
        'raqami': raqami,
        'izoh': izoh,
        'kodi': kodi,
      };

  Future<void> delete() {
    obyektlar.remove(this);
    return service!.deleteId(tr);
  }

  Future<int> insert() {
    obyektlar.add(this);
    //logConsole("insert() ${toJson()}");
    return service!.insert(toJson());
  }

  Future<void> update() {
    return service!.update(toJson(), where: " tr='$tr'");
  }

  num? summaNum = 0;
  num summaOl() {
    summaNum = 50000;
    return summaNum!;
  }

  @override
  String toString(){
    return tr.toString();
  }

  /*
  Future<void> summaHisobla() async {
    summa = 0;
    List obyektlar = await MahChiqimService.getAll(where: "turi=${turi} AND turi=${tr}");
    
    for (MahChiqim obj in obyektlar) {
      summa += obj.sotnarxiReal * obj.miqdori;
    }
  }
  */

  @override
  operator == (other) => other is HujjatTarqat && other.tr == tr;

  @override
  int get hashCode => tr.hashCode;
}

class HujjatTarqatService extends HujjatPartiyaService {
  @override
  final String table = "hujjat_tarqat";

  HujjatTarqatService({super.prefix = ''});

  @override
  String get tableName => "'$prefix$table'";

  @override
  String get createTable => """
    CREATE TABLE $tableName (
      "tr"	INTEGER NOT NULL DEFAULT 0,
      "qulf"	INTEGER NOT NULL DEFAULT 0,
      "yoq"	INTEGER NOT NULL DEFAULT 0,
      "sana"	INTEGER NOT NULL DEFAULT 0,
      "vaqtS"	INTEGER NOT NULL DEFAULT 0,
      "vaqt"	INTEGER NOT NULL DEFAULT 0,
      "trHujjat"	INTEGER NOT NULL DEFAULT 0,
      "trKont"	INTEGER NOT NULL DEFAULT 0,
      "raqami"	INTEGER NOT NULL DEFAULT 0,
      "kodi"	TEXT NOT NULL DEFAULT '',
      "izoh"	TEXT NOT NULL DEFAULT '',
      PRIMARY KEY("tr")
    );
  """;

}

