import 'package:erp_oshxona/Library/db/db.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/turi.dart';

class HujjatTur extends Tur {
  static HujjatTur kirim = HujjatTur(1, "Kirim");
  static HujjatTur kirimFil = HujjatTur(2, "Filialdan Kirim"); 
  static HujjatTur qaytibOlish = HujjatTur(3, "Qaytib olish");
  static HujjatTur qaytibBerish = HujjatTur(4, "Qaytib berish");
  static HujjatTur zarar = HujjatTur(5, "Qoldiqdan o'chirish");
  static HujjatTur kirimIch = HujjatTur(6, "Ishlab chiqarildi");
  static HujjatTur chiqimIch = HujjatTur(7, "Ishlab chiqarish uchun harajat");
  static HujjatTur chiqimFil = HujjatTur(8, "Filialdan Kirim");
  static HujjatTur chiqim = HujjatTur(9, "Chiqim");
  static HujjatTur buyurtma = HujjatTur(11, "Buyurtma");

  static final Map<int, HujjatTur> obyektlar = {
    kirim.tr: kirim,
    kirimFil.tr: kirimFil,
    qaytibOlish.tr: qaytibOlish,
    qaytibBerish.tr: qaytibBerish,
    zarar.tr: zarar,
    kirimIch.tr: kirimIch,
    chiqimIch.tr: chiqimIch,
    chiqimFil.tr: chiqimFil,
    chiqim.tr: chiqim,
    buyurtma.tr: buyurtma,
  };

  HujjatTur(super.tr, super.nomi);

  get olHujjatlar => Hujjat.obyektlar.where((element) => element.turi == tr).toList();
}

class HujjatSts extends Tur {
  static HujjatSts faol = HujjatSts(1, "Faol");
  static HujjatSts bajarilgan = HujjatSts(2, "Bajarilgan");

  static final Map<int, HujjatSts> obyektlar = {
    faol.tr: faol,
    bajarilgan.tr: bajarilgan,
  };

  HujjatSts(super.tr, super.nomi);
}

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
  static Hujjat ol(HujjatTur turi, int tr) => obyektlar.firstWhere((element) => element.turi == turi.tr && element.tr == tr);

  int turi = 0;
  int tr = 0;
  bool qulf =  false;
  bool yoq = false;
  int sts = 0;
  int sana = 0;
  int vaqtS = 0;
  int vaqt = 0;
  int trKont = 0;
  int raqami = 0;
  String hujjatRaqami = "";
  String izoh = "";

  Kont? get kont => trKont == 0 ? null : Kont.obyektlar[trKont];
  num get summa => summaNum ??  yaxlitla(summaOl());
  DateTime get sanaDT => DateTime.fromMillisecondsSinceEpoch(sana);
  DateTime get vaqtDT => DateTime.fromMillisecondsSinceEpoch(vaqt);
  DateTime get vaqtSDT => DateTime.fromMillisecondsSinceEpoch(vaqtS);
  
  Hujjat();

  Hujjat.fromJson(Map<String, dynamic> json) {
    turi = int.parse(json['turi'].toString());
    tr = int.parse(json['tr'].toString());
    qulf = json['qulf'].toString() == "1" ? true : false;
    yoq = json['yoq'].toString() == "1" ? true : false;
    sts = int.parse(json['sts'].toString());
    sana = int.parse(json['sana'].toString());
    vaqtS = int.parse(json['vaqtS'].toString());
    vaqt = int.parse(json['vaqt'].toString());
    trKont = int.parse(json['trKont'].toString());
    raqami = int.parse(json['raqami'].toString());
    hujjatRaqami = json['hujjatRaqami'];
    izoh = json['izoh'];
  }

  Map<String, dynamic> toJson() => {
        'turi': turi,
        'tr': tr,
        'sts': sts,
        'qulf': qulf ? 1 : 0,
        'yoq': yoq ? 1 : 0,
        'sana': sana,
        'vaqtS': vaqtS,
        'vaqt': vaqt,
        'trKont': trKont,
        'raqami': raqami,
        'hujjatRaqami': hujjatRaqami,
        'izoh': izoh,
      };

  Future<Map<String, dynamic>> toPost() async {
    /*var chiqimlarList = await HujjatService.getAll(
        filter: Filter(where: "WHERE turi='${this.turi}' AND tr='${this.tr}'"));*/
    List<Map> chiqimlar = [];/*
    await chiqimlarList.forEach((obj) async {
      await chiqimlar.add(await obj.toPost());
    });*/
    return <String, dynamic>{
      'turi': turi,
      'tr': tr,
      'sts': sts,
      'qulf': qulf ? 1 : 0,
      'trKont': trKont,
      'sana': sana.toString().substring(0, 10),
      'hujjatRaqami': hujjatRaqami,
      'izoh': "$izoh ($tr-савдо)",
      'chiqimlar': [] + chiqimlar,
    };
  }

  Future<void> delete() async {
    await service!.deleteId(turi, tr);
    obyektlar.remove(this);
  }

  Future<void> insert() async {
    tr = await service!.insert(toJson());
    obyektlar.add(this);
  }

  Future<void> update(Hujjat eski, Hujjat yangi) async {
    await service!.update(yangi.toJson(), where: " tr='${yangi.tr}'");
  }

  @override
  String toString(){
    return tr.toString();
  }

  num? summaNum = 0;
  num summaOl() {
    summaNum = 50000;
    return summaNum!;
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
      "raqami"	INTEGER NOT NULL DEFAULT 0,
      "hujjatRaqami"	TEXT NOT NULL DEFAULT '',
      "izoh"	TEXT NOT NULL DEFAULT '',
      PRIMARY KEY("turi","tr")
    );
  """;

  Future<Map> select({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map<int, dynamic> map = {};
    await for (final rows
        in db.watch("SELECT * FROM '$tableName' $where", tables: [tableName])) {
      for (final element in rows) {
        map[element['tr']] = element;
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
    where ??= " WHERE $where";
    await db.query("DELETE FROM '$tableName' $where");
  }

  Future<void> deleteId(int turi, int id, {String? where}) async {
    where ??= " turi = $turi AND tr='$id'";
    await delete(where: where);
  }

  Future<int> count({String? where}) async {
    where = where == null ? "" : " WHERE $where";
    Map row = await db.query("SELECT COUNT(*) FROM '$tableName'$where",
        //params: [tableName],
        //fromMap: (map) => {},
        singleResult: true);
    return int.parse(row['seq'].toString()) + 1;
  }

  Future<int> insert(Map map) async {
    map['turi'] = (map['turi'] == 0) ? null : map['turi'];
    map['tr'] = (map['tr'] == 0) ? null : map['tr'];

    var insertId = await db.insert(map as Map<String, dynamic>, tableName);
    return insertId;
  }

  Future<int> newId(int turi) async {
    Map row = await db.query("SELECT tr FROM '$tableName' WHERE turi = ? ORDER BY tr DESC LIMIT 0, 1",
        params: [turi],
        //fromMap: (map) => {},
        singleResult: true);
    return row['tr'] + 1;
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
}

