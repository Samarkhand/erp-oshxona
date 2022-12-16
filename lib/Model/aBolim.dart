import 'package:erp_oshxona/Model/system/turi.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class ABolimTur extends Tur {
  ABolimTur(super.tr, super.nomi, {required super.ranggi, required super.icon});

  static final Map<int, ABolimTur> obyektlar = {
    tushum.tr: tushum,
    chiqim.tr: chiqim,
    mahsulot.tr: mahsulot,
    tizim.tr: tizim,
  };

  static final ABolimTur tushum =
      ABolimTur(1, "Tushum", ranggi: Colors.blue, icon: Icons.arrow_downward);
  static final ABolimTur chiqim =
      ABolimTur(2, "Chiqim", ranggi: Colors.red, icon: Icons.arrow_upward);
  static final ABolimTur mahsulot =
      ABolimTur(3, "Mahsulot", ranggi: Colors.red, icon: Icons.arrow_upward);
  static final ABolimTur tizim =
      ABolimTur(4, "Boshqa", ranggi: Colors.grey, icon: Icons.ac_unit);
}

class ABolim {
  static Map<int, ABolim> obyektlar = {
    //0: ABolim()..tr=0..nomi="Noma'lum"..icon=Icons.folder_open,
  };
  static CrudService? service;

  // structure
  int tr = 0;
  int turi = 0;
  bool yoq = false;
  int trBobo = 0;
  int tartib = 0;
  num summa = 0;
  String nomi = '';
  IconData icon = const IconData(0);
  Color color = const Color(0xFF000000);
  bool active = true;

  ABolim();

  ABolim.fromJson(Map json)
      : tr = int.parse(json['tr'].toString()),
        turi = int.parse(json['turi'].toString()),
        yoq = (json['yoq'] == '1') ? true : false,
        trBobo = int.parse(json['trBobo'].toString()),
        tartib = int.parse(json['tartib'].toString()),
        summa = num.parse(json['summa'].toString()),
        nomi = json['nomi'],
        icon = IconData(int.parse(json['icon'].toString()),
            fontFamily: "MaterialIcons"),
        color = Color(int.parse(json['color'].toString())),
        active = (json['active'] == 1) ? true : false;

  Map<String, dynamic> toJson() => {
        'tr': tr,
        'turi': turi,
        'yoq': yoq ? 1 : 0,
        'active': active ? 1 : 0,
        'trBobo': trBobo,
        'tartib': tartib,
        'summa': summa,
        'nomi': nomi,
        'icon': icon.codePoint,
        'color': color.value,
      };

  @override
  String toString() {
    return nomi;
  }

  @override
  operator == (other) => other is ABolim && other.tr == tr;

  @override
  int get hashCode => tr.hashCode ^ nomi.hashCode;
}

class ABolimService extends CrudService {
  @override
  ABolimService({super.prefix = ''}) : super("aBolim");

  static String createTable = """

CREATE TABLE `aBolim` (
  `tr` INTEGER DEFAULT 0,
  `turi` INTEGER DEFAULT 0,
  `yoq` INTEGER DEFAULT 0,
  `trBobo` INTEGER DEFAULT 0,
  `tartib` INTEGER DEFAULT 0,
  `summa` NUMERIC DEFAULT 0,
  `nomi` TEXT DEFAULT '',
  `icon` INTEGER DEFAULT 0,
  `color` INTEGER DEFAULT 0,
  `active` INTEGER DEFAULT 0,
	PRIMARY KEY("tr" AUTOINCREMENT)
);
""";

  @override
  Future<Map> select({String? where}) async {
    where = where == null ? "" : " WHERE $where" ;
    Map<int, dynamic> map = {};
    await for (final rows in db.watch("SELECT * FROM $table $where", tables: [table])) {
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
    where = where == null ? "" : " WHERE $where" ;
    await db.query("DELETE FROM `$table` $where");
  }

  @override
  Future<void> deleteId(int id, {String? where}) async {
    if(where == null){
      where = ' tr=\'$id\'';
    }
    else{
      where = " tr='$id' AND $where";
    }
    await delete(where: where);
  }

  @override
  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where" ;
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
    where = where == null ? "" : " WHERE $where" ;

    String updateClause = "";
    final List params = [];
    final values = map.keys;//.where((element) => !keys.contains(element));
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
