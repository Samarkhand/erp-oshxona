import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/system/turi.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class AmaliyotTur extends Tur {
  static final AmaliyotTur tushum =
      AmaliyotTur(1, "Tushum", amal: "+", ranggi: Colors.blue, icon: Icons.arrow_downward);
  static final AmaliyotTur chiqim =
      AmaliyotTur(2, "Chiqim", amal: "-", ranggi: Colors.red, icon: Icons.arrow_upward);
  static final AmaliyotTur qarzB =
      AmaliyotTur(3, "Qarz berish", amal: "-", ranggi: Colors.green, icon: Icons.arrow_upward);
  static final AmaliyotTur qarzO =
      AmaliyotTur(4, "Qarz olish", amal: "+", ranggi: Colors.orange, icon: Icons.arrow_downward);
  static final AmaliyotTur transP = AmaliyotTur(5, "Hisoblar aro o'tkazma +", amal: "+",
      ranggi: Colors.black87, icon: Icons.arrow_downward, editable: false);
  static final AmaliyotTur transM = AmaliyotTur(6, "Hisoblar aro o'tkazma -", amal: "-",
      ranggi: Colors.black87, icon: Icons.arrow_upward, editable: false);

  static final Map<int, AmaliyotTur> obyektlar = {
    tushum.tr: tushum,
    chiqim.tr: chiqim,
    qarzB.tr: qarzB,
    qarzO.tr: qarzO,
    transP.tr: transP,
    transM.tr: transM,
  };

  AmaliyotTur(super.tr, super.nomi, {required super.ranggi, required super.icon, this.amal = "", this.aBolimTr, this.editable = true});

  late final String amal;
  ABolim? aBolimTr;
  late final bool editable;

  @override
  String toString(){
    return tr.toString();
  }
}

/// faqat mablag' amaliyotlari
class Amaliyot {
  static Map<int, Amaliyot> obyektlar = {};
  static CrudService? service;

  int tr = 0;
  bool yoq = false;
  int turi = 0;
  int hisob = 0;
  int hujjat = 0;
  int bolim = 0;
  int kont = 0;
  num miqdor = 0;

  /// Rasmiy sana
  int sana = DateTime.now().millisecondsSinceEpoch;

  /// Kiritilgan aniq vaqti
  int vaqt = DateTime.now().millisecondsSinceEpoch;
  String izoh = '';
  String photo = "";
  int vaqtS = 0;

  late DateTime sanaDT;
  late DateTime vaqtDT;
  late DateTime vaqtSDT;

  Amaliyot() {
    sanaDT = DateTime.fromMillisecondsSinceEpoch((sana));
    vaqtDT = DateTime.fromMillisecondsSinceEpoch((vaqt));
    vaqtSDT = DateTime.fromMillisecondsSinceEpoch((vaqtS));
  }

  Amaliyot.bosh()
      : tr = 0,
        yoq = false,
        turi = 0,
        hisob = 0,
        hujjat = 0,
        bolim = 0,
        kont = 0,
        miqdor = 0,
        sana = DateTime.now().millisecondsSinceEpoch,
        vaqt = DateTime.now().millisecondsSinceEpoch,
        //this.vaqt = DateTime.fromMillisecondsSinceEpoch(int.parse(json['vaqt'].toString() + "000")),
        izoh = '',
        photo = '',
        vaqtS = 0 {
    sanaDT = DateTime.fromMillisecondsSinceEpoch(sana);
    vaqtDT = DateTime.fromMillisecondsSinceEpoch(vaqt);
    vaqtSDT = DateTime.fromMillisecondsSinceEpoch(vaqtS);
  }

  Amaliyot.fromJson(Map json)
      : tr = int.parse(json['tr'].toString()),
        yoq = (json['yoq'] == '1') ? true : false,
        turi = int.parse(json['turi'].toString()),
        hisob = int.parse(json['hisob'].toString()),
        hujjat = int.parse(json['hujjat'].toString()),
        bolim = int.parse(json['bolim'].toString()),
        kont = int.parse(json['kont'].toString()),
        miqdor = num.parse(json['miqdor'].toString()),
        sana = toMilliSecond(int.parse(json['sana'].toString())),
        vaqt = toMilliSecond(int.parse(json['vaqt'].toString())),
        //this.vaqt = DateTime.fromMillisecondsSinceEpoch(int.parse(json['vaqt'].toString() + "000")),
        izoh = json['izoh'].toString(),
        photo = json['photo'].toString(),
        vaqtS = int.parse(json['vaqtS'].toString()) {
    sanaDT = DateTime.fromMillisecondsSinceEpoch((sana));
    vaqtDT = DateTime.fromMillisecondsSinceEpoch((vaqt));
    vaqtSDT = DateTime.fromMillisecondsSinceEpoch((vaqtS));
  }

  Map<String, dynamic> toJson() => {
        'tr': tr,
        'yoq': yoq,
        'turi': turi,
        'hisob': hisob,
        'hujjat': hujjat,
        'bolim': bolim,
        'kont': kont,
        'miqdor': miqdor,
        'sana': toSecond(sana),
        'vaqt': toSecond(vaqt),
        'izoh': izoh,
        'photo': photo,
        'vaqtS': vaqtS,
      };

  Map<String, dynamic> toPost() => {
        'tr': tr,
        'yoq': yoq,
        'turi': turi,
        'hisob': hisob,
        'tr_hujjat': hujjat,
        'bolim': bolim,
        'kont': kont,
        'miqdori': miqdor,
        'sana': toSecond(sana),
        'vaqt': toSecond(vaqt),
        'izoh': izoh,
        //'photo': photo,
        //'vaqtS': vaqtS,
      };

  @override
  String toString() {
    return toJson().toString();
    //return "${this.tr}:${this.yoq}:${this.turi}:${this.tol_turi}:${this.maqsad}:${this.mijoz}:${this.vaqt}:${this.miqdor}:${this.izoh}:${this.photo}";
  }

  Future<void> delete() async {
    await service!.deleteId(tr);
    if (hisob != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[hisob]!;
      if (AmaliyotTur.tushum.tr == turi) {
        ushbuHisob.balansOzaytir(miqdor);
      } else if (AmaliyotTur.chiqim.tr == turi) {
        ushbuHisob.balansKopaytir(miqdor);
      } else if (AmaliyotTur.transP.tr == turi) {
        ushbuHisob.balansOzaytir(miqdor);
      } else if (AmaliyotTur.transM.tr == turi) {
        ushbuHisob.balansKopaytir(miqdor);
      }
    }
    if (kont != 0) {
      Kont ushbuKont = Kont.obyektlar[kont]!;
      if (AmaliyotTur.tushum.tr == turi) {
        ushbuKont.balansOzaytir(miqdor);
      } else if (AmaliyotTur.chiqim.tr == turi) {
        ushbuKont.balansKopaytir(miqdor);
      }
    }
    obyektlar.remove(tr);
  }

  Future<void> insert() async {
    vaqt = DateTime.now().millisecondsSinceEpoch;
    tr = await service!.insert(toJson());
    if (hisob != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[hisob]!;
      if (AmaliyotTur.tushum.tr == turi) {
        ushbuHisob.balansKopaytir(miqdor);
      } else if (AmaliyotTur.chiqim.tr == turi) {
        ushbuHisob.balansOzaytir(miqdor);
      } else if (AmaliyotTur.transP.tr == turi) {
        ushbuHisob.balansKopaytir(miqdor);
      } else if (AmaliyotTur.transM.tr == turi) {
        ushbuHisob.balansOzaytir(miqdor);
      }
    } else {
      throw Exception("Hisob tanlanmagan. Hisob tanlang");
    }
    
    if (kont != 0) {
      Kont ushbuKont = Kont.obyektlar[kont]!;
      if (AmaliyotTur.tushum.tr == turi) {
        ushbuKont.balansKopaytir(miqdor);
      } else if (AmaliyotTur.chiqim.tr == turi) {
        ushbuKont.balansOzaytir(miqdor);
      }
    }
    Amaliyot.obyektlar[tr] = this;
  }

  Future<void> update(Amaliyot eski, Amaliyot yangi) async {
    await service!.update(yangi.toJson(), where: " tr='${yangi.tr}'");
    
    if(hisob != eski.hisob) {
      Hisob eskiHisob = Hisob.obyektlar[eski.hisob]!;
      Hisob ushbuHisob = Hisob.obyektlar[hisob]!;
      if (AmaliyotTur.tushum.tr == turi) {
        ushbuHisob.balansKopaytir(miqdor);
        eskiHisob.balansOzaytir(eski.miqdor);
      } else if (AmaliyotTur.chiqim.tr == turi) {
        ushbuHisob.balansOzaytir(miqdor);
        eskiHisob.balansKopaytir(eski.miqdor);
      } else if (AmaliyotTur.transP.tr == turi) {
        ushbuHisob.balansKopaytir(miqdor);
        eskiHisob.balansOzaytir(eski.miqdor);
      } else if (AmaliyotTur.transM.tr == turi) {
        ushbuHisob.balansOzaytir(miqdor);
        eskiHisob.balansKopaytir(eski.miqdor);
      }
    }
    else{
      if (hisob != 0) {
        Hisob ushbuHisob = Hisob.obyektlar[hisob]!;
        if (AmaliyotTur.tushum.tr == turi) {
          ushbuHisob.balansKopaytir(miqdor);
          ushbuHisob.balansOzaytir(eski.miqdor);
        } else if (AmaliyotTur.chiqim.tr == turi) {
          ushbuHisob.balansOzaytir(miqdor);
          ushbuHisob.balansKopaytir(eski.miqdor);
        } else if (AmaliyotTur.transP.tr == turi) {
          ushbuHisob.balansKopaytir(miqdor);
          ushbuHisob.balansOzaytir(eski.miqdor);
        } else if (AmaliyotTur.transM.tr == turi) {
          ushbuHisob.balansOzaytir(miqdor);
          ushbuHisob.balansKopaytir(eski.miqdor);
        }
      } else {
        throw Exception("Hisob tanlanmagan. Hisob tanlang");
      }
    }
    
    if(eski.kont == 0) {
      if (kont != 0) {
        Kont ushbuKont = Kont.obyektlar[kont]!;
        if (AmaliyotTur.tushum.tr == turi) {
          ushbuKont.balansKopaytir(miqdor);
        } else if (AmaliyotTur.chiqim.tr == turi) {
          ushbuKont.balansOzaytir(miqdor);
        }
      }
    } else {
      if(kont == 0){
        Kont eskiKont = Kont.obyektlar[eski.kont]!;
        if (AmaliyotTur.tushum.tr == turi) {
          eskiKont.balansOzaytir(eski.miqdor);
        } else if (AmaliyotTur.chiqim.tr == turi) {
          eskiKont.balansKopaytir(eski.miqdor);
        }
      } else if(kont != eski.kont) {
        Kont eskiKont = Kont.obyektlar[eski.kont]!;
        Kont ushbuKont = Kont.obyektlar[kont]!;
        if (AmaliyotTur.tushum.tr == turi) {
          ushbuKont.balansKopaytir(miqdor);
          eskiKont.balansOzaytir(eski.miqdor);
        } else if (AmaliyotTur.chiqim.tr == turi) {
          ushbuKont.balansOzaytir(miqdor);
          eskiKont.balansKopaytir(eski.miqdor);
        }
      } else {
        if (kont != 0) {
          Kont ushbuKont = Kont.obyektlar[kont]!;
          if (AmaliyotTur.tushum.tr == turi) {
            ushbuKont.balansKopaytir(miqdor);
            ushbuKont.balansOzaytir(eski.miqdor);
          } else if (AmaliyotTur.chiqim.tr == turi) {
            ushbuKont.balansOzaytir(miqdor);
            ushbuKont.balansKopaytir(eski.miqdor);
          }
        }
      }
    }
  }
}

class AmaliyotService extends CrudService {
  @override
  AmaliyotService({super.prefix = ''}) : super("amaliyot");

  static String createTable = """
CREATE TABLE "amaliyot" (
	"tr"	INTEGER DEFAULT 0,
	"yoq"	INTEGER DEFAULT 0,
	"turi"	INTEGER DEFAULT 0,
	"hisob"	INTEGER DEFAULT 0,
	"hujjat"	INTEGER DEFAULT 0,
	"bolim"	INTEGER DEFAULT 0,
	"kont"	INTEGER DEFAULT 0,
	"miqdor"	NUMERIC DEFAULT 0,
	"sana"	INTEGER DEFAULT 0,
	"vaqt"	INTEGER DEFAULT 0,
	"izoh"	TEXT DEFAULT '',
	"photo"	TEXT DEFAULT '',
	"vaqtS"	INTEGER DEFAULT 0,
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
