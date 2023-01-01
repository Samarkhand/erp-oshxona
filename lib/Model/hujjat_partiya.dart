import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';

class HujjatPartiya {
  static HujjatPartiyaService? service;
  static final Set<HujjatPartiya> obyektlar = {};
  static HujjatPartiya? ol(int tr) => obyektlar.firstWhere((element) => element.tr == tr);

  int turi = 0;
  int tr = 0;
  int trMahal = 0;
  int trChiqim = 0;
  int trKirim = 0;
  int trHujjat = 0;

  Hujjat? get hujjat => trHujjat == 0 ? null : Hujjat.ol(HujjatTur.kirimIch, trHujjat);
  
  HujjatPartiya();

  HujjatPartiya.fromJson(Map<String, dynamic> json) {
    turi = json['turi'];
    tr = json['tr'];
    trMahal = int.parse(json['trMahal'].toString());
    trChiqim = int.parse(json['trChiqim'].toString());
    trKirim = int.parse(json['trKirim'].toString());
    trHujjat = int.parse(json['trHujjat'].toString());
  }

  Map<String, dynamic> toJson() => {
        'turi': turi,
        'tr': tr,
        'trMahal': trMahal,
        'trChiqim': trChiqim,
        'trKirim': trKirim,
        'trHujjat': trHujjat,
      };

  Future<void> delete() async {
    obyektlar.remove(this);
    await service!.deleteId(turi, tr);
  }

  Future<void> insert() async {
    tr = await service!.insert(toJson());
    obyektlar.add(this);
  }

  Future<void> update(HujjatPartiya eski, HujjatPartiya yangi) async {
    await service!.update(yangi.toJson(), where: " tr='${yangi.tr}'");
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
      "turi"	INTEGER NOT NULL DEFAULT 0,
      "tr"	INTEGER NOT NULL DEFAULT 0,
      `trMahal` INTEGER NOT NULL DEFAULT 0,
      `trKirim` INTEGER NOT NULL DEFAULT 0,
      `trChiqim` INTEGER NOT NULL DEFAULT 0,
      `trHujjat` INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("turi", "tr")
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

