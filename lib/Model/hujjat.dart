import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/kont.dart';

import 'hujjat_davomi.dart';

class Hujjat {
  static HujjatService? service;
  static final Set<Hujjat> obyektlar = {};
  /*{
    HujjatTur.kirim.tr: [],
    HujjatTur.kirimFil.tr: [],
    HujjatTur.qaytibOlish.tr: [],
    HujjatTur.qaytibBerish.tr: [],
    HujjatTur.zarar.tr: [],
    HujjatTur.kirimIch.tr: [],
    HujjatTur.chiqimIch.tr: [],
    HujjatTur.chiqimFil.tr: [],
    HujjatTur.chiqim.tr: [],
    HujjatTur.buyurtma.tr: [],
  };*/
  static List<Hujjat> get kirimlar => obyektlar.where((element) => element.turi == HujjatTur.kirim.tr).toList();
  static List<Hujjat> get kirimFillar => obyektlar.where((element) => element.turi == HujjatTur.kirimFil.tr).toList();
  static List<Hujjat> get qaytibOlishlar => obyektlar.where((element) => element.turi == HujjatTur.qaytibOlish.tr).toList();
  static List<Hujjat> get qaytibBerishlar => obyektlar.where((element) => element.turi == HujjatTur.qaytibBerish.tr).toList();
  static List<Hujjat> get zararlar => obyektlar.where((element) => element.turi == HujjatTur.zarar.tr).toList();
  static List<Hujjat> get kirimIchlar => obyektlar.where((element) => element.turi == HujjatTur.kirimIch.tr).toList();
  static List<Hujjat> get chiqimIchlar => obyektlar.where((element) => element.turi == HujjatTur.chiqimIch.tr).toList();
  static List<Hujjat> get chiqimFillar => obyektlar.where((element) => element.turi == HujjatTur.chiqimFil.tr).toList();
  static List<Hujjat> get chiqimlar => obyektlar.where((element) => element.turi == HujjatTur.chiqim.tr).toList();
  static List<Hujjat> get buyurtmalar => obyektlar.where((element) => element.turi == HujjatTur.buyurtma.tr).toList();
  static List<Hujjat> olList(HujjatTur turi) => obyektlar.where((element) => element.turi == turi.tr).toList();
  static Hujjat? ol(HujjatTur turi, int tr) => obyektlar.firstWhere((element) => element.turi == turi.tr && element.tr == tr);

  int turi = 0;
  int tr = 0;
  bool qulf =  false;
  bool yoq = false;
  int sts = 0;
  int sana = 0;
  int vaqtS = 0;
  int vaqt = 0;
  int trKont = 0;
  int trHujjat = 0;
  int raqami = 0;
  String hujjatRaqami = "";
  String izoh = "";

  HujjatTur get turiObj => HujjatTur.obyektlar[turi]!;
  HujjatSts get status => HujjatSts.obyektlar[turi]![sts]!;
  num get summa => summaNum ??  yaxlitla(summaOl());
  Kont? get kont => trKont == 0 ? null : Kont.obyektlar[trKont];
  Hujjat? get hujjat => trHujjat == 0 ? null : Hujjat.ol(turiObj, trHujjat);
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);
  
  Hujjat(this.turi);

  Hujjat.fromJson(Map<String, dynamic> json) {
    turi = json['turi'];
    tr = json['tr'];
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    sts = json['sts'];
    sana = int.parse(json['sana'].toString()) * 1000;
    vaqtS = int.parse(json['vaqtS'].toString()) * 1000;
    vaqt = int.parse(json['vaqt'].toString()) * 1000;
    trKont = json['trKont'];
    trHujjat = json['trHujjat'];
    raqami = json['raqami'];
    hujjatRaqami = json['hujjatRaqami'];
    izoh = json['izoh'];
  }

  Map<String, dynamic> toJson() => {
        'turi': turi,
        'tr': tr,
        'sts': sts,
        'qulf': qulf ? 1 : 0,
        'yoq': yoq ? 1 : 0,
        'sana': toSecond(sana),
        'vaqtS': toSecond(vaqtS),
        'vaqt': toSecond(vaqt),
        'trKont': trKont,
        'trHujjat': trHujjat,
        'raqami': raqami,
        'hujjatRaqami': hujjatRaqami,
        'izoh': izoh,
      };

  Future<void> delete() async {
    obyektlar.remove(this);
    await service!.deleteId(turi, tr);
  }

  Future<void> insert() async {
    tr = await service!.insert(toJson());
    obyektlar.add(this);
  }

  Future<void> update(Hujjat eski, Hujjat yangi) async {
    await service!.update(yangi.toJson(), where: " tr='${yangi.tr}'");
  }

  Future yangiRaqam() async {
    raqami = await service!.newRaqam(where: "turi=$turi");
  }

  num? summaNum = 0;
  num summaOl() {
    summaNum = 50000;
    return summaNum!;
  }

  @override
  String toString(){
    return tr.toString();
  }

  /*
  Future<void> summaHisobla() async {
    summa = 0;
    List obyektlar = await MahChiqimService.getAll(where: "turi=${turi} AND turi=${tr}");
    
    for (MahChiqim obj in obyektlar) {
      summa += obj.sotnarxiReal * obj.miqdori;
    }
  }
  */

  @override
  operator == (other) => other is Hujjat && other.turi == turi && other.tr == tr;

  @override
  int get hashCode => turi.hashCode ^ tr.hashCode;
}

class HujjatService {
  final String prefix;
  final String table = "hujjat";
  HujjatService({this.prefix = ''});

  String get tableName => prefix + table;

  String get createTable => """
    CREATE TABLE "$tableName" (
      "turi"	INTEGER NOT NULL DEFAULT 0,
      "tr"	INTEGER NOT NULL DEFAULT 0,
      "qulf" INTEGER NOT NULL DEFAULT 0,
      "yoq" INTEGER NOT NULL DEFAULT 0,
      "sts"	INTEGER NOT NULL DEFAULT 0,
      "sana"	INTEGER NOT NULL DEFAULT 0,
      "vaqtS"	INTEGER NOT NULL DEFAULT 0,
      "vaqt"	INTEGER NOT NULL DEFAULT 0,
      "trKont"	INTEGER NOT NULL DEFAULT 0,
      "trHujjat"	INTEGER NOT NULL DEFAULT 0,
      "raqami"	INTEGER NOT NULL DEFAULT 0,
      "hujjatRaqami"	TEXT NOT NULL DEFAULT '',
      "izoh"	TEXT NOT NULL DEFAULT '',
      PRIMARY KEY("turi","tr")
    );
  """;

  Future<Set> select({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Set map = {};
    await for (final rows
        in db.watch("SELECT * FROM '$tableName' $where", tables: [tableName])) {
      for (final element in rows) {
        map.add(element);
      }
      return map;
    }
    return map;
  }

  Future<Map> selectId(int turi, int id, {String? where}) async {
    Map row = await db.query("SELECT * FROM '$tableName' WHERE turi = ? AND tr = ?",
        params: [turi, id],
        //fromMap: (map) => {},
        singleResult: true);
    return row;
  }

  Future<void> delete({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    await db.query("DELETE FROM '$tableName' $where");
  }

  Future<void> deleteId(int turi, int id, {String? where}) async {
    where = where == null ? " turi = $turi AND tr='$id'" : where;
    await delete(where: where);
  }

  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map row = await db.query("SELECT COUNT(*) FROM '$tableName'$where",
        //params: [tableName],
        //fromMap: (map) => {},
        singleResult: true);
    return row['seq'] + 1;
  }

  Future<int> insert(Map map) async {
    map['turi'] = (map['turi'] == 0) ? null : map['turi'];
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];

    var insertId = await db.insert(map as Map<String, dynamic>, "'$tableName'");
    return insertId;
  }

  Future<int> newId(int turi) async {
    int? tr = await db.query("SELECT MAX(tr) FROM '$tableName' WHERE turi = ?",
        params: [turi],
        //fromMap: (map) => {},
        singleResult: true);
        //if(row == null) throw Exception("Javob yo'q");
    return (tr ?? 0) + 1;
  }

  Future<int> replace(Map map) async {
    map['turi'] = (map['turi'] == 0) ? null : map.remove('turi');
    map['tr'] = (map['tr'] == 0) ? null : map.remove('tr');

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
    var sql = "REPLACE INTO '$tableName' ($cols) VALUES ($vals)";
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

    final String sql = "UPDATE '$tableName' SET $updateClause$where";
    await db.execute(sql, tables: [tableName], params: params);
    //await db.query(sql);
    //await db.update(map as Map<String, dynamic>, tableName, keys: []);
  }

  Future<int> newRaqam({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    int? tr = await db.query("SELECT MAX(raqami) FROM '$tableName' $where ORDER BY tr DESC LIMIT 0, 1",
        //params: [turi],
        //fromMap: (map) => {},
        singleResult: true);
        //if(row == null) throw Exception("Javob yo'q");
    return (tr ?? 0) + 1;
  }

}

