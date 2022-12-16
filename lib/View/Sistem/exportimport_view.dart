import 'package:erp_oshxona/Library/db/db_init.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/transfer.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/View/Sistem/exportimport_cont.dart';
import 'package:erp_oshxona/Widget/restart_widget.dart';
import 'package:flutter/material.dart';

class ExportimportView extends StatefulWidget {
  const ExportimportView({Key? key}) : super(key: key);

  @override
  State<ExportimportView> createState() => _ExportimportViewState();
}

class _ExportimportViewState extends State<ExportimportView> {
  final ExportimportCont _cont = ExportimportCont();
  bool yuklanmoqda = false;
  dynamic jsonExport = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context, title: "Ma'lumotlar rezervi"),
        body: _cont.isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(_cont.loadingLabel),
                    ),
                  ],
                ),
              )
            : _body(context),
      ),
    );
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
    );
  }

  Widget _body(context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text("Eksport & Import",
              style: Theme.of(context).textTheme.headline4),
        ),
        Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(children: [
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                leading: const Icon(Icons.save),
                title: const Text("Barcha ma'lumotlar rezervini saqlash"),
                onTap: () async {
                  _cont.showLoading(text: "Ma'lumot tayyorlanmoqda...");
                  String dt =
                      "${dateFormat.format(DateTime.now())}_${hourMinuteFormat.format(DateTime.now())}";
                  await ExportimportCont.writeTofile(context,
                      filename:
                          "${ExportimportCont.filePrefix}backup_base_$dt.json",
                      data: (await ExportimportCont.olBazadanJSON()).codeUnits);
                  _cont.hideLoading();
                },
              ),
              const Padding(
                padding: EdgeInsets.all(7.0),
                child: Divider(thickness: 1.0),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                leading: const Icon(Icons.file_open),
                title: const Text("Fayldan ma'lumotlarni tiklash"),
                onTap: () => fayldanOqiDialog(context),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text("Excel faylga saqlash",
              style: Theme.of(context).textTheme.headline4),
        ),
        Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  leading: const Icon(Icons.table_view),
                  title: const Text("Kontaktlarni saqlash"),
                  onTap: () async {
                    _cont.showLoading(text: "Ma'lumot tayyorlanmoqda...");
                    String dt =
                        "${dateFormat.format(DateTime.now())}_${hourMinuteFormat.format(DateTime.now())}";
                    await ExportimportCont.writeTofile(context,
                        filename:
                            "${ExportimportCont.filePrefix}Kontaktlar_$dt.csv",
                        data: (await ExportimportCont.olKontaktCSVOl()));
                    _cont.hideLoading();
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  leading: const Icon(Icons.table_view),
                  title: const Text("Mablag' amaliyotlarini saqlash"),
                  onTap: () async {
                    _cont.showLoading(text: "Ma'lumot tayyorlanmoqda...");
                    String dt =
                        "${dateFormat.format(DateTime.now())}_${hourMinuteFormat.format(DateTime.now())}";
                    await ExportimportCont.writeTofile(context,
                        filename:
                            "${ExportimportCont.filePrefix}Amaliyotlar_$dt.csv",
                        data: (await ExportimportCont.olAmaliyotCSVOl()));
                    _cont.hideLoading();
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  leading: const Icon(Icons.table_view),
                  title: const Text("Ko'rsatilgan xizmatlarni saqlash"),
                  onTap: () async {
                    _cont.showLoading(text: "Ma'lumot tayyorlanmoqda...");
                    String dt =
                        "${dateFormat.format(DateTime.now())}_${hourMinuteFormat.format(DateTime.now())}";
                    await ExportimportCont.writeTofile(context,
                        filename:
                            "${ExportimportCont.filePrefix}Xizmatlar_$dt.csv",
                        data: (await ExportimportCont.olXizmatCSVOl()));
                    _cont.hideLoading();
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  leading: const Icon(Icons.table_view),
                  title: const Text("Mahsulot amaliyotlarini saqlash"),
                  onTap: () async {
                    _cont.showLoading(text: "Ma'lumot tayyorlanmoqda...");
                    String dt =
                        "${dateFormat.format(DateTime.now())}_${hourMinuteFormat.format(DateTime.now())}";
                    await ExportimportCont.writeTofile(context,
                        filename:
                            "${ExportimportCont.filePrefix}Mahsulotlar_$dt.csv",
                        data: (await ExportimportCont.olMahsulotCSVOl()));
                    _cont.hideLoading();
                  },
                ),
              ]),
            )),
        const Padding(
          padding: EdgeInsets.all(7.0),
          child: Divider(thickness: 1.0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4.0),
          child: Row(
            children: [
              Icon(
                Icons.warning,
                color: Theme.of(context).textTheme.headline4!.color,
                size: Theme.of(context).textTheme.headline4!.fontSize,
              ),
              const SizedBox(width: 7.0),
              Text("O'chirish", style: Theme.of(context).textTheme.headline4),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(children: [
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                leading: const Icon(Icons.delete),
                title:
                    const Text("Mablag' oldi-berdi amaliyotlarini o'chirish"),
                onTap: () => amaliyotOchirDialog(context),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                leading: const Icon(Icons.delete),
                title:
                    const Text("Ko'rsatilgan xizmat amaliyotlarini o'chirish"),
                onTap: () => orderOchirDialog(context),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                leading: const Icon(Icons.delete),
                title:
                    const Text("Maxsulot oldi-berdi amaliyotlarini o'chirish"),
                onTap: () => aMaxsulotOchirDialog(context),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                leading: const Icon(Icons.cleaning_services),
                title: const Text("Kontkatlar balansini 0 qilish"),
                onTap: () => balansOchirDialog(context),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                leading: const Icon(Icons.refresh),
                title:
                    const Text("Ilovani boshlang'ich ma'lumotlarini qaytarish"),
                onTap: () => boshlangichQaytarDialog(context),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 15),
        Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  leading:
                      const Icon(Icons.cleaning_services, color: Colors.red),
                  title: Text("Ilovadagi barcha ma'lumotlarni o'chirish",
                      style: TextStyle(color: Colors.red.shade600)),
                  onTap: () => bazaTozalaDialog(context),
                ),
              ]),
            )),
        const SizedBox(height: 60),
      ]),
    );
  }

  fayldanOqiDialog(context) {
    var contextParent = context;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
            "Ilovani barcha ma'lumotlari o'chirilib, fayldagi ma'lumotlar olinsinmi?"),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Yo'q, qolsin", style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _cont.showLoading(text: "Ma'lumot o'qib, bazaga yozilmoqda...");
              await ExportimportCont.readFromFile(context);
              _cont.hideLoading();
              
              await RestartWidget.restartApp(contextParent);
            },
            child: Text("Ha, tasdiqlayman", style: TextStyle(color: Colors.blue.shade700)),
          ),
        ],
      ),
    );
  }

  amaliyotOchirDialog(BuildContext context) {
    var contextParent = context;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
            "Ilovani barcha ma'lumotlari o'chiriladi va boshlang'ich holiga qaytadi. Rozimisiz?"),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q, qolsin"),
          ),
          TextButton(
            onPressed: () async {
              _cont.showLoading(text: "Ma'lumot tozalanmoqda...");
              await Amaliyot.service!.delete();
              await Transfer.service!.delete();
              await Hisob.service!.update({"balans": 0/*, "vaqtS": 0*/});
              
              await RestartWidget.restartApp(contextParent);
              _cont.hideLoading();
            },
            child: Text("Ha, o'chirilsin", style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  orderOchirDialog(BuildContext context) {
    var contextParent = context;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
            "Xizmat ko'rsatilgani haqidagi barcha qaydlar o'chiriladi, tasdiqlaysizmi?"),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q, qolsin"),
          ),
          TextButton(
            onPressed: () async {
              _cont.showLoading(text: "Ma'lumot tozalanmoqda...");
              await AOrder.service!.delete();
              
              await RestartWidget.restartApp(contextParent);
              _cont.hideLoading();
            },
            child: Text("Ha, o'chirilsin", style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  aMaxsulotOchirDialog(BuildContext context) {
    var contextParent = context;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
            "Maxsulot oldi-berdi haqidagi barcha qaydlar o'chiriladi, tasdiqlaysizmi?"),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q, qolsin"),
          ),
          TextButton(
            onPressed: () async {
              _cont.showLoading(text: "Ma'lumot tozalanmoqda...");
              await AMahsulot.service!.delete();
              
              await RestartWidget.restartApp(contextParent);
              _cont.hideLoading();
            },
            child: Text("Ha, o'chirilsin", style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  balansOchirDialog(BuildContext context) {
    var contextParent = context;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
            "Barcha kontaktlar qarz va haqi \"0\" (nol) qilinadi, tasdiqlaysizmi?"),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q, qolsin"),
          ),
          TextButton(
            onPressed: () async {
              _cont.showLoading(text: "Ma'lumot tozalanmoqda...");
              await Kont.service!.update({"balans": 0, "oyboBalans": 0, "vaqtS": toSecond(DateTime.now().millisecondsSinceEpoch)/*, "boshBalans": 0*/});
              
              await RestartWidget.restartApp(contextParent);
              _cont.hideLoading();
            },
            child: Text("Ha, o'chirilsin", style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  bazaTozalaDialog(BuildContext context) {
    var contextParent = context;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ilovani barcha ma'lumotlari o'chirilsinmi?"),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q, qolsin"),
          ),
          TextButton(
            onPressed: () async {
              _cont.showLoading(text: "Ma'lumot tozalanmoqda...");
              await ExportimportCont.bazaTozala(context);
              
              await RestartWidget.restartApp(contextParent);
              _cont.hideLoading();
            },
            child: Text("Ha, o'chirilsin", style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  boshlangichQaytarDialog(BuildContext context) {
    var contextParent = context;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
            "Ilovani barcha ma'lumotlari o'chiriladi va boshlang'ich holiga qaytadi. Rozimisiz?"),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q, qolsin"),
          ),
          TextButton(
            onPressed: () async {
              _cont.showLoading(text: "Ma'lumot tozalanmoqda...");
              await ExportimportCont.bazaTozala(context);
              _cont.showLoading(text: "Boshlang'ich holiga qaytmoqda...");
              await DatabaseInitializer.prepareDataUZ();
              await DatabaseInitializer.doQuery();
              
              RestartWidget.restartApp(contextParent);
              _cont.hideLoading();
            },
            child: Text("Ha, o'chirilsin", style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
