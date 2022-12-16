import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';

class MahChiqim {
  static Map<int, MahChiqim> obyektlar = {};
  static MahChiqimService? service;

  int trHujjat = 0;
  int tr = 0;
  int turi = 0;
  bool qulf = false;
  bool yoq = false;
  int trKont = 0;
  int trMah = 0;
  int sana = 0;
  int vaqtS = 0;
  int vaqt = 0;
  num miqdori = 0;
  num tannarxi = 0;
  num sotnarxi = 0;
  num sotnarxiReal = 0;
  String nomi = '';
  String kodi = "";
  String izoh = "";

  Mahsulot get mahsulot => Mahsulot.obyektlar[trMah] ?? Mahsulot.obyektlar[0]!;
  Kont? get kont => trKont == 0 ? null : Kont.obyektlar[trKont];
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);
  
  MahChiqim();

  MahChiqim.fromJson(Map<String, dynamic> json) {
    trHujjat = int.parse(json['trHujjat'].toString());
    tr = int.parse(json['tr'].toString());
    turi = int.parse(json['turi'].toString());
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    trKont = int.parse(json['trKont'].toString());
    trMah = int.parse(json['trMah'].toString());
    sana = int.parse(json['sana'].toString());
    vaqtS = int.parse(json['vaqtS'].toString());
    vaqt = int.parse(json['vaqt'].toString());
    miqdori = num.parse(json['miqdori'].toString());
    tannarxi = num.parse(json['tannarxi'].toString());
    sotnarxi = num.parse(json['sotnarxi'].toString());
    sotnarxiReal = num.parse(json['sotnarxiReal'].toString());
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
        'sana': sana,
        'vaqtS': vaqtS,
        'vaqt': vaqt,
        'miqdori': miqdori,
        'tannarxi': tannarxi,
        'sotnarxi': sotnarxi,
        'sotnarxiReal': sotnarxiReal,
        'nomi': nomi,
        'kodi': kodi,
        'izoh': izoh,
      };

  // for web-service
  Map<String, dynamic> toPost() => {
        'trHujjat': trHujjat,
        'turi': turi,
        'tr': tr,
        'yoq': yoq ? 1 : 0,
        'qulf': qulf ? 1 : 0,
        'trKont': trKont,
        'trMah': trMah,
        'sana': sana,
        'vaqtS': vaqtS,
        'vaqt': vaqt,
        'miqdori': miqdori,
        'tannarxi': tannarxi,
        'sotnarxi': sotnarxi,
        'sotnarxiReal': sotnarxiReal,
        'nomi': nomi,
        'kodi': kodi,
        'izoh': izoh,
      };

}

class MahChiqimService {
  String prefix = '';
  final String table = "mah_chiqim";
  MahChiqimService({this.prefix = ''});

  String get tableName => prefix + table;

  String get createTable => """
    CREATE TABLE "$tableName" (
      "trHujjat"	INTEGER NOT NULL DEFAULT 0,
      "tr"	INTEGER NOT NULL DEFAULT 0,
      "turi"	INTEGER NOT NULL DEFAULT 0,
      "qulf" INTEGER NOT NULL DEFAULT 0,
      "yoq"	INTEGER NOT NULL DEFAULT 0,
      "trKont"	INTEGER NOT NULL DEFAULT 0,
      "trMah"	INTEGER NOT NULL DEFAULT 0,
      "sana"	INTEGER NOT NULL DEFAULT 0,
      "vaqtS"	INTEGER NOT NULL DEFAULT 0,
      "vaqt"	INTEGER NOT NULL DEFAULT 0,
      "miqdori"	NUMERIC NOT NULL DEFAULT 0,
      "tannarxi"	NUMERIC NOT NULL DEFAULT 0,
      "sotnarxi"	NUMERIC NOT NULL DEFAULT 0,
      "sotnarxiReal"	NUMERIC NOT NULL DEFAULT 0,
      "nomi"	TEXT NOT NULL DEFAULT '',
      "kodi"	TEXT NOT NULL DEFAULT '',
      "izoh"	TEXT NOT NULL DEFAULT '',
      PRIMARY KEY("trHujjat","tr")
    );
  """;

  Future<Map> select({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map<int, dynamic> map = {};
    await for (final rows
        in db.watch("SELECT * FROM $table $where", tables: [table])) {
      for (final element in rows) {
        map[element['tr']] = element;
      }
      return map;
    }
    return map;
  }

  Future<Map> selectId(int hujjatId, int id, {String? where}) async {
    Map row = await db.query("SELECT * FROM $table WHERE trHujjat = ? AND tr = ?",
        params: [hujjatId, id],
        //fromMap: (map) => {},
        singleResult: true);
    return row;
  }

  Future<void> delete({String? where}) async {
    where ??= " WHERE $where";
    await db.query("DELETE FROM `$table` $where");
  }

  Future<void> deleteId(int hujjatId, int id, {String? where}) async {
    where ??= " trHujjat = $hujjatId AND tr='$id'";
    await delete(where: where);
  }

  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map row = await db.query("SELECT COUNT(*) FROM $table$where",
        //params: [table],
        //fromMap: (map) => {},
        singleResult: true);
    return int.parse(row['seq'].toString()) + 1;
  }

  Future<int> insert(Map map) async {
    map['trHujjat'] = (map['trHujjat'] == 0) ? null : map['trHujjat'];
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];

    var insertId = await db.insert(map as Map<String, dynamic>, table);
    return insertId;
  }

  Future<int> newId(int hujjatId) async {
    Map row = await db.query("SELECT tr FROM $table WHERE trHujjat = ? ORDER BY tr DESC LIMIT 0, 1",
        params: [hujjatId],
        //fromMap: (map) => {},
        singleResult: true);
    return row['tr'] + 1;
  }

  Future<int> replace(Map map) async {
    map['trHujjat'] = (map['trHujjat'] == 0) ? null : map.remove('trHujjat');
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
    var sql = "REPLACE INTO $table ($cols) VALUES ($vals)";
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

    final String sql = "UPDATE $table SET $updateClause$where";
    await db.execute(sql, tables: [table], params: params);
    //await db.query(sql);
    //await db.update(map as Map<String, dynamic>, table, keys: []);
  }
}
