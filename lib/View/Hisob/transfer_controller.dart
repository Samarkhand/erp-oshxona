import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/View/Hisob/transfer_view.dart';
import 'package:erp_oshxona/Model/transfer.dart';
import 'package:erp_oshxona/Model/TransferTemp.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/system/controller.dart';

class TransferCont with Controller {
  late TransferView widget;
  bool yuklanibBoldi = false;
  List<Amaliyot> barchaObjectlar = [];
  List<Amaliyot> korsatObjectlar = [];

  bool update = false;

  TextEditingController miqdorController = TextEditingController();
  TextEditingController izohController = TextEditingController();
  TextEditingController foizController = TextEditingController();
  TextEditingController sumController = TextEditingController();

  Transfer trans = Transfer();
  Transfer transEski = Transfer();
  TransferTemp temp = TransferTemp()..yoq = true;

  Future<void> init(widget, Function setState, BuildContext context) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;

    if (widget.trans != null) {
      trans = widget.trans;
      transEski = Transfer.fromJson(trans.toJson());

      miqdorController.text = trans.miqdor.toString();
      foizController.text = trans.foiz.toString();
      sumController.text = trans.sum.toString();
      izohController.text = trans.izoh;

      update = true;
    } else {
      trans = Transfer()..vaqt = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<void> dispose() async {}

  Future<List> olHisoblar() async {
    return Hisob.obyektlar.values.toList();
  }

  Future<void> transferTempTanla(int hisobtr, bool hisobdan) async {
    if (hisobdan) {
      trans.trHisobdan = hisobtr;
    } else {
      trans.trHisobga = hisobtr;
    }

    if (trans.trHisobdan != 0 && trans.trHisobga != 0) {
      var hatobor = false;
      try {
        temp = TransferTemp.fromJson((await TransferTemp.service!
            .selectOne(trans.trHisobdan, trans.trHisobga)));
      } catch (e) {
        hatobor = true;
      }
      if (!hatobor) {
        trans.selectTemp(temp);
      } else {
        temp = TransferTemp()
          ..trHisobdan = trans.trHisobdan
          ..trHisobga = trans.trHisobga
          ..bolim = Sozlash.abolimKomissiya.tr
          ..yoq = true
          ..foiz = trans.foiz
          ..sum = trans.sum;
      }
      foizController.text = trans.foiz.toString();
      sumController.text = trans.sum.toString();
      setState(() {
        trans = trans;
      });
    }
  }

  void saqla(BuildContext context) async {
    if (foizController.text == '') {
      trans.foiz = 0;
    } else {
      trans.foiz = num.parse(foizController.text.toString());
    }
    if (sumController.text == '') {
      trans.sum = 0;
    } else {
      trans.sum = num.parse(sumController.text.toString());
    }

    trans.izoh = izohController.text;
    trans.miqdor = num.parse(miqdorController.text.toString());

    if (update) {
      await ozgar(context);
    } else {
      await yangi(context);
    }
    logConsole("saqla()");
    logConsole(temp.toJson());
    logConsole(trans.toJson());
    logConsole("");

    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
    temp.getFromTrans(trans);
    if (temp.yoq) {
      temp.yoq = false;
      TransferTemp.service!.insert(temp.toJson());
    } else {
      if (trans.foiz != temp.foiz || trans.sum != temp.sum) {
        TransferTemp.service!
            .update(temp.toJson(), temp.trHisobdan, temp.trHisobga);
      }
    }
  }

  Future<void> ozgar(BuildContext context) async {
    logConsole("ozgar()");
    await Transfer.service!.update(trans.toJson());
    balanslarUpdate(transEski, trans);
    logConsole("Eski: $this.transEski\nYangi: $this.trans");
  }

  Future<void> yangi(BuildContext context) async {
    logConsole("yangi()");
    //int tr = await Amaliyot.service!.newId();
    //----------
    trans.yoq = false;
    trans.bolim = temp.bolim;
    trans.vaqt = DateTime.now().millisecondsSinceEpoch;
    //----------
    var plusAmaliyot = Amaliyot()
      //..tr = tr + 2
      ..yoq = false
      ..turi = AmaliyotTur.transP.tr
      ..hisob = trans.trHisobga
      ..bolim = Sozlash.abolimTransP.tr
      ..vaqt = DateTime.now().millisecondsSinceEpoch
      ..miqdor = trans.miqdor
      ..izoh = trans.izoh;

    var minusAmaliyot = Amaliyot.fromJson(plusAmaliyot.toJson());
    //minusAmaliyot.tr = tr;
    minusAmaliyot.turi = AmaliyotTur.transM.tr;
    minusAmaliyot.bolim = Sozlash.abolimTransM.tr;
    minusAmaliyot.hisob = trans.trHisobdan;
    minusAmaliyot.miqdor = trans.miqdor;

    var xizmatAmaliyot = Amaliyot.fromJson(plusAmaliyot.toJson());
    //xizmatAmaliyot.tr = tr + 1;
    xizmatAmaliyot.turi = AmaliyotTur.chiqim.tr;
    xizmatAmaliyot.hisob = trans.trHisobdan;
    xizmatAmaliyot.bolim = Sozlash.abolimKomissiya.tr;
    xizmatAmaliyot.miqdor = trans.getSumXizmat();

    minusAmaliyot.tr = await Amaliyot.service!.insert(minusAmaliyot.toJson());
    // agar xizmat miqdori 0 bo'lsa - xizmatAmaliyot kiritmay qo'yaversin
    if (xizmatAmaliyot.miqdor > 0) {
      xizmatAmaliyot.tr =
          await Amaliyot.service!.insert(xizmatAmaliyot.toJson());
    }
    plusAmaliyot.tr = await Amaliyot.service!.insert(plusAmaliyot.toJson());

    Amaliyot.obyektlar[minusAmaliyot.tr] = minusAmaliyot;
    Amaliyot.obyektlar[plusAmaliyot.tr] = plusAmaliyot;
    if (xizmatAmaliyot.miqdor > 0) {
      Amaliyot.obyektlar[xizmatAmaliyot.tr] = xizmatAmaliyot;
    }

    trans.trAmalM = minusAmaliyot.tr;
    trans.trAmalP = plusAmaliyot.tr;
    await Transfer.service!.insert(trans.toJson());
    hisobBalansUpdate(trans);
  }

  Future<void> hisobBalansUpdate(Transfer obyekt) async {
    if (obyekt.trHisobdan != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[obyekt.trHisobdan]!;
      ushbuHisob.balansOzaytir(obyekt.miqdor + obyekt.getSumXizmat());
    }
    if (obyekt.trHisobga != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[obyekt.trHisobga]!;
      ushbuHisob.balansKopaytir(obyekt.miqdor);
    }
  }

  Future<void> balanslarUpdate(Transfer obyektEski, Transfer obyekt) async {
    if (obyektEski.trHisobdan != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[obyektEski.trHisobdan]!;
      ushbuHisob.balansKopaytir(obyektEski.miqdor + obyektEski.getSumXizmat());
    }
    if (obyekt.trHisobga != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[obyekt.trHisobga]!;
      ushbuHisob.balansOzaytir(obyekt.miqdor);
    }
    //-------
    if (obyekt.trHisobdan != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[obyekt.trHisobdan]!;
      ushbuHisob.balansOzaytir(obyekt.miqdor + obyekt.getSumXizmat());
    }
    if (obyekt.trHisobga != 0) {
      Hisob ushbuHisob = Hisob.obyektlar[obyekt.trHisobga]!;
      ushbuHisob.balansKopaytir(obyekt.miqdor);
    }
  }
}
