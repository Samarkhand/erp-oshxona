import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class Mahal {
  static Map<int, Mahal> obyektlar = {/*0: Mahal.bosh()..nomi = "Noma'lum"*/};
  static CrudService? service;

  int tr = 0;
  bool yoq = false;
  int vaqtS = 0;
  int vaqt = 0;
  String nomi = '';

  Mahal();

  Mahal.fromJson(Map json)
      : tr = int.parse(json['tr'].toString()),
        yoq = (json['yoq'] == 1) ? true : false,
        vaqtS = int.parse(json['vaqtS'].toString()),
        vaqt = int.parse(json['vaqt'].toString()),
        nomi = json['nomi'].toString();

  Map<String, dynamic> toJson() => {
        'tr': tr,
        'yoq': yoq ? 1 : 0,
        'vaqtS': vaqtS,
        'vaqt': vaqt,
        'nomi': nomi,
      };

  @override
  String toString() => nomi;

  @override
  operator ==(other) => other is Mahal && other.tr == tr;

  @override
  int get hashCode => tr.hashCode ^ nomi.hashCode;
}

class MahalService extends CrudService {
  @override
  MahalService({super.prefix = ''}) : super("kBolim");

  static String createTable = """
CREATE TABLE "kBolim" (
	"tr"	INTEGER DEFAULT 0,
	"yoq"	INTEGER DEFAULT 0,
	"active"	INTEGER DEFAULT 0,
	"tartib"	INTEGER DEFAULT 0,
	"turi"	INTEGER DEFAULT 0,
	"nomi"	TEXT DEFAULT '',
	"icon"	INTEGER DEFAULT 0,
	"color"	INTEGER DEFAULT 0,
	PRIMARY KEY("tr" AUTOINCREMENT)
);
""";

  @override
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

  @override
  Future<Map> selectId(int id, {String? where}) async {
    Map row = await db.query("SELECT * FROM $table WHERE tr = ?",
        params: [id],
        //fromMap: (map) => {},
        singleResult: true);
    return row;
  }

  @override
  Future<void> delete({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    await db.query("DELETE FROM `$table` $where");
  }

  @override
  Future<void> deleteId(int id, {String? where}) async {
    if (where == null) {
      where = ' tr=\'$id\'';
    } else {
      where = " tr='$id' AND $where";
    }
    await delete(where: where);
  }

  @override
  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map row = await db.query("SELECT COUNT(*) FROM $table$where",
        //params: [table],
        //fromMap: (map) => {},
        singleResult: true);
    return int.parse(row['seq'].toString()) + 1;
  }

  @override
  Future<int> insert(Map map) async {
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];

/*
    var cols = '';
    var vals = '';

    var vergul = '';

    map.forEach((col, val) {
      cols += "$vergul `$col`";
      vals += "$vergul '$val'";
      if (vergul == "") {
        vergul = ',';
      }
    });
    var sql = "INSERT INTO $table ($cols) VALUES ($vals)";
    var res = await db.query(sql);
    return res.insertId;*/

    var insertId = await db.insert(map as Map<String, dynamic>, table);
    return insertId;
  }

  @override
  Future<int> newId() async {
    Map row = await db.query("SELECT * FROM sqlite_sequence WHERE name = ?",
        params: [table],
        //fromMap: (map) => {},
        singleResult: true);
    return int.parse(row['seq'].toString()) + 1;
  }

  @override
  Future<int> replace(Map map) async {
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];

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

  @override
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
