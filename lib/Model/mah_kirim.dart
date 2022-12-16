import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';

class MahKirim {
  static Map<int, MahKirim> obyektlar = {};
  static MahKirimService? service;

  int tr = 0;
  int turi = 0;
  int trHujjat = 0;
  bool qulf = false;
  bool yoq = false;
  int sana = 0;
  int vaqtS = 0;
  int vaqt = 0;
  int trMah = 0;
  num miqdori = 0;
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

  MahKirim.fromJson(Map<String, dynamic> json) {
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
    tannarxi = num.parse(json['tannarxi'].toString());
    tannarxiReal = num.parse(json['tannarxiReal'].toString());
    sotnarxi = num.parse(json['sotnarxi'].toString());
    trKont = int.parse(json['trKont'].toString());
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

  // for web-service
  Map<String, dynamic> toPost() => {
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
}

class MahKirimService {
  String prefix = '';
  final String table = "mah_kirim";
  MahKirimService({this.prefix = ''});

  String get tableName => prefix + table;

  String get createTable => """
    CREATE TABLE "$tableName" (
      "tr"	INTEGER NOT NULL DEFAULT 0,
      "turi"	INTEGER NOT NULL DEFAULT 0,
      "qulf" INTEGER NOT NULL DEFAULT 0,
      "yoq"	INTEGER NOT NULL DEFAULT 0,
      "trMah"	INTEGER NOT NULL DEFAULT 0,
      "trHujjat"	INTEGER NOT NULL DEFAULT 0,
      "sana"	INTEGER NOT NULL DEFAULT 0,
      "vaqtS"	INTEGER NOT NULL DEFAULT 0,
      "vaqt"	INTEGER NOT NULL DEFAULT 0,
      "miqdori"	NUMERIC NOT NULL DEFAULT 0,
      "tannarxi"	NUMERIC NOT NULL DEFAULT 0,
      "tannarxiReal"	NUMERIC NOT NULL DEFAULT 0,
      "sotnarxi"	NUMERIC NOT NULL DEFAULT 0,
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
        in db.watch("SELECT * FROM '$tableName' $where", tables: [table])) {
      for (final element in rows) {
        map[element['tr']] = element;
      }
      return map;
    }
    return map;
  }

  Future<Map> selectId(int hujjatId, int id, {String? where}) async {
    Map row =
        await db.query("SELECT * FROM '$tableName' WHERE trHujjat = ? AND tr = ?",
            params: [hujjatId, id],
            //fromMap: (map) => {},
            singleResult: true);
    return row;
  }

  Future<void> delete({String? where}) async {
    where ??= " WHERE $where";
    await db.query("DELETE FROM '$tableName' $where");
  }

  Future<void> deleteId(int hujjatId, int id, {String? where}) async {
    where ??= " trHujjat = $hujjatId AND tr='$id'";
    await delete(where: where);
  }

  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map row = await db.query("SELECT COUNT(*) FROM '$tableName'$where",
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
    Map row = await db.query(
        "SELECT tr FROM '$tableName' WHERE trHujjat = ? ORDER BY tr DESC LIMIT 0, 1",
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
    await db.execute(sql, tables: [table], params: params);
    //await db.query(sql);
    //await db.update(map as Map<String, dynamic>, table, keys: []);
  }
}
