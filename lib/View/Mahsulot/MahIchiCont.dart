import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/m_olchov.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/Mahsulot/MahIchiView.dart';
import 'package:select_dialog/select_dialog.dart';

class MahIchiCont with Controller {
  late MahIchiView widget;
  late Mahsulot object;
  List amaliyotList = [];
  List amaliyotListT = [];
  late DateTime sanaD;
  late DateTime sanaG;

  late TextEditingController nomiController;
  TextEditingController dialogTextFieldCont = TextEditingController();
  //Map<int, TextEditingController> tarkibCont = {};
  final formKey = GlobalKey<FormState>();

  List<Mahsulot> homAshyoList = [];
  Set<MTarkib> tarkibList = {};

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    //Mahsulot.obyektlar = await Mahsulot.service!.getAll();
    object = widget.object;
    if (widget.yangimi) {
    } else if (widget.infomi) {
      sanaD = DateTime(today.year, today.month);
      sanaG = DateTime(today.year, today.month, today.day, 23, 59, 59);
      await loadItems();
      loadFromGlobal();
    }
    nomiController = TextEditingController(text: object.nomi);
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  saqlashTuriTanlash(context) {
    SelectDialog.showModal<MOlchov>(
      context,
      label: "Bo'lim tanlang",
      selectedValue: object.mOlchov,
      items:
          MOlchov.obyektlar.values.where((element) => element.tr != 0).toList(),
      onChange: (selected) {
        setState(() {
          object.trOlchov = selected.tr;
        });
        //Navigator.pop(context);
        //hisobTanlash(context);
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      showLoading(text: "Saqlanmoqda");
      object.nomi = nomiController.text;
      if (widget.yangimi) {
        var tr = await Mahsulot.service!.insert(object.toJson());
        Mahsulot.obyektlar[tr] = object..tr = tr;
      } else if (!widget.infomi) {
        await Mahsulot.service!
            .update(object.toJson(), where: " tr='${object.tr}'");
        //Mahsulot.obyektlar[object.tr] = object;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saqlandi"),
        duration: Duration(seconds: 1),
      ));
      hideLoading();
      Navigator.pop(context);
    }
  }

  add(Mahsulot mah, {num miqdori = 1}) async {
    var tarkib = MTarkib()..trMah=object.tr..trMahTarkib=mah.tr..miqdori=miqdori;
    tarkibList.add(tarkib);
    //tarkibCont[tarkib.trMahTarkib] = TextEditingController(text: tarkib.miqdori.toStringAsFixed(tarkib.mahsulot.kasr));
    setState(() => tarkibList);
    await tarkib.insert();
  }

  remove(MTarkib tarkib) async {
    tarkibList.remove(tarkib);
    setState(() => tarkibList);
    tarkib.delete();
  }

  validate(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Matn kiriting';
    }
    return null;
  }

  Future<void> loadItems() async {
    // amaliyot
    amaliyotList = [];
    amaliyotListT = [];
    
    if(object.turi == MTuri.mahsulot.tr) {
      await MTarkib.loadToGlobal(object.turi);
      /*if(MTarkib.obyektlar[object.turi] != null){
        for(var tarkib in MTarkib.obyektlar[object.turi]!){
          tarkibCont[tarkib.trMahTarkib] = TextEditingController(text: tarkib.miqdori.toStringAsFixed(tarkib.mahsulot.kasr));
        }
      }*/
    }
    /*
    (await Hujjat.service!.select(
            where:
                " hisob='${object.tr}' AND sana>=${toSecond(sanaD.millisecondsSinceEpoch)} AND sana<=${toSecond(sanaG.millisecondsSinceEpoch)} ORDER BY sana DESC"))
        .forEach((key, value) {
      var obj = Hujjat.fromJson(value);
      Hujjat.obyektlar.remove(value);
      amaliyotList.add(obj);
      amaliyotListT.add(obj);
    });*/
  }

  loadFromGlobal() {
    homAshyoList = Mahsulot.obyektlar.values.toList();
    homAshyoList.removeWhere((element) => element.tr == object.tr);
    if(object.turi == MTuri.mahsulot.tr) tarkibList = MTarkib.obyektlar[object.tr] ?? {};
    amaliyotList = amaliyotList.where((element) => element.hisob == object.tr).toList();
    amaliyotList.sort((a, b) => -a.sana.compareTo(b.sana));

    amaliyotListT = amaliyotListT.where((element) => element.hisob == object.tr).toList();
    amaliyotListT.sort((a, b) => -a.sana.compareTo(b.sana));
  }

  Future<void> sanaTanlashD(BuildContext context, StateSetter setState) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sanaD,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != sanaD) {
      setState(() => sanaD = picked);
    }
  }

  Future<void> sanaTanlashG(BuildContext context, StateSetter setState) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sanaG,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != sanaG) {
      setState(() => sanaG = picked);
    }
  }
}
