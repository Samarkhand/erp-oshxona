import 'package:erp_oshxona/Library/api_num.dart';
import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';
import 'package:erp_oshxona/Model/m_brend.dart';
import 'package:erp_oshxona/Model/m_olchov.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/alert.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';

class MahQoldiq {
  static Map<int, MahQoldiq> obyektlar = {};
  static MahQoldiqService? service;

  int tr = 0;
  bool yoq = false;
  num qoldi = 0;
  num sotildi = 0;
  bool ozQoldimi = false;
  bool tarozimi = false;
  bool komplektmi = false;
  int trOlchov = 0;
  int trBolim = 0;
  int trBrend = 0;
  num tannarxi = 0;
  num sotnarxi = 0;
  num sumTannarxi = 0;
  int sana = 0;
  int vaqtS = 0;

  Mahsulot? get mahsulot => Mahsulot.obyektlar[tr];
  int get turi => mahsulot != null ? mahsulot!.turi : 1;
  MTuri get mTuri => MTuri.obyektlar[turi]!;
  MOlchov get mOlchov => MOlchov.obyektlar[trOlchov] ?? MOlchov.obyektlar[0]!;
  MBrend get mBrend => MBrend.obyektlar[trBrend] ?? MBrend.obyektlar[0]!;
  MBolim get mBolim => MBolim.obyektlar[trBolim] ?? MBolim.obyektlar[0]!;

  MahQoldiq();

  MahQoldiq.fromJson(Map<String, dynamic> json) {
    tr = int.parse(json['tr'].toString());
    qoldi = num.parse(json['qoldi'].toString());
    sotildi = num.parse(json['sotildi'].toString());
    ozQoldimi = (json['ozQoldimi'] == 1) ? true : false;
    tarozimi = (json['tarozimi'] == 1) ? true : false;
    //this.komplektmi = (json['komplektmi'] == 1) ? true : false;
    trOlchov = int.parse(json['trOlchov'].toString());
    trBolim = int.parse(json['trBolim'].toString());
    trBrend = int.parse(json['trBrend'].toString());
    tannarxi = num.parse(json['tannarxi'].toString());
    sotnarxi = num.parse(json['sotnarxi'].toString());
    sumTannarxi = num.parse(json['sumTannarxi'].toString());
    sana = int.parse(json['sana'].toString()) * 1000;
    vaqtS = int.parse(json['vaqtS'].toString()) * 1000;
  }

  Map<String, dynamic> toJson() => {
        'tr': tr,
        'qoldi': qoldi,
        'sotildi': sotildi,
        'ozQoldimi': ozQoldimi ? 1 : 0,
        'tarozimi': tarozimi ? 1 : 0,
        //'komplektmi': komplektmi ? 1 : 0,
        'trOlchov': trOlchov,
        'trBolim': trBolim,
        'trBrend': trBrend,
        'tannarxi': tannarxi,
        'sotnarxi': sotnarxi,
        'sumTannarxi': sumTannarxi,
        'sana': sana,
        'vaqtS': vaqtS,
      };

  MahQoldiq.fromServer(Map<String, dynamic> json) {
    tr = int.parse(json['tr_mah'].toString());
    qoldi = num.parse(json['qoldi'].toString());
    sotildi = num.parse(json['sotildi'].toString());
    ozQoldimi = (json['oz_qoldimi'] == 1) ? true : false;
    tarozimi = (json['tarozimi'] == 1) ? true : false;
    //this.komplektmi = (json['komplektmi'] == 1) ? true : false;
    trOlchov = int.parse(json['tr_ob'].toString());
    trBolim = int.parse(json['tr_turi'].toString());
    trBrend = int.parse(json['tr_ich'].toString());
    tannarxi = num.parse(json['tannarxi'].toString());
    sotnarxi = num.parse(json['sotnarxi'].toString());
    sumTannarxi = num.parse(json['sum_tannarxi'].toString());
    sana =
        json['sana'].toString() == "" ? 0 : int.parse(json['sana'].toString());
    vaqtS = int.parse(json['vaqt_ozg'].toString());
  }

  Map<String, dynamic> toServer() => {
        'tr_mah': tr,
        'qoldi': qoldi,
        'sotildi': sotildi,
        'oz_qoldimi': ozQoldimi ? 1 : 0,
        'tarozimi': tarozimi ? 1 : 0,
        //'komplektmi': komplektmi ? 1 : 0,
        'tr_ob': trOlchov,
        'tr_turi': trBolim,
        'tr_ich': trBrend,
        'tannarxi': tannarxi,
        'sotnarxi': sotnarxi,
        'sumTannarxi': sumTannarxi,
        'sana': sana,
        'vaqt_ozg': vaqtS,
      };

  Future<void> ozaytir([num miqdor = 1.0]) async {
    qoldi -= miqdor;
    await service!.update(
      {
        "qoldi": qoldi,
        "ozQoldimi": mahsulot!.minMiqdori >= qoldi ? 1 : 0,
        "vaqtS": DateTime.now().millisecondsSinceEpoch,
      },
      where: "tr=$tr",
    );
  }

  Future<void> kopaytir([num miqdor = 1.0]) async {
    qoldi += miqdor;
    await service!.update(
      {
        "qoldi": qoldi,
        "sotildi": sotildi,
        "ozQoldimi": mahsulot!.minMiqdori >= qoldi ? 1 : 0,
        "vaqtS": DateTime.now().millisecondsSinceEpoch,
      },
      where: "tr=$tr",
    );
  }

  static Future<Alert?> sotiladimi(Mahsulot mah, [num miqdori = 1.0]) async {
    if (mah.mQoldiq == null) {
      return (
        Alert(
          AlertType.error,
          "Mavjud emas",
          desc:
              "Maxsulot qoldig'i mavjud emas va ushbu bazada avval ham mavjud bo'lmagan",
        )
      );
    } else if (mah.mQoldiq!.qoldi <= 0) {
      return (
        Alert(AlertType.error, "Maxsulot qolmagan")
      );
    } else if (mah.mQoldiq!.qoldi < miqdori) {
      return (
        Alert(
          AlertType.warning,
          "Yetarli emas",
          desc:
              "Maxsulot qoldig'i yetarli emas. Mavjud qoldiq: ${mah.mQoldiq!.qoldi} ${mah.mOlchov.nomi}",
        )
      );
    }
    return null;
  }

  static Future<Map> ozaytirMah(Mahsulot mah, {num miqdor = 1.0}) async {
    try{
      await sotiladimi(mah, miqdor);
    }
    on ExceptionIW{
      rethrow;
    }

    //await MahQoldiq.obyektlar[mah.tr]!.ozaytir(miqdor);
    Map<String, dynamic> ret = {
      'qoldiqlar':<Map<String, dynamic>>[
        {
          'tr': mah.tr,
          'miqdori': miqdor,
          'tannarxi': MahQoldiq.obyektlar[mah.tr]!.tannarxi
        },
      ],
      'kirimlar':<Map<String, dynamic>>[

      ],
    };
    return ret;
  }

  static Future<int> kopaytirMah(Mahsulot mah,
      {num miqdor = 1.0, num tannarxi = 0, num sotnarxi = 0}) async {
    late MahQoldiq qoldiq;
    if (mah.mQoldiq == null) {
      qoldiq = MahQoldiq();
      qoldiq.tr = mah.tr;
      qoldiq.qoldi = miqdor;
      qoldiq.ozQoldimi = mah.minMiqdori >= qoldiq.qoldi ? true : false;
      qoldiq.tarozimi = mah.tarozimi;
      qoldiq.trOlchov = mah.trOlchov;
      qoldiq.trBolim = mah.trBolim;
      qoldiq.trBrend = mah.trBrend;
      qoldiq.tannarxi = tannarxi;
      qoldiq.sotnarxi = sotnarxi;
      qoldiq.sumTannarxi = (miqdor * sotnarxi).decimal(2);
      qoldiq.sana = today.millisecondsSinceEpoch;
      qoldiq.vaqtS = DateTime.now().millisecondsSinceEpoch;
      MahQoldiq.obyektlar[qoldiq.tr] = qoldiq;
      return await MahQoldiq.service!.insert(qoldiq.toJson());
    }
    qoldiq = mah.mQoldiq!;
    await qoldiq.kopaytir(miqdor);
    return qoldiq.tr;
  }
}

class MahQoldiqService extends CrudService {
  @override
  MahQoldiqService({super.prefix = ''}) : super("mah_qoldiq");

  String get tableName => "'$prefix$table'";

  String get createTable => """
CREATE TABLE $tableName (
  "tr"	INTEGER NOT NULL DEFAULT 0,
	"qoldi"	NUMERIC NOT NULL DEFAULT 0,
	"sotildi"	NUMERIC NOT NULL DEFAULT 0,
	"ozQoldimi"	INTEGER NOT NULL DEFAULT 0,
	"tarozimi"	INTEGER NOT NULL DEFAULT 0,
	"komplektmi"	INTEGER NOT NULL DEFAULT 0,
	"trOlchov"	INTEGER NOT NULL DEFAULT 0,
	"trBolim"	INTEGER NOT NULL DEFAULT 0,
	"trBrend"	INTEGER NOT NULL DEFAULT 0,
	"tannarxi"	NUMERIC NOT NULL DEFAULT 0,
	"sotnarxi"	NUMERIC NOT NULL DEFAULT 0,
	"sumTannarxi"	NUMERIC NOT NULL DEFAULT 0,
	"sana"	INTEGER NOT NULL DEFAULT 0,
	"vaqtS"	INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY("tr" AUTOINCREMENT)
);
  """;

  @override
  Future<Map> select({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map<int, dynamic> map = {};
    await for (final rows
        in db.watch("SELECT * FROM $tableName $where", tables: [tableName])) {
      for (final element in rows) {
        map[element['tr']] = element;
      }
      return map;
    }
    return map;
  }

  @override
  Future<Map> selectId(int id, {String? where}) async {
    Map row = await db.query("SELECT * FROM $tableName WHERE tr = ?",
        params: [id],
        //fromMap: (map) => {},
        singleResult: true);
    return row;
  }

  @override
  Future<void> delete({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    await db.query("DELETE FROM `$tableName` $where");
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
    Map row = await db.query("SELECT COUNT(*) FROM $tableName$where",
        //params: [tableName],
        //fromMap: (map) => {},
        singleResult: true);
    return int.parse(row['seq'].toString()) + 1;
  }

  @override
  Future<int> insert(Map map) async {
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];

    var insertId = await db.insert(map as Map<String, dynamic>, tableName);
    return insertId;
  }

  @override
  Future<int> newId() async {
    Map row = await db.query("SELECT * FROM sqlite_sequence WHERE name = ?",
        params: [tableName],
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
    var sql = "REPLACE INTO $tableName ($cols) VALUES ($vals)";
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

    final String sql = "UPDATE $tableName SET $updateClause$where";
    await db.execute(sql, tables: [tableName], params: params);
    //await db.query(sql);
    //await db.update(map as Map<String, dynamic>, tableName, keys: []);
  }
}
