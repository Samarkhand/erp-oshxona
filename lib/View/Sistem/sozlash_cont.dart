
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/View/Sistem/sozlash_view.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:select_dialog/select_dialog.dart';

class SozlashCont with Controller {
  late SozlashView widget;

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    await loadView();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> loadView() async {
    
  }

  Future<void> hisobBolimTanlash() async {
    int select = 0;
    SelectDialog.showModal<Hisob>(
      context,
      label: "Hisob tanlang",
      selectedValue: Hisob.obyektlar[select],
      items: Hisob.obyektlar.values
          .toList(),
      onChange: (selected) async {
        await Sozlash.box.put("tanlanganHisob", selected.tr);
        setState(() {
          Sozlash.tanlanganHisob;
        });
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }

  Future<void> komissiyaBolimTanlash([int select = 0, ABolimTur? turi])async {
    turi = turi ?? ABolimTur.chiqim;
    SelectDialog.showModal<ABolim>(
      context,
      label: turi.nomi,
      selectedValue: ABolim.obyektlar[select],
      items: ABolim.obyektlar.values
          .where((element) => element.turi == turi!.tr)
          .toList(),
      onChange: (selected) async {
        await Sozlash.box.put('abolimTrKomissiya', selected.tr);
        setState(() {
          Sozlash.abolimKomissiya;
        });
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }

  Future<void> mahBolimTanlash([String boxput = '', int select = 0, ABolimTur? turi])async {
    if(boxput.isEmpty) {
      return;
    }
    SelectDialog.showModal<ABolim>(
      context,
      label: turi!.nomi,
      selectedValue: ABolim.obyektlar[select],
      items: ABolim.obyektlar.values
          .where((element) => element.turi == turi.tr)
          .toList(),
      onChange: (selected) async {
        await Sozlash.box.put(boxput, selected.tr);
        setState(() {
          Sozlash.abolimKomissiya;
        });
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }
}