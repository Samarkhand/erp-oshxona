import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mahal.dart';

class HujjatPartiya {
  static HujjatPartiyaService? service;
  static final Set<HujjatPartiya> obyektlar = {};
  static HujjatPartiya? ol(int tr) => obyektlar.firstWhere((element) => element.tr == tr);

  int turi = 1;
  int tr = 0;
  int trMahal = 0;
  int trChiqim = 0;
  int trHujjat = 0;
  int sana = 0;

  Hujjat get hujjat => Hujjat.ol(HujjatTur.kirimIch, trHujjat)!;
  Hujjat? get hujjatChiq => Hujjat.ol(HujjatTur.chiqimIch, trChiqim);
  Mahal get mahal => Mahal.obyektlar[trMahal]!;
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  
  HujjatPartiya();

  /// trHujjat id bo'yicha
  static HujjatPartiya id(int trHujjat) {
    return obyektlar.firstWhere((element) => element.trHujjat == trHujjat);
  }

  /*id(int id) async {
    var hujjat = Hujjat.obyektlar.firstWhere((element) => element.tr == id);
    Map json = await service!.selectId(hujjat.tr);
    fromJson(json as  Map<String, dynamic>);
  }*/

  HujjatPartiya.fromJson(Map<String, dynamic> json) {
    turi = json['turi'];
    tr = json['tr'];
    trMahal = int.parse(json['trMahal'].toString());
    trChiqim = int.parse(json['trChiqim'].toString());
    trHujjat = int.parse(json['trHujjat'].toString());
    sana = int.parse(json['sana'].toString()) * 1000;
  }

  fromJson(Map<String, dynamic> json) {
    turi = json['turi'];
    tr = json['tr'];
    trMahal = int.parse(json['trMahal'].toString());
    trChiqim = int.parse(json['trChiqim'].toString());
    trHujjat = int.parse(json['trHujjat'].toString());
    sana = int.parse(json['sana'].toString()) * 1000;
  }

  Map<String, dynamic> toJson() => {
        'turi': turi,
        'tr': tr,
        'trMahal': trMahal,
        'trChiqim': trChiqim,
        'trHujjat': trHujjat,
        'sana': toSecond(sana),
      };

  Future<void> delete() async {
    obyektlar.remove(this);
    await service!.deleteId(tr);
  }

  Future<void> insert() async {
    obyektlar.add(this);
  }

  Future<void> update() async {
    await service!.update(toJson(), where: " tr='$tr'");
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
  operator == (other) => other is HujjatPartiya && other.turi == turi && other.tr == tr;

  @override
  int get hashCode => turi.hashCode ^ tr.hashCode;
}

class HujjatPartiyaService {
  final String prefix;
  final String table = "hujjat_partiya";
  HujjatPartiyaService({this.prefix = ''});

  String get tableName => "'$prefix$table'";

  String get createTable => """
    CREATE TABLE $tableName (
      "tr"	INTEGER NOT NULL DEFAULT 0,
      "turi"	INTEGER NOT NULL DEFAULT 0,
      `trMahal` INTEGER NOT NULL DEFAULT 0,
      `trChiqim` INTEGER NOT NULL DEFAULT 0,
      `trHujjat` INTEGER NOT NULL DEFAULT 0,
      `sana` INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("tr")
    );
  """;

  Future<Set> select({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Set map = {};
    await for (final rows
        in db.watch("SELECT * FROM $tableName $where", tables: [tableName])) {
      for (final element in rows) {
        map.add(element);
      }
      return map;
    }
    return map;
  }

  Future<Map> selectId(int id, {String? where}) async {
    Map row = await db.query("SELECT * FROM $tableName WHERE tr = ?",
        params: [id],
        //fromMap: (map) => {},
        singleResult: true);
    return row;
  }

  Future<void> delete({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    await db.query("DELETE FROM $tableName $where");
  }

  Future<void> deleteId(int id, {String? where}) async {
    where = where == null ? " tr='$id'" : where;
    await delete(where: where);
  }

  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map row = await db.query("SELECT COUNT(*) FROM $tableName$where",
        //params: [tableName],
        //fromMap: (map) => {},
        singleResult: true);
    return row['seq'] + 1;
  }

  Future<int> insert(Map map) async {
    map['turi'] = (map['turi'] == 0) ? null : map['turi'];
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];

    var insertId = await db.insert(map as Map<String, dynamic>, "$tableName");
    return insertId;
  }

  Future<int> newId() async {
    int? tr = await db.query("SELECT MAX(tr) FROM $tableName",
        //params: [turi],
        //fromMap: (map) => {},
        singleResult: true);
        //if(row == null) throw Exception("Javob yo'q");
    return (tr ?? 0) + 1;
  }

  Future<int> replace(Map map) async {
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
    var sql = "REPLACE INTO $tableName ($cols) VALUES ($vals)";
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

    final String sql = "UPDATE $tableName SET $updateClause$where";
    await db.execute(sql, tables: [tableName], params: params);
    //await db.query(sql);
    //await db.update(map as Map<String, dynamic>, tableName, keys: []);
  }

  Future<int> newRaqam({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    int? tr = await db.query("SELECT MAX(raqami) FROM $tableName $where ORDER BY tr DESC LIMIT 0, 1",
        //params: [turi],
        //fromMap: (map) => {},
        singleResult: true);
        //if(row == null) throw Exception("Javob yo'q");
    return (tr ?? 0) + 1;
  }

}

