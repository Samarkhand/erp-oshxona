import 'package:erp_oshxona/Model/system/turi.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class AMahsulotTur extends Tur {
  AMahsulotTur(super.tr, super.nomi, {required super.ranggi, required super.icon});

  static final AMahsulotTur kirim = AMahsulotTur(1, "Kirim",
      ranggi: Colors.blue, icon: Icons.arrow_downward);
  static final AMahsulotTur vozvratKir = AMahsulotTur(2, "Kontaktdan qaytarish",
      ranggi: Colors.red, icon: Icons.arrow_downward);
  static final AMahsulotTur savdo = AMahsulotTur(3, "Savdo",
      ranggi: Colors.green, icon: Icons.arrow_upward);
  static final AMahsulotTur vozvratChiq = AMahsulotTur(4, "Kontaktga qaytarish",
      ranggi: Colors.orange, icon: Icons.arrow_upward);
  static final AMahsulotTur spisanya = AMahsulotTur(5, "Ro'yxatdan o'chirish",
      ranggi: Colors.red, icon: Icons.arrow_upward);

  static final AMahsulotTur qoldiq = AMahsulotTur(1, "Qoldiq",
      ranggi: Colors.purple, icon: Icons.storefront_rounded);

  static final Map<int, AMahsulotTur> obyektlar = {
    savdo.tr: savdo,
    vozvratChiq.tr: vozvratChiq,
    spisanya.tr: spisanya,
    vozvratKir.tr: vozvratKir,
    kirim.tr: kirim,
  };
}

/// faqat mablag' amaliyotlari //
class AMahsulot {
  static Map<int, AMahsulot> obyektlar = {};
  static CrudService? service;

  int tr;
  bool yoq;
  int turi;
  int hujjat;
  int bolim;
  int kont;
  num miqdor;

  /// Rasmiy sana
  int sana;

  /// Kiritilgan aniq vaqti
  int vaqt;
  String izoh;
  String photo = "";
  int vaqtS;

  late DateTime sanaDT;
  late DateTime vaqtDT;
  late DateTime vaqtSDT;

  AMahsulot({
    required this.tr,
    required this.yoq,
    required this.turi,
    required this.hujjat,
    required this.bolim,
    required this.kont,
    required this.miqdor,
    required this.sana,
    required this.vaqt,
    required this.izoh,
    required this.photo,
    required this.vaqtS,
  }) {
    sanaDT = DateTime.fromMillisecondsSinceEpoch((sana));
    vaqtDT = DateTime.fromMillisecondsSinceEpoch((vaqt));
    vaqtSDT = DateTime.fromMillisecondsSinceEpoch((vaqtS));
  }

  AMahsulot.bosh()
      : tr = 0,
        yoq = false,
        turi = 0,
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
    sanaDT = DateTime.fromMillisecondsSinceEpoch((sana));
    vaqtDT = DateTime.fromMillisecondsSinceEpoch((vaqt));
    vaqtSDT = DateTime.fromMillisecondsSinceEpoch((vaqtS));
  }

  AMahsulot.fromJson(Map json)
      : tr = int.parse(json['tr'].toString()),
        yoq = (json['yoq'] == '1') ? true : false,
        turi = int.parse(json['turi'].toString()),
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


  Future<void> delete() async {
    await service!.deleteId(tr);
    if (kont != 0) {
      Kont ushbuKont = Kont.obyektlar[kont]!;
      if (AMahsulotTur.kirim.tr == turi) {
        ushbuKont.balansOzaytir(miqdor);
      } else if (AMahsulotTur.vozvratKir.tr == turi) {
        ushbuKont.balansOzaytir(miqdor);
      } else if (AMahsulotTur.vozvratChiq.tr == turi) {
        ushbuKont.balansKopaytir(miqdor);
      } else if (AMahsulotTur.savdo.tr == turi) {
        ushbuKont.balansKopaytir(miqdor);
      }
    }
    obyektlar.remove(tr);
  }

  Future<void> insert() async {
    tr = await service!.insert(toJson());

    if (kont != 0) {
      Kont ushbuKont = Kont.obyektlar[kont]!;
      if (AMahsulotTur.kirim.tr == turi) {
        ushbuKont.balansKopaytir(miqdor);
      } else if (AMahsulotTur.vozvratKir.tr == turi) {
        ushbuKont.balansKopaytir(miqdor);
      } else if (AMahsulotTur.vozvratChiq.tr == turi) {
        ushbuKont.balansOzaytir(miqdor);
      } else if (AMahsulotTur.savdo.tr == turi) {
        ushbuKont.balansOzaytir(miqdor);
      }
    }
    AMahsulot.obyektlar[tr] = this;
  }

  Future<void> update(AMahsulot eski, AMahsulot yangi) async {
    await AMahsulot.service!.update(yangi.toJson(), where: " tr='${yangi.tr}'");
    
    if(eski.kont == 0) {
      if (kont != 0) {
        Kont ushbuKont = Kont.obyektlar[kont]!;
        if (AMahsulotTur.kirim.tr == turi) {
          ushbuKont.balansKopaytir(miqdor);
        } else if (AMahsulotTur.vozvratKir.tr == turi) {
          ushbuKont.balansKopaytir(miqdor);
        } else if (AMahsulotTur.savdo.tr == turi) {
          ushbuKont.balansOzaytir(miqdor);
        } else if (AMahsulotTur.vozvratChiq.tr == turi) {
          ushbuKont.balansOzaytir(miqdor);
        }
      }
    } else {
      if(kont == 0){
        Kont eskiKont = Kont.obyektlar[eski.kont]!;
        if (AMahsulotTur.kirim.tr == turi) {
          eskiKont.balansOzaytir(eski.miqdor);
        } else if (AMahsulotTur.vozvratKir.tr == turi) {
          eskiKont.balansOzaytir(eski.miqdor);
        } else if (AMahsulotTur.savdo.tr == turi) {
          eskiKont.balansKopaytir(eski.miqdor);
        } else if (AMahsulotTur.vozvratChiq.tr == turi) {
          eskiKont.balansKopaytir(eski.miqdor);
        }
      } else if(kont != eski.kont) {
        Kont eskiKont = Kont.obyektlar[eski.kont]!;
        Kont ushbuKont = Kont.obyektlar[kont]!;
        if (AMahsulotTur.kirim.tr == turi) {
          ushbuKont.balansKopaytir(miqdor);
          eskiKont.balansOzaytir(eski.miqdor);
        } else if (AMahsulotTur.vozvratKir.tr == turi) {
          ushbuKont.balansKopaytir(miqdor);
          eskiKont.balansOzaytir(eski.miqdor);
        } else if (AMahsulotTur.savdo.tr == turi) {
          ushbuKont.balansOzaytir(miqdor);
          eskiKont.balansKopaytir(eski.miqdor);
        } else if (AMahsulotTur.vozvratChiq.tr == turi) {
          ushbuKont.balansOzaytir(miqdor);
          eskiKont.balansKopaytir(eski.miqdor);
        }
      } else {
        if (kont != 0) {
          Kont ushbuKont = Kont.obyektlar[kont]!;
          if (AMahsulotTur.kirim.tr == turi) {
            ushbuKont.balansKopaytir(miqdor);
            ushbuKont.balansOzaytir(eski.miqdor);
          } else if (AMahsulotTur.vozvratKir.tr == turi) {
            ushbuKont.balansKopaytir(miqdor);
            ushbuKont.balansOzaytir(eski.miqdor);
          } else if (AMahsulotTur.savdo.tr == turi) {
            ushbuKont.balansOzaytir(miqdor);
            ushbuKont.balansKopaytir(eski.miqdor);
          } else if (AMahsulotTur.vozvratChiq.tr == turi) {
            ushbuKont.balansOzaytir(miqdor);
            ushbuKont.balansKopaytir(eski.miqdor);
          }
        }
      }
    }
  }

  @override
  String toString(){
    return tr.toString();
  }
}

class AMahsulotService extends CrudService {
  @override
  AMahsulotService({super.prefix = ''}) : super("aMahsulot");

  static String createTable = """
CREATE TABLE `aMahsulot` (
  `tr` INTEGER DEFAULT 0,
  `yoq` INTEGER DEFAULT 0,
  `turi` INTEGER DEFAULT 0,
  `hujjat` INTEGER DEFAULT 0,
  `bolim` INTEGER DEFAULT 0,
  `kont` INTEGER DEFAULT 0,
  `miqdor` INTEGER DEFAULT 0,
  `sana` INTEGER DEFAULT 0,
  `vaqt` INTEGER DEFAULT 0,
  `izoh` TEXT DEFAULT '',
  `photo` TEXT DEFAULT '',
  `vaqtS` INTEGER DEFAULT 0,
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
