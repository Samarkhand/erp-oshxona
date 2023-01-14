import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/mah_buyurtma.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/turi.dart';

class MahKirimTur extends Tur {
  static MahKirimTur qoldiq = MahKirimTur(0, "Boshlang'ich qoldiq", 0);
  static MahKirimTur kirim = MahKirimTur(1, "Kirim", HujjatTur.kirim.tr);
  static MahKirimTur kirimFil = MahKirimTur(2, "Filialdan Kirim", HujjatTur.kirimFil.tr); 
  static MahKirimTur qaytibOlish = MahKirimTur(3, "Qaytib olish", HujjatTur.qaytibOlish.tr);
  static MahKirimTur kirimIch = MahKirimTur(4, "Kirim ichlab chiqarish", HujjatTur.kirimIch.tr);

  static final Map<int, MahKirimTur> obyektlar = {
    kirim.tr: kirim,
    kirimFil.tr: kirimFil,
    qaytibOlish.tr: qaytibOlish,
    kirimIch.tr: kirimIch,
  };

  MahKirimTur(super.tr, super.nomi, this.trHujjatTur);

  late int trHujjatTur;
  HujjatTur get hujjatTur => HujjatTur.obyektlar[trHujjatTur]!;

  get olHujjatlar => MahKirim.obyektlar.values.where((element) => element.turi == tr).toList();
}

class MahKirim {
  insert() async {
    obyektlar[tr] = this;
    await service!.insert(toJson());
  }

  delete() async {
    await service!.deleteId(trHujjat, tr);
    obyektlar.remove(this);
  }

  update(List<String> cols) async {

  }

  Future<void> ozaytir([num miqdor = 1.0]) async {
    qoldi -= miqdor;
    await service!.update(
      {
        "qoldi": qoldi,
      },
      where: "tr=$tr",
    );
  }

  Future<void> kopaytir([num miqdor = 1.0]) async {
    qoldi += miqdor;
    await service!.update(
      {
        "qoldi": qoldi,
      },
      where: "tr=$tr",
    );
  }
  static Map<int, MahKirim> obyektlar = {};
  static MahKirimService? service;

  int tr = 0;
  int turi = MahKirimTur.kirim.tr;
  int trHujjat = 0;
  bool qulf = false;
  bool yoq = false;
  int trMah = 0;
  num qoldi = 0;
  num miqdori = 0;
  int sana = 0;
  int vaqtS = 0;
  int vaqt = 0;
  num tannarxi = 0;
  num tannarxiReal = 0;
  num sotnarxi = 0;
  int trKont = 0;
  String nomi = '';
  String kodi = "";
  String izoh = "";

  Mahsulot get mahsulot => Mahsulot.obyektlar[trMah] ?? Mahsulot.obyektlar[0]!;
  Kont? get kont => trKont == 0 ? null : Kont.obyektlar[trKont];
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);

  MahKirim();

  MahKirim.fromBrtm(MahBuyurtma brtm) {
    int now = DateTime.now().millisecondsSinceEpoch;
    tr = brtm.tr;
    turi = MahKirimTur.kirimFil.tr;
    //trHujjat = brtm.trHujjat;
    //qulf = true;
    //yoq = false;
    sana = brtm.sana;
    vaqtS = now;
    vaqt = now;
    trMah = trMah;
    miqdori = brtm.miqdori;
    qoldi = brtm.miqdori;
    tannarxi = brtm.narxi;
    tannarxiReal = brtm.narxi;
    sotnarxi = brtm.narxi;
    trKont = brtm.trKont;
    nomi = brtm.nomi;
    kodi = brtm.kodi;
    izoh = brtm.izoh;
  }

  MahKirim.fromJson(Map<String, dynamic> json) {
    tr = int.parse(json['tr'].toString());
    turi = int.parse(json['turi'].toString());
    trHujjat = int.parse(json['trHujjat'].toString());
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    sana = int.parse(json['sana'].toString())*1000;
    vaqtS = int.parse(json['vaqtS'].toString())*1000;
    vaqt = int.parse(json['vaqt'].toString())*1000;
    trMah = int.parse(json['trMah'].toString());
    miqdori = num.parse(json['miqdori'].toString());
    qoldi = num.parse(json['qoldi'].toString());
    tannarxi = num.parse(json['tannarxi'].toString());
    tannarxiReal = num.parse(json['tannarxiReal'].toString());
    sotnarxi = num.parse(json['sotnarxi'].toString());
    trKont = int.parse(json['trKont'].toString());
    nomi = json['nomi'];
    kodi = json['kodi'];
    izoh = json['izoh'];
  }

  Map<String, dynamic> toJson() => {
        'tr': tr,
        'turi': turi,
        'trHujjat': trHujjat,
        'yoq': yoq ? 1 : 0,
        'qulf': qulf ? 1 : 0,
        'trMah': trMah,
        'sana': toSecond(sana),
        'vaqtS': toSecond(vaqtS),
        'vaqt': toSecond(vaqt),
        'qoldi': qoldi,
        'miqdori': miqdori,
        'tannarxi': tannarxi,
        'tannarxiReal': tannarxiReal,
        'sotnarxi': sotnarxi,
        'trKont': trKont,
        'nomi': nomi,
        'kodi': kodi,
        'izoh': izoh,
      };

  MahKirim.fromServer(Map<String, dynamic> json) {
    tr = int.parse(json['tr'].toString());
    turi = int.parse(json['turi'].toString());
    trHujjat = int.parse(json['trHujjat'].toString());
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    sana = int.parse(json['sana'].toString());
    vaqtS = int.parse(json['vaqtS'].toString());
    vaqt = int.parse(json['vaqt'].toString());
    trMah = int.parse(json['trMah'].toString());
    miqdori = num.parse(json['miqdori'].toString());
    qoldi = num.parse(json['qoldi'].toString());
    tannarxi = num.parse(json['tannarxi'].toString());
    tannarxiReal = num.parse(json['tannarxiReal'].toString());
    sotnarxi = num.parse(json['sotnarxi'].toString());
    trKont = int.parse(json['trKont'].toString());
    nomi = json['nomi'];
    kodi = json['kodi'];
    izoh = json['izoh'];
  }

  // for web-service
  Map<String, dynamic> toServer() => {
        'trHujjat': trHujjat,
        'turi': turi,
        'tr': tr,
        'yoq': yoq ? 1 : 0,
        'qulf': qulf ? 1 : 0,
        'trMah': trMah,
        'sana': sana,
        'vaqtS': vaqtS,
        'vaqt': vaqt,
        'miqdori': miqdori,
        'tannarxi': tannarxi,
        'tannarxiReal': tannarxiReal,
        'sotnarxi': sotnarxi,
        'trKont': trKont,
        'nomi': nomi,
        'kodi': kodi,
        'izoh': izoh,
      };

  @override
  operator == (other) => other is MahKirim && other.tr == tr;

  @override
  int get hashCode => tr.hashCode;
}

class MahKirimService {
  String prefix = '';
  final String table = "mah_kirim";
  MahKirimService({this.prefix = ''});

  String get tableName => "'$prefix$table'";

  String get createTable => """
    CREATE TABLE $tableName (
      "tr"	INTEGER NOT NULL DEFAULT 0,
      "turi"	INTEGER NOT NULL DEFAULT 0,
      "trHujjat"	INTEGER NOT NULL DEFAULT 0,
      "qulf" INTEGER NOT NULL DEFAULT 0,
      "yoq"	INTEGER NOT NULL DEFAULT 0,
      "trMah"	INTEGER NOT NULL DEFAULT 0,
      "qoldi"	NUMERIC NOT NULL DEFAULT 0,
      "miqdori"	NUMERIC NOT NULL DEFAULT 0,
      "sana"	INTEGER NOT NULL DEFAULT 0,
      "vaqtS"	INTEGER NOT NULL DEFAULT 0,
      "vaqt"	INTEGER NOT NULL DEFAULT 0,
      "tannarxi"	NUMERIC NOT NULL DEFAULT 0,
      "tannarxiReal"	NUMERIC NOT NULL DEFAULT 0,
      "sotnarxi"	NUMERIC NOT NULL DEFAULT 0,
      "trKotib"	INTEGER NOT NULL DEFAULT 0,
      "trKont"	INTEGER NOT NULL DEFAULT 0,
      "nomi"	TEXT NOT NULL DEFAULT '',
      "kodi"	TEXT NOT NULL DEFAULT '',
      "izoh"	TEXT NOT NULL DEFAULT '',
      PRIMARY KEY("tr")
    );
  """;

  Future<Map> select({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map<int, dynamic> map = {};
    await for (final rows
        in db.watch("SELECT * FROM $tableName $where", tables: [tableName])) {
      for (final element in rows) {
        map[element['tr']] = element;
      }
      return map;
    }
    return map;
  }

  Future<Map> selectId(int id, {String? where}) async {
    Map row =
        await db.query("SELECT * FROM $tableName WHERE tr = ?",
            params: [id],
            //fromMap: (map) => {},
            singleResult: true);
    return row;
  }

  Future<void> delete({String? where}) async {
    where ??= " WHERE $where";
    await db.query("DELETE FROM $tableName $where");
  }

  Future<void> deleteId(int hujjatId, int id, {String? where}) async {
    where ??= " tr='$id'";
    await delete(where: where);
  }

  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map row = await db.query("SELECT COUNT(*) FROM $tableName $where",
        //params: [tableName],
        //fromMap: (map) => {},
        singleResult: true);
    return int.parse(row['seq'].toString()) + 1;
  }

  Future<int> insert(Map map) async {
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];

    var insertId = await db.insert(map as Map<String, dynamic>, tableName);
    return insertId;
  }

  Future<int> newId() async {
    int? row = await db.query(
        "SELECT tr FROM $tableName ORDER BY tr DESC LIMIT 0, 1",
        //params: [hujjatId],
        //fromMap: (map) => {},
        singleResult: true);
    return (row ?? 0) + 1;
  }

  Future<int> replace(Map map) async {
    map['tr'] = (map['tr'] == 0) ? null : map.remove('tr');

    var cols = '';
    var vals = '';

    var vergul = '';

    map.forEach((col, val) {
      val = val;
      col = col;
      cols += "$vergul `$col`";
      vals += "$vergul '$val'";
      if (vergul == "") {
        vergul = ',';
      }
    });
    var sql = "REPLACE INTO '$tableName' ($cols) VALUES ($vals)";
    var res = await db.query(sql);
    return res.insertId;
  }

  Future<void> update(Map map, {String? where}) async {
    where = where == null ? "" : " WHERE $where";

    String updateClause = "";
    final List params = [];
    final values = map.keys; //.where((element) => !keys.contains(element));
    for (String value in values) {
      if (updateClause.isNotEmpty) updateClause += ", ";
      updateClause += "$value=?";
      params.add(map[value]);
    }

    final String sql = "UPDATE '$tableName' SET $updateClause$where";
    await db.execute(sql, tables: [tableName], params: params);
    //await db.query(sql);
    //await db.update(map as Map<String, dynamic>, tableName, keys: []);
  }
}
