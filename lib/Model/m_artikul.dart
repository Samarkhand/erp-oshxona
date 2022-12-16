import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';

class MArtikul {
  static Map<String, List<MArtikul>> obyektlar = {};
  static Map<String, List<Mahsulot>> mahlar = {};

  static MArtikulService? service;

  String artikul = '';
  int trMah = 0;
  int	vaqtS = 0;

  Mahsulot get mahsulot => Mahsulot.obyektlar[trMah] ?? Mahsulot.obyektlar[0]!;

  MArtikul();

  MArtikul.fromJson(Map<String, dynamic> json):
    artikul = json['artikul'].toString(),
    trMah = int.parse(json['trMah'].toString()),
    vaqtS = int.parse(json['vaqtS'].toString());
  
  Map<String, dynamic> toJson() =>
    {
      'artikul': artikul,
      'trMah': trMah,
      'vaqtS': vaqtS,
    };
    
  MArtikul.fromServer(Map<String, dynamic> json):
    artikul = json['artikul'].toString(),
    trMah = int.parse(json['tr_mah'].toString()),
    vaqtS = 0;
  
  Map<String, dynamic> toServer() =>
    {
      'artikul': artikul,
      'tr_mah': trMah,
      'vaqtS': vaqtS,
    };

}

class MArtikulService{
  final String prefix = '';
  final String table = "m_artikul";
  MArtikulService();

  static String createTable = """
CREATE TABLE "m_artikul" (
	"code"	TEXT NOT NULL DEFAULT '',
  "trMah"	INTEGER NOT NULL DEFAULT 0,
	"vaqtS"	INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY("code","trMah")
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

  Future<Map> selectId(int id, {String? where}) async {
    Map row = await db.query("SELECT * FROM $table WHERE tr = ?",
        params: [id],
        //fromMap: (map) => {},
        singleResult: true);
    return row;
  }

  Future<void> delete({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    await db.query("DELETE FROM `$table` $where");
  }

  Future<void> deleteId(int id, {String? where}) async {
    if (where == null) {
      where = ' tr=\'$id\'';
    } else {
      where = " tr='$id' AND $where";
    }
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
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];
    
    var insertId = await db.insert(map as Map<String, dynamic>, table);
    return insertId;
  }

  Future<int> newId() async {
    Map row = await db.query("SELECT * FROM sqlite_sequence WHERE name = ?",
        params: [table],
        //fromMap: (map) => {},
        singleResult: true);
    return int.parse(row['seq'].toString()) + 1;
  }

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
