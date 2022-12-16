import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class Kont {
  static Map<int, Kont> obyektlar = {
    //0: Kont()..nomi = "Noma'lum",
  };
  static CrudService? service;

  int tr = 0;
  bool yoq = false;
  bool active = true;
  int bolim = 0;
  num balans = 0;
  num oyboBalans = 0;
  num boshBalans = 0;
  DateTime vaqt = DateTime(2000);
  String davKod = '';
  String telKod = '';
  String tel = '';
  String nomi = '';
  String izoh = '';

  Kont();

  Kont.fromJson(Map json)
      :
        tr = int.parse(json['tr'].toString()),
        yoq = json['yoq'].toString() == "1",
        active = json['active'].toString() == '1',
        bolim = int.parse(json['bolim'].toString()),
        balans = num.parse(json['balans'].toString()),
        oyboBalans = num.parse(json['oyboBalans'].toString()),
        boshBalans = num.parse(json['boshBalans'].toString()),
        vaqt = DateTime.fromMillisecondsSinceEpoch(toMilliSecond(json['vaqt'])),
        davKod = json['davKod'].toString(),
        telKod = json['telKod'].toString(),
        tel = json['tel'].toString(),
        nomi = json['nomi'].toString(),
        izoh = json['izoh'].toString();

  Map<String, dynamic> toJson() => {
        'tr': tr,
        'yoq': yoq ? 1 : 0,
        'active': active ? 1 : 0,
        'bolim': bolim,
        'balans': balans,
        'oyboBalans': oyboBalans,
        'boshBalans': boshBalans,
        'vaqt': toSecond(vaqt.millisecondsSinceEpoch),
        'davKod': davKod,
        'telKod': telKod,
        'tel': tel,
        'nomi': nomi,
        'izoh': izoh,
      };

  Kont.fromServer(Map<String, dynamic> json)
      :
        tr = int.parse(json['tr'].toString()),
        yoq = false,
        active = true,
        bolim = int.parse(json['bolim'].toString()),
        balans = num.parse(json['balans'].toString()),
        oyboBalans = num.parse(json['oyboBalans'].toString()),
        boshBalans = num.parse(json['boshBalans'].toString()),
        vaqt = DateTime.fromMillisecondsSinceEpoch(toMilliSecond(json['vaqt'])),
        davKod = json['davKod'].toString(),
        telKod = json['telKod'].toString(),
        tel = json['tel'].toString(),
        nomi = "${json['fish']}, ${json['nomi']}",
        //this.izoh = json['izoh'].toString(),
        izoh = '';

  Map<String, dynamic> toServer() => {
        'tr': tr,
        'yoq': yoq ? 1 : 0,
        'active': active ? 1 : 0,
        'bolim': bolim,
        'balans': balans,
        'oyboBalans': oyboBalans,
        'boshBalans': boshBalans,
        'davKod': davKod,
        'telKod': telKod,
        'tel': tel,
        'nomi': nomi,
        'izoh': izoh,
      };

  Future<void> balansKopaytir(num miqdor) async {
    balans = balans + miqdor;
    service!.update({'balans': balans}, where: "tr=$tr");
  }

  Future<void> balansOzaytir(num miqdor) async {
    balans = balans - miqdor;
    service!.update({'balans': balans}, where: "tr=$tr");
  }
}

class KontService extends CrudService {
  @override
  KontService({super.prefix = ''}) : super("kont");

  static String createTable = """
CREATE TABLE "kont" (
	"tr"	INTEGER DEFAULT 0,
	"yoq"	INTEGER DEFAULT 0,
	"trShaxs"	INTEGER DEFAULT 0,
	"active"	INTEGER DEFAULT 0,
	"bolim"	INTEGER DEFAULT 0,
	"balans"	NUMERIC DEFAULT 0,
	"oyboBalans"	NUMERIC DEFAULT 0,
	"boshBalans"	NUMERIC DEFAULT 0,
	"vaqt"	INTEGER DEFAULT 0,
	"vaqtS"	INTEGER DEFAULT 0,
  "davKod"	TEXT DEFAULT '',
	"telKod"	TEXT DEFAULT '',
	"tel"	TEXT DEFAULT '',
	"nomi"	TEXT DEFAULT '',
	"izoh"	TEXT DEFAULT '',
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
