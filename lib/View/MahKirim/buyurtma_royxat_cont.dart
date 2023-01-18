import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mah_buyurtma.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/alert.dart';
import 'package:erp_oshxona/View/MahKirim/buyurtma_royxat_view.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:http/http.dart';

class BuyurtmaRoyxatCont with Controller {
  late BuyurtmaRoyxatView widget;
  List objectList = [];

  late final Hujjat hujjat;
  late final Hujjat kirimHujjat;

  late DateTime sanaD;
  late DateTime sanaG;

  List<Mahsulot> mahsulotList = [];
  List<MahBuyurtma> buyurtmaList = [];
  List<MahKirim> kirimList = [];

  Map<int, TextEditingController> buyurtmaCont = {};

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async 
  {
    this.setState = setState;
    this.widget = widget;
    this.context = context;

    hujjat = widget.hujjat;
    showLoading(text: "Yuklanmoqda...");
    await loadItems();
    await loadFromGlobal();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> delete(KBolim element) async {
    bool kontBormi = false;
    (await Kont.service!.select(where: " bolim='${element.tr}' LIMIT 0, 1")).forEach((key, value) {
      kontBormi = true;
    });
    
    if(kontBormi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirish mumkin emas. Oldin ishlatilgan"),
        duration: Duration(seconds: 5),
      ));
    } else{
      await KBolim.service!.deleteId(element.tr);
      KBolim.obyektlar.remove(element.tr);
      setState(() {
        objectList.remove(element);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O'chirib yuborildi"),
        duration: Duration(seconds: 5),
      ));
    }
  }
  
  Future<void> loadItems() async {
    if(hujjat.sts == HujjatSts.tasdiqKutBrtm.tr){
      await MahKirim.service!.select(where: "trHujjat=${hujjat.tr} ORDER BY tr DESC").then((values) { 
        for (var value in values.values) {
          var kirim = MahKirim.fromJson(value);
          MahKirim.obyektlar[kirim.tr] = kirim;
          //buyurtmaCont[kirim.tr] = TextEditingController(text: kirim.miqdori.toStringAsFixed(kirim.mahsulot.kasr));
          kirimList.add(kirim);
        }
      });
    }
    else {
      await MahBuyurtma.service!.select(where: "trHujjat=${hujjat.tr} ORDER BY tr DESC").then((values) { 
        for (var value in values) {
          var buyurtma = MahBuyurtma.fromJson(value);
          MahBuyurtma.obyektlar.add(buyurtma);
          buyurtmaCont[buyurtma.tr] = TextEditingController(text: buyurtma.miqdori.toStringAsFixed(buyurtma.mahsulot.kasr));
        }
      });
    }
  }

  loadFromGlobal(){
    if(hujjat.sts == HujjatSts.tasdiqKutBrtm.tr){
      kirimHujjat = Hujjat.ol(HujjatTur.kirimFil, hujjat.trHujjat)!;
    }
    buyurtmaList = MahBuyurtma.obyektlar.where((element) => element.trHujjat == hujjat.tr).toList();
    buyurtmaList.sort(
      // Comparison function not necessary here, but shown for demonstrative purposes 
      (a, b) => -a.tr.compareTo(b.tr), 
    );
    mahsulotList = Mahsulot.obyektlar.values.where((element) => element.turi == MTuri.homAshyo.tr).toList();
    mahsulotList.sort((a, b) => -b.nomi.compareTo(a.nomi));
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

  buyurtmaJonatish() async {
    showLoading(text: "Buyurtma jo'natilmoqda");
    if (await (Connectivity().checkConnectivity()) == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      hideLoading();
      return;
    }
    var url = InwareServer.urlBuyurtma;
    Map<String, String> headers = {"Auth": Sozlash.token};
    Map body = _brtmJonatganiMalumot();
    Response? reply = await apiPost(url, headers: headers, jsonMap: body);
    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("REQUEST body: $body");
    logConsole("RESPONSE head: ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if (reply.statusCode == 200 && result != null) {
      final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);
      setState((){ 
        hujjat.qulf = true;
        hujjat.sts = HujjatSts.jonatilganBrtm.tr;
      });
      await Hujjat.service!.update({
        'qulf': hujjat.qulf ? 1 : 0,
        'sts': hujjat.sts,
        'vaqtS': vaqts,
      }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");
    }
    if (result?['alert'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result!['alert']['title']),
        duration: const Duration(seconds: 5),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
    else if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
    hideLoading();
  }

  buyurtmaTekshirish() async {
    showLoading(text: "Buyurtma tekshirilmoqda");
    if (await (Connectivity().checkConnectivity()) == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      hideLoading();
      return;
    }
    var url = "${InwareServer.urlBuyurtma}&checkStatus=${hujjat.tr}";
    Map<String, String> headers = {"Auth": Sozlash.token};
    Map body = _brtmJonatganiMalumot();
    Response? reply = await apiPost(url, headers: headers, jsonMap: body);
    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("REQUEST body: $body");
    logConsole("RESPONSE head: ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if (reply.statusCode == 200 && result != null) {
      final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);
      setState((){
        hujjat.qulf = result['hujjat']['qulf'] == 1;
        hujjat.sts = result['hujjat']['sts'];
      });
      if(hujjat.sts == HujjatSts.tasdiqKutBrtm.tr){
        // agar kirimFil hujjat hosil qilingan bo'lmasa - qilinsin.
        if(hujjat.trHujjat == 0){
          kirimHujjat = Hujjat(HujjatTur.kirimFil.tr);
          kirimHujjat.tr = await Hujjat.service!.newId(kirimHujjat.turi);
          kirimHujjat.sana = hujjat.sana;
          kirimHujjat.vaqt = DateTime.now().millisecondsSinceEpoch;
          kirimHujjat.vaqtS = kirimHujjat.vaqt;
          kirimHujjat.trHujjat = hujjat.tr;
          hujjat.trHujjat = kirimHujjat.tr;
          await Hujjat.service!.insert(kirimHujjat.toJson());
        }
        if(hujjat.trHujjat != 0){
          for(Map buyurtmaData in result['mahsulotlar']){
            var brtm = buyurtmaList.firstWhere((element) => element.tr == int.parse(buyurtmaData['tr'].toString()), orElse: () => MahBuyurtma.fromJson(buyurtmaData as Map<String, dynamic>));
            if(brtm.yoq) continue;
            var kirim = MahKirim.fromBrtm(brtm);
            kirim.trHujjat = kirimHujjat.tr;
            kirim.turi = MahKirimTur.kirimFil.tr;
            kirim.sana = hujjat.sana;
            kirim.vaqt = DateTime.now().millisecondsSinceEpoch;
            kirim.vaqtS = kirim.vaqt;
            await MahKirim.service!.insert(kirim.toJson());
          }
        }
      }
      await Hujjat.service!.update({
        'qulf': hujjat.qulf ? 1 : 0,
        'sts': hujjat.sts,
        'trHujjat': hujjat.trHujjat,
        'vaqtS': vaqts,
      }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");
    }
    if (result?['alert'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result!['alert']['title']),
        duration: const Duration(seconds: 5),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
    else if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
    hideLoading();
  }

  buyurtmaTugallash() async {
    showLoading(text: "Buyurtma tugallanmoqda");
    if (await (Connectivity().checkConnectivity()) == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      hideLoading();
      return;
    }
    var url = "${InwareServer.urlBuyurtma}&complete=${hujjat.tr}";
    Map<String, String> headers = {"Auth": Sozlash.token};
    Response? reply = await apiGet(url, headers: headers);
    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("RESPONSE head: ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if (reply.statusCode == 200 && result != null) {
      final int vaqts = toSecond(DateTime.now().millisecondsSinceEpoch);
      setState((){
        hujjat.qulf = result['hujjat']['qulf'] == 1;
        hujjat.sts = result['hujjat']['sts'];
      });
      await Hujjat.service!.update({
        'qulf': hujjat.qulf ? 1 : 0,
        'sts': hujjat.sts,
        'vaqtS': vaqts,
      }, where: "turi='${hujjat.turi}' AND tr='${hujjat.tr}'");
      if(hujjat.sts == HujjatSts.tasdiqKutBrtm.tr){
        // agar kirimFil hujjat hosil qilingan bo'lmasa - qilinsin.
        //Hujjat? kirimHujjat = Hujjat.ol(HujjatTur.kirimFil, hujjat.trHujjat);
        for(var kirim in kirimList){
          kirim.qulf = true;
          kirim.vaqtS = vaqts;
          kirim.qoldi = kirim.miqdori;
          kirim.tannarxiReal = kirim.tannarxi;
          kirim.trQoldiq = await MahQoldiq.kopaytirMah(kirim.mahsulot, miqdor: kirim.miqdori, tannarxi: kirim.tannarxiReal);

          await MahKirim.service!.update({
            'qulf': 1,
            'qoldi': kirim.qoldi,
            'tannarxiReal': kirim.tannarxiReal,
            'trQoldiq': kirim.trQoldiq,
            'vaqtS': vaqts,
          }, where: "tr='${kirim.tr}'");
        }
      }
    }
    if (result?['alert'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result!['alert']['title']),
        duration: const Duration(seconds: 5),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
    else if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Serverdan (${reply.statusCode}) hato javob keldi"),
        duration: const Duration(seconds: 2),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
    hideLoading();
  }

  addToList(Mahsulot buyurtma) async {
    String? value = await inputDialog(context, "");
    if(value != null){
      num miqdori = num.tryParse(value) ?? 0;
      add(buyurtma, miqdori: miqdori);
    }
  }

  add(Mahsulot mah, {num miqdori = 1}) async {
    var buyurtma = MahBuyurtma()..trHujjat=hujjat.tr ..trMah=mah.tr ..miqdori=miqdori;
    if(buyurtmaList.contains(buyurtma)){
      return;
    }
    buyurtma.sana = hujjat.sana;
    buyurtma.vaqt = DateTime.now().millisecondsSinceEpoch;
    buyurtma.vaqtS = buyurtma.vaqt;
    buyurtma.tr = await MahBuyurtma.service!.newId(buyurtma.trHujjat);
    buyurtmaList.add(buyurtma);
    buyurtmaCont[buyurtma.tr] = TextEditingController(text: buyurtma.miqdori.toStringAsFixed(buyurtma.mahsulot.kasr));
    setState(() => buyurtmaList);
    await buyurtma.insert();
  }

  remove(MahBuyurtma buyurtma) async {
    try{
      await buyurtma.delete();
      buyurtmaList.remove(buyurtma);
    }
    catch(e){
      alertDialog(context, e as Alert);
    }
    finally{
      setState(() => buyurtmaList);
    }
  }

  mahIzlash(String value){
    loadFromGlobal();
    setState(() {
      mahsulotList = mahsulotList
          .where((element) =>
              element.nomi.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Map _brtmJonatganiMalumot(){
    return {
      'hujjat': hujjat.toJson(),
      'mahsulotlar': buyurtmaList.map((e) => e.toJson()).toList(),
    };
  }
}
