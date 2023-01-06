import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class MOlchov {
  static Map<int, MOlchov> obyektlar = {
    //0 : MOlchov()..tr=0..tartib=0..kasr=0..nomi=""..vaqtS=0,
  };

  static CrudService? service;

  int	tr=0;
  bool yoq = false;
  int	tartib=0;
  num kasr=0;
  int	vaqtS=0;
  String nomi = '';

  MOlchov();

  MOlchov.fromJson(Map<String, dynamic> json){
    tr = int.parse(json['tr'].toString());
    yoq = (json['yoq'] == 1) ? true : false;
    tartib = int.parse(json['tartib'].toString());
    kasr = num.parse(json['kasr'].toString());
    vaqtS = int.parse(json['vaqtS'].toString());
    nomi = json['nomi'].toString();
  }
  
  Map<String, dynamic> toJson() =>
    {
      'tr': tr,
      'yoq': yoq ? 1 : 0,
      'tartib': tartib,
      'kasr': kasr,
      'vaqtS': vaqtS,
      'nomi': nomi,
    };

  MOlchov.fromServer(Map<String, dynamic> json){
    tr = int.parse(json['tr'].toString());
    vaqtS = int.parse(json['vaqtS'].toString());
    nomi = json['nomi'].toString();
  }
  
  Map<String, dynamic> toServer() =>
    {
      'tr': tr,
      'vaqtS': vaqtS,
      'nomi': nomi,
    };

  @override
  String toString() {
    return nomi;
  }

  @override
  operator ==(other) => other is MOlchov && other.tr == tr;

  @override
  int get hashCode => tr.hashCode ^ nomi.hashCode;
}

class MOlchovService extends CrudService {
  @override
  MOlchovService({super.prefix = ''}) : super("m_olchov");

  static String createTable = """
CREATE TABLE "m_olchov" (
  "tr"	INTEGER NOT NULL DEFAULT 0,
	"yoq"	INTEGER NOT NULL DEFAULT 0,
	"tartib"	INTEGER NOT NULL DEFAULT 0,
	"vaqtS"	INTEGER NOT NULL DEFAULT 0,
	"kasr"	NUMERIC NOT NULL DEFAULT 0,
	"trKotib"	INTEGER NOT NULL DEFAULT 0,
	"nomi"	TEXT NOT NULL DEFAULT '',
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
    await db.query(sql);
    return 0;
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
