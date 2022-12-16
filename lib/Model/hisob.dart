import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class Hisob {
  static Map<int, Hisob> obyektlar = {/*0: Hisob.bosh()..nomi = "Noma'lum"*/};
  static CrudService? service;

  int tr;
  bool yoq = false;
  bool abh = false;
  bool active = true;
  int tartib = 0;
  int saqlashTuri = 0;
  int turi = 0;
  num balans = 0;
  num plan = 0;
  int val = 0;
  String nomi;
  IconData icon = const IconData(0);
  Color color = const Color(0xFF000000);

  Hisob(
      {required this.tr,
      required this.yoq,
      required this.abh,
      required this.tartib,
      required this.turi,
      required this.saqlashTuri,
      required this.balans,
      required this.plan,
      required this.nomi,
      required this.icon,
      required this.color,
      required this.active});

  Hisob.bosh()
      : tr = 0,
        yoq = false,
        abh = false,
        active = true,
        tartib = 0,
        turi = 0,
        saqlashTuri = 0,
        balans = 0,
        plan = 0,
        val = 0,
        nomi = '',
        icon = IconData(int.parse(0.toString()), fontFamily: "MaterialIcons"),
        color = Color(int.parse(0.toString()));

  Hisob.fromJson(Map json)
      : tr = int.parse(json['tr'].toString()),
        yoq = (json['yoq'] == 1) ? true : false,
        abh = (json['abh'] == 1) ? true : false,
        active = (json['active'] == 1) ? true : false,
        tartib = int.parse(json['tartib'].toString()),
        turi = int.parse(json['turi'].toString()),
        saqlashTuri = int.parse(json['saqlashTuri'].toString()),
        balans = num.parse(json['balans'].toString()),
        plan = num.parse(json['plan'].toString()),
        val = int.parse(json['val'].toString()),
        nomi = json['nomi'].toString(),
        icon = IconData(int.parse(json['icon'].toString()),
            fontFamily: "MaterialIcons"),
        color = Color(int.parse(json['color'].toString()));

  Map<String, dynamic> toJson() => {
        'tr': tr,
        'yoq': yoq ? 1 : 0,
        'abh': abh ? 1 : 0,
        'active': active ? 1 : 0,
        'tartib': tartib,
        'turi': turi,
        'saqlashTuri': saqlashTuri,
        'balans': balans,
        'plan': plan,
        'val': val,
        'nomi': nomi,
        'icon': icon.codePoint,
        'color': color.value,
      };

  Hisob.fromServer(Map<String, dynamic> json)
      : tr = int.parse(json['tr'].toString()),
        yoq = (json['yoq'] == 1) ? true : false,
        abh = (json['abh'] == 1) ? true : false,
        active = (json['active'] == 1) ? true : false,
        tartib = int.parse(json['tartib'].toString()),
        turi = int.parse(json['turi'].toString()),
        saqlashTuri = int.parse(json['saqlashTuri'].toString()),
        balans = num.parse(json['balans'].toString()),
        plan = num.parse(json['plan'].toString()),
        val = int.parse(json['val'].toString()),
        nomi = json['nomi'].toString(),
        icon = IconData(int.parse(0.toString()), fontFamily: "MaterialIcons"),
        color = Color(int.parse(0.toString()));

  Map<String, dynamic> toServer() => {
        'tr': tr,
        'yoq': yoq ? 1 : 0,
        'abh': abh ? 1 : 0,
        'active': active ? 1 : 0,
        'tartib': tartib,
        'turi': turi,
        'saqlashTuri': saqlashTuri,
        'balans': balans,
        'plan': plan,
        'val': val,
        'nomi': nomi,
        'icon': icon.codePoint,
        'color': color.value,
      };

  Future<void> balansKopaytir(num miqdor) async {
    balans = balans + miqdor;
    await service?.update({'balans': balans}, where: " tr=$tr");
  }

  Future<void> balansOzaytir(num miqdor) async {
    balans = balans - miqdor;
    await service?.update({'balans': balans}, where: " tr=$tr");
  }

  @override
  String toString() => nomi;

  @override
  operator == (other) => other is Hisob && other.tr == tr;

  @override
  int get hashCode => tr.hashCode ^ nomi.hashCode ^ color.hashCode;
}

class HisobService extends CrudService {
  @override
  HisobService({super.prefix = ''}) : super("hisob");

  static String createTable = """
CREATE TABLE "hisob" (
	"tr"	INTEGER DEFAULT 0,
	"yoq"	INTEGER DEFAULT 0,
	"abh"	INTEGER DEFAULT 0,
	"tartib"	INTEGER DEFAULT 0,
	"turi"	INTEGER DEFAULT 0,
	"saqlashTuri"	INTEGER DEFAULT 0,
	"balans"	NUMERIC DEFAULT 0,
	"plan"	NUMERIC DEFAULT 0,
	"val"	INTEGER DEFAULT 0,
	"nomi"	TEXT DEFAULT '',
	"icon"	INTEGER DEFAULT 0,
	"color"	INTEGER DEFAULT 0,
	"active"	INTEGER DEFAULT 0,
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
