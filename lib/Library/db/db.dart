import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/db/db_init.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/m_artikul.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';
import 'package:erp_oshxona/Model/m_brend.dart';
import 'package:erp_oshxona/Model/m_code.dart';
import 'package:erp_oshxona/Model/m_olchov.dart';
import 'package:erp_oshxona/Model/mah_buyurtma.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahal.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/smena.dart';
import 'package:erp_oshxona/Model/system/crudHelper.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_wrapper/sqlite_wrapper.dart';

SQLiteWrapper db = SQLiteWrapper();

class DatabaseHelper {
  static const int version = 1;
  static final DatabaseHelper _singleton = DatabaseHelper._internal();
  factory DatabaseHelper() {
    return _singleton;
  }

  DatabaseHelper._internal();

  Future<DatabaseInfo> initDB(dbPath, {inMemory = false}) async {
    return await db.openDB(
      dbPath,
      version: version,
      onCreate: () => _create(),
      onUpgrade: (from, to) => _upgrade(from, to),
    );
    // Print where the database is stored
    //logConsole("Database path: ${dbInfo.path}");
  }

  _create() async {
    String sql = '';
    /*
    sql += AmaliyotService.createTable;
    sql += AMahsulotService.createTable;
    sql += AOrderService.createTable;
    sql += HisobService.createTable;
    sql += ABolimService.createTable;
    sql += TransferService.createTable;
    sql += TransferTempService.createTable;
    */
    sql += KBolimService.createTable;
    sql += KontService.createTable;
    sql += MOlchovService.createTable;
    sql += MBolimService.createTable;
    sql += MBrendService.createTable;
    sql += MahsulotService.createTable;
    sql += MCodeService.createTable;
    sql += MArtikulService.createTable;
    sql += MahalService.createTable;
    sql += SmenaService.createTable;
    sql += MArtikulService.createTable;
    // 
    sql += Hujjat.service!.createTable;
    sql += HujjatPartiya.service!.createTable;
    sql += MahQoldiq.service!.createTable;
    sql += MahKirim.service!.createTable;
    sql += MahChiqim.service!.createTable;
    sql += MahBuyurtma.service!.createTable;
    await db.execute(sql);

    //await Sozlash.initValues();
    /*
    await DatabaseInitializer.prepareDataUZ();
    await DatabaseInitializer.doQuery();
    */
  }

  _upgrade(int from, int to) async {
    logConsole("Upgraded database from: $from to: $to");

    if (from == 1) {
      from = 2;
      await _upgradeTo2();
    }
    if (from == 2) {
      from = 3;
      await _upgradeTo3();
    }
  }

  _upgradeTo3() async {
    List abolim = [];
    int trABolim = await ABolim.service!.newId();
    int tartib = 0;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "O'tkazma +"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 17, 17, 17));
    await Sozlash.box.put("abolimTransP", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "O'tkazma -"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 46, 45, 45));
    await Sozlash.box.put("abolimTransM", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "Qarz berish"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 177, 65, 21));
    await Sozlash.box.put("abolimQarzB", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "Qarz olish"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 224, 228, 21));
    await Sozlash.box.put("abolimQarzO", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "Mahsulot uchun"
      ..icon = Icons.production_quantity_limits
      ..color = const Color.fromARGB(255, 224, 228, 21));
    await Sozlash.box.put("abolimMahUchun", trABolim);
    trABolim++;
    tartib++;
    abolim.add(ABolim()
      ..tr = trABolim
      ..turi = ABolimTur.tizim.tr
      ..tartib = tartib
      ..nomi = "Komissiya to'lovlari"
      ..icon = Icons.money
      ..color = const Color.fromARGB(255, 177, 21, 156));
    await Sozlash.box.put("abolimTrKomissiya", trABolim);
    for (var obj in abolim) {
      await ABolim.service!.insert(obj.toJson());
    }
    await Amaliyot.service!.update({"bolim": Sozlash.abolimMahUchun.tr}, where: "bolim=${Sozlash.abolimTrMahKirChiq.tr} OR bolim=${Sozlash.abolimTrMahSvdTush.tr}");
    await ABolim.service!.delete(where: "tr=${Sozlash.abolimTrMahKirChiq.tr}");
    await ABolim.service!.delete(where: "tr=${Sozlash.abolimTrMahSvdTush.tr}");
    await Sozlash.box.delete("abolimTrMahKirChiq");
    await Sozlash.box.delete("abolimTrMahSvdTush");
  }

  _upgradeTo2() async {
    final List<String> myQuery = [];
    // yangi ustun qo'shildi
    db.execute("""
      ALTER TABLE ${Kont.service!.table} ADD COLUMN "vaqtS" INTEGER DEFAULT 0;
    """);
    db.execute("""
      ALTER TABLE ${Kont.service!.table} ADD COLUMN "trShaxs" INTEGER DEFAULT 0;
    """);
    db.execute("""
      ALTER TABLE ${Kont.service!.table} ADD COLUMN "davKod" TEXT DEFAULT "";
    """);
    db.execute("""
      ALTER TABLE ${Kont.service!.table} ADD COLUMN "telKod" TEXT DEFAULT "";
    """);
    db.execute("""
      ALTER TABLE ${Kont.service!.table} ADD COLUMN "tel" TEXT DEFAULT "";
    """);
    _tartibiniYangila(Kont.service!, KontService.createTable, myQuery);
  }

  Future<List<String>> _tartibiniYangila(CrudService service, String createTable, List<String> myQuery) async {
    Map zapas = await service.select();
    // Eskini nomini o'zgartirdim
    db.execute("""
      ALTER TABLE ${service.table} RENAME TO ${service.table}_old;
    """);
    // yangi jadval
    db.execute(createTable);
    // yangi jadvalga eski 
    /*
    db.execute("""INSERT INTO ${service.table}
      SELECT *
      FROM ${{service.table}}_old;""");*/

    for (Map element in zapas.values) {
      await service.insert(Kont.fromJson(element).toJson());
    }
    
    // eski jadval o'chirib yuborilsin
    db.execute("""
      DROP TABLE ${service.table}_old;
    """);
    return myQuery;
  }

}



/*
  /// Return a list of all todos
  Stream getTodos() {
    return SQLiteWrapper()
        .watch("SELECT * FROM todos", tables: ["todos"], fromMap: Todo.fromMap);
  }

  Stream<Map<String, dynamic>> getTodoCount() {
    return Stream.castFrom(SQLiteWrapper().watch("""
        SELECT SUM(done) as done, sum(todo) as todo FROM (
        SELECT COUNT(*) as done,  0 as todo FROM todos where done = 1
        UNION
        SELECT 0 as done,  COUNT(*) as todo FROM todos where done = 0
        ) as todos 
      """, tables: ["todos"], singleResult: true));
  }

  /// Add the new to-do Item
  void addNewTodo(String title) async {
    await SQLiteWrapper().insert(Todo(title: title).toMap(), "todos");
  }

  void toggleDone(Todo todo) async {
    todo.done = !todo.done;
    await SQLiteWrapper().update(todo.toMap(), "todos", keys: ["id"]);
  }

  void deleteTodo(Todo todo) async {
    await SQLiteWrapper().delete(todo.toMap(), "todos", keys: ["id"]);
  }*/

/*
import 'dart:convert';

class Todo {
  int? id;
  String title;
  bool done = false;

  Todo({required this.title});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'done': done,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(title: map['title'] ?? '')
      ..done = (map['done'] ?? 0) == 1 ? true : false
      ..id = (map['id']);
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));
}
 */
    /*
    StreamBuilder(
      stream: stream,
      initialData: const [],
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final List<ABolim> aBolims = List<ABolim>.from(snapshot.data);
        return Expanded(
            //child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: aBolims.length,
            itemBuilder: (BuildContext context, int index) {
              final ABolim aBolim = aBolims[index];
              return aBolimItem(ABolim);
            },
            //  ),
          ),
        ));
      },
    );*/
