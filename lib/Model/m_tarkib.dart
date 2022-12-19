import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class MTarkib {
  static Map<int, Set<MTarkib>> obyektlar = {};

  static MTarkibService? service;

  int	trMah=0;
  int	trMahTarkib=0;
  bool yoq = false;
  int	vaqtS=0;
  num miqdori=0;

  Mahsulot get mahsulot => Mahsulot.obyektlar[trMah]!;
  Mahsulot get mahsulotTarkib => Mahsulot.obyektlar[trMahTarkib]!;

  static Future<void> loadToGlobal(int tr) async {
    if(obyektlar[tr] == null) {
      for (var value in (await service!.select())) {
        var obj = MTarkib.fromJson(value);
        if(obyektlar[obj.trMah] == null) obyektlar[obj.trMah] = {};
        obyektlar[obj.trMah]!.add(obj);
      }
    }
  }

  MTarkib();

  MTarkib.fromJson(Map<String, dynamic> json){
    trMah = int.parse(json['trMah'].toString());
    trMahTarkib = int.parse(json['trMahTarkib'].toString());
    yoq = (json['yoq'] == 1) ? true : false;
    vaqtS = int.parse(json['vaqtS'].toString());
    miqdori = num.parse(json['miqdori'].toString());
  }
  
  Map<String, dynamic> toJson() =>
    {
      'trMah': trMah,
      'trMahTarkib': trMahTarkib,
      'yoq': yoq ? 1 : 0,
      'vaqtS': vaqtS,
      'miqdori': miqdori,
    };

  insert() async {
    if(obyektlar[trMah] == null) obyektlar[trMah] = {};
    obyektlar[trMah]!.add(this);
    await service!.replace(toJson());
  }

  delete() async {
    await service!.deleteId(trMah, trMahTarkib);
    obyektlar[trMah]!.remove(this);
  }

  @override
  String toString() {
    return "$trMah $trMahTarkib";
  }

  @override
  operator == (other) => other is MTarkib && other.trMah == trMah && other.trMahTarkib == trMahTarkib;

  @override
  int get hashCode => trMah.hashCode ^ trMahTarkib.hashCode;
}

class MTarkibService {
  final String prefix;
  final String table = "m_tarkib";
  MTarkibService({this.prefix = ''});

  String get createTable => """
CREATE TABLE "$table" (
  "trMah" INTEGER NOT NULL DEFAULT 0,
	"trMahTarkib"	INTEGER NOT NULL DEFAULT 0,
	"yoq"	INTEGER NOT NULL DEFAULT 0,
	"vaqtS"	INTEGER NOT NULL DEFAULT 0,
	"miqdori"	NUMERIC NOT NULL DEFAULT 0,
  PRIMARY KEY("trMah", "trMahTarkib")
);
  """;

  Future<List> select({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    List<dynamic> map = [];
    await for (final rows
        in db.watch("SELECT * FROM $table $where", tables: [table])) {
      for (final element in rows) {
        map.add(element);
      }
      return map;
    }
    return map;
  }

  Future<Map> selectId(int id, int idTarkib, {String? where}) async {
    Map row = await db.query("SELECT * FROM $table WHERE trMah = ? AND trMahTarkib = ?",
        params: [id],
        //fromMap: (map) => {},
        singleResult: true);
    return row;
  }

  Future<void> delete({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    await db.query("DELETE FROM `$table` $where");
  }

  Future<void> deleteId(int id, int idTarkib, {String? where}) async {
    if (where == null) {
      where = " trMah='$id' AND trMahTarkib = '$idTarkib'";
    } else {
      where = " trMah='$id' AND trMahTarkib = '$idTarkib' AND $where";
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
    var insertId = await db.insert(map as Map<String, dynamic>, table);
    return insertId;
  }

  Future replace(Map map) async {
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
    await db.query(sql);
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
