import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/m_brend.dart';
import 'package:erp_oshxona/Model/m_olchov.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';
import 'package:erp_oshxona/Model/system/turi.dart';

import 'm_bolim.dart';

class MTuri extends Tur{
  static final MTuri mahsulot = MTuri(1, "Taom");
  static final MTuri homAshyo = MTuri(2, "Masalliq");
  static final MTuri buyum = MTuri(3, "Buyum");

  static final Map<int, MTuri> obyektlar = {
    mahsulot.tr: mahsulot,
    homAshyo.tr: homAshyo,
    buyum.tr: buyum,
  };

  MTuri(super.tr, super.nomi, {super.ranggi, super.icon});
}

class Mahsulot {
  static Map<int, Mahsulot> obyektlar = {
    0: Mahsulot()..tr=0..trOlchov=0..trBolim=0..trBrend=0..nomi=""..rasm=""..malumot="",
  };

  static CrudService? service;
  
  int tr = 0;
  bool yoq = false;
  int turi = MTuri.mahsulot.tr;
  int tartib = 0;
  bool tanlangan = false;
  bool tarozimi = false;
  bool komplektmi = false;
  int	trBolim = 0;
  int	trOlchov = 0;
  int	trBrend = 0;
  int	vaqtS = 0;
  int	vaqt = 0;
  int	kasr = 0;
  num	minMiqdori = 0;
  int	trKotib = 0;
  String nomi = '';
  String rasm = "";
  String malumot = "";

  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);
  MTuri get mTuri => MTuri.obyektlar[turi]!;
  MOlchov get mOlchov => 
      MOlchov.obyektlar[trOlchov] ?? MOlchov.obyektlar[0] ?? MOlchov();
  MBrend get mBrend => 
      MBrend.obyektlar[trBrend] ?? MBrend.obyektlar[0] ?? MBrend();
  MBolim get mBolim => 
      MBolim.obyektlar[trBolim] ?? MBolim.obyektlar[0] ?? MBolim();
  MahQoldiq? get mQoldiq => MahQoldiq.obyektlar[tr];

  Mahsulot();

  Mahsulot.fromJson(Map<String, dynamic> json){
    tr = int.parse(json['tr'].toString());
    yoq = (json['yoq'] == 1) ? true : false;
    turi = int.parse(json['turi'].toString());
    tartib = int.parse(json['tartib'].toString());
    tanlangan = (json['tanlangan'] == 1) ? true : false;
    tarozimi = (json['tarozimi'] == 1) ? true : false;
    komplektmi = (json['komplektmi'] == 1) ? true : false;
    trOlchov = int.parse(json['trOlchov'].toString());
    trBolim = int.parse(json['trBolim'].toString());
    trBrend = int.parse(json['trBrend'].toString());
    vaqtS = int.parse(json['vaqtS'].toString());
    vaqt = int.parse(json['vaqt'].toString());
    kasr = int.parse(json['kasr'].toString());
    minMiqdori = num.parse(json['minMiqdori'].toString());
    trKotib = int.parse(json['trKotib'].toString());
    nomi = json['nomi'].toString();
    rasm = json['rasm'].toString();
    malumot = json['malumot'].toString();
  }
  
  Map<String, dynamic> toJson() =>
    {
      'tr': tr,
      'yoq': yoq ? 1 : 0,
      'tartib': tartib,
      'turi': turi,
      'tanlangan': tanlangan ? 1 : 0,
      'tarozimi': tarozimi ? 1 : 0,
      'komplektmi': komplektmi ? 1 : 0,
      'trOlchov': trOlchov,
      'trBolim': trBolim,
      'trBrend': trBrend,
      'vaqtS': vaqtS,
      'vaqt': vaqt,
      'kasr': kasr,
      'minMiqdori': minMiqdori,
      'trKotib': trKotib,
      'nomi': nomi,
      'rasm': rasm,
      'malumot': malumot,
    };

  Mahsulot.fromServer(Map<String, dynamic> json){
    tr = int.parse(json['tr'].toString());
    tartib = int.parse(json['tartib'].toString());
    tarozimi = (json['tarozimi'] == 1) ? true : false;
    minMiqdori = num.parse(json['min_miqdori'].toString());
    trOlchov = int.parse(json['tr_ob'].toString());
    trBolim = int.parse(json['tr_turi'].toString());
    trBrend = int.parse(json['tr_ich'].toString());
    vaqtS = int.parse(json['vaqt_ozg'].toString());
    nomi = json['nomi'].toString();
    rasm = json['rasm'].toString();
    malumot = json['malumot'].toString();
  }
  
  Map<String, dynamic> toServer() =>
    {
      'tr': tr,
      'tartib': tartib,
      'tarozimi': tarozimi ? 1 : 0,
      'min_miqdori': minMiqdori,
      'tr_ob': trOlchov,
      'tr_turi': trBolim,
      'tr_ich': trBrend,
      'nomi': nomi,
      'rasm': rasm,
      'malumot': malumot,
      'vaqt_ozg': vaqtS,
    };

  @override
    String toString() {
      return "$tr. $nomi " /*+ narxFormat.format(MahQoldiq.obyektlar[this.tr].sotnarxi)*/;
    }
}

class MahsulotService extends CrudService {
  @override
  MahsulotService({super.prefix = ''}) : super("mahsulot");

  static String createTable = """
CREATE TABLE "mahsulot" (
  "tr"	INTEGER NOT NULL DEFAULT 0,
	"yoq"	INTEGER NOT NULL DEFAULT 0,
	"turi"	INTEGER NOT NULL DEFAULT 0,
	"tartib"	INTEGER NOT NULL DEFAULT 0,
	"tanlangan"	INTEGER NOT NULL DEFAULT 0,
	"tarozimi"	INTEGER NOT NULL DEFAULT 0,
	"komplektmi"	INTEGER NOT NULL DEFAULT 0,
	"trBolim"	INTEGER NOT NULL DEFAULT 0,
	"trOlchov"	INTEGER NOT NULL DEFAULT 0,
	"trBrend"	INTEGER NOT NULL DEFAULT 0,
	"vaqtS"	INTEGER NOT NULL DEFAULT 0,
	"vaqt"	INTEGER NOT NULL DEFAULT 0,
	"kasr"	INTEGER NOT NULL DEFAULT 0,
	"minMiqdori"	NUMERIC NOT NULL DEFAULT 0,
	"trKotib"	INTEGER NOT NULL DEFAULT 0,
	"nomi"	TEXT NOT NULL DEFAULT '',
	"rasm"	TEXT NOT NULL DEFAULT '',
	"malumot"	TEXT NOT NULL DEFAULT '',
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
