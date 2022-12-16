import 'package:erp_oshxona/Library/db/db.dart';

import 'transfer.dart';

class TransferTemp { 
  static Map<int, TransferTemp> obyektlar = {/*0: KBolim.bosh()..nomi = "Noma'lum"*/};
  static TransferTempService? service;

  int trHisobdan = 0;
  int trHisobga = 0;
  bool yoq = false;
  num foiz = 0; // Perevoddan ushlangan foiz
  num sum = 0; // o'tkazma xizmat summasi
  int bolim = 0;
  String izoh = '';

  // ignore: non_constant_identifier_names
  TransferTemp();

  TransferTemp.fromJson(Map json){
    trHisobdan = int.parse(json['trHisobdan'].toString());
    trHisobga = int.parse(json['trHisobga'].toString());
    yoq = (json['yoq'] == '1') ? true : false;
    foiz = num.parse(json['foiz'].toString());
    sum = num.parse(json['sum'].toString());
    bolim = int.parse(json['bolim'].toString());
    izoh = json['izoh'].toString();
  }

  Map<String, dynamic> toJson() =>
    {
      'trHisobdan': trHisobdan,
      'trHisobga': trHisobga,
      'yoq': yoq ? 1 : 0,
      'foiz': foiz,
      'sum': sum,
      'bolim': bolim,
      'izoh': izoh,
    };

  Future<void> getFromTrans(Transfer trans) async {
    trHisobdan = trans.trHisobdan;
    trHisobga = trans.trHisobga;
    foiz = trans.foiz;
    sum = trans.sum;
  }
}

class TransferTempService {
  final String prefix;
  final String table;
  
  TransferTempService({this.prefix = ''}) : table = "transfertemp";

  static String createTable = """
CREATE TABLE "transfertemp" (
	"trHisobdan"	INTEGER DEFAULT 0,
	"trHisobga"	INTEGER DEFAULT 0,
	"yoq"	INTEGER DEFAULT 0,
	"foiz"	NUMERIC DEFAULT 0,
	"sum"	NUMERIC DEFAULT 0,
	"bolim"	INTEGER DEFAULT 0,
	"izoh"	TEXT DEFAULT '',
	PRIMARY KEY("trHisobdan","trHisobga")
);
""";

  Future<List> select({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    List map = [];
    await for (final rows
        in db.watch("SELECT * FROM $table $where", tables: [table])) {
      for (final element in rows) {
        map.add(element);
      }
      return map;
    }
    return map;
  }

  Future<Map> selectOne(int trHisobdan, int trHisobga) async {
    Map row = await db.query(
      "SELECT * FROM $table WHERE trHisobdan=? AND trHisobga=?",
      params: [trHisobdan, trHisobga],
      //fromMap: (map) => {},
      singleResult: true,
    );
    return row;
  }
  
  Future<void> delete({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    await db.query("DELETE FROM `$table` $where");
  }
  
  Future<void> deleteId(int trHisobdan, int trHisobga, {String? where}) async {
    if (where == null) {
      where = ' trHisobdan=$trHisobdan AND trHisobga=$trHisobga';
    } else {
      where = where;
    }
    await delete(where: where);
  }

  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map row = await db.query("SELECT COUNT(*) FROM $table$where",
        //params: [table],
        //fromMap: (map) => {},
        singleResult: true);
    return int.parse(row['seq'].toString()) + 1;
  }
  
  Future<int> insert(Map map) async {

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
  
  Future<int> replace(Map map) async {
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
  
  Future<void> update(Map map, int trHisobdan, int trHisobga, {String? where}) async {
    where = where == null ? " trHisobdan=$trHisobdan AND trHisobga=$trHisobga" : " WHERE $where";

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
