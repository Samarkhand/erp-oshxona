import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

import 'TransferTemp.dart';
import 'hisob.dart';

class TransferTuri{
  
}

class Transfer {

  static CrudService? service;

  int tr = 0;
  bool yoq = false;
  int turi = 0;
  int trHisobdan = 0;
  int trHisobga = 0;
  int trAmalM = 0; // minus amaliyot tr
  int trAmalK = 0; // komissiya amaliyot tr
  int trAmalP = 0; // plus amaliyot tr
  num foiz = 0; // Perevoddan ushlangan foiz
  num sum = 0; // o'tkazma xizmat summasi
  num miqdor = 0; // o'tkazilgan mablag' miqdor
  int bolim = 0;
  int vaqt = 0;
  String izoh = '';

  DateTime vaqtDT;

  Transfer() : vaqtDT = DateTime.now();

  Transfer.fromJson(Map json) : vaqtDT = DateTime.now(){
    tr = int.parse(json['tr'].toString());
    yoq = (json['yoq'] == '1') ? true : false;
    trHisobdan = int.parse(json['trHisobdan'].toString());
    trHisobga = int.parse(json['trHisobga'].toString());
    trAmalM = int.parse(json['trAmalM'].toString());
    trAmalK = int.parse(json['trAmalK'].toString());
    trAmalP = int.parse(json['trAmalP'].toString());
    foiz = num.parse(json['foiz'].toString());
    sum = num.parse(json['sum'].toString());
    miqdor = num.parse(json['miqdor_kir'].toString());
    bolim = int.parse(json['bolim'].toString());
    vaqt = toMilliSecond(int.parse(json['vaqt'].toString()));
    izoh = json['izoh'].toString();
    
    vaqtDT = DateTime.fromMillisecondsSinceEpoch(vaqt);
  }

  Map<String, dynamic> toJson() =>
    {
      'tr': tr,
      'yoq': yoq ? 1 : 0,
      'trHisobdan': trHisobdan,
      'trHisobga': trHisobga,
      'trAmalM': trAmalM,
      'trAmalK': trAmalK,
      'trAmalP': trAmalP,
      'foiz': foiz,
      'sum': sum,
      'miqdor_kir': miqdor,
      'bolim': bolim,
      'vaqt': toSecond(vaqt),
      'izoh': izoh,
    };

  num getSumXizmat() {
    if(miqdor == 0 || (foiz == 0 && sum == 0)) return 0;
    num sumXizmat = (((foiz != 0) ? (foiz / 100) : 0) * miqdor) + sum;
    return sumXizmat;
  }

  Future<void> delete() async {
    //await TransferService.delete(this.tr);
    var sumXizmat = ((foiz / 100) * miqdor) + sum;

    Hisob hisobdan = Hisob.obyektlar[trHisobdan]!;
    hisobdan.balansOzaytir(miqdor + sumXizmat);
    
    Hisob hisobga  = Hisob.obyektlar[trHisobga]!;
    hisobga.balansOzaytir(miqdor);
  }

  Future<void> selectTemp(TransferTemp temp) async {
    trHisobdan = temp.trHisobdan;
    trHisobga = temp.trHisobga;
    foiz = temp.foiz;
    sum = temp.sum;
  }
}

class TransferService extends CrudService {
  @override
  TransferService({super.prefix = ''}) : super("transfer");

  static String createTable = """
CREATE TABLE "transfer" (
	"tr"	INTEGER DEFAULT 0,
	"yoq"	INTEGER DEFAULT 0,
	"turi"	INTEGER DEFAULT 0,
	"trHisobdan"	INTEGER DEFAULT 0,
	"trHisobga"	INTEGER DEFAULT 0,
	"trAmalM"	INTEGER DEFAULT 0,
	"trAmalK"	INTEGER DEFAULT 0,
	"trAmalP"	INTEGER DEFAULT 0,
	"trValyuta"	NUMERIC DEFAULT 0,
	"foiz"	NUMERIC DEFAULT 0,
	"sum"	NUMERIC DEFAULT 0,
	"miqdor_chiq"	NUMERIC DEFAULT 0,
	"miqdor_kir"	NUMERIC DEFAULT 0,
	"bolim"	INTEGER DEFAULT 0,
	"vaqt"	INTEGER DEFAULT 0,
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
