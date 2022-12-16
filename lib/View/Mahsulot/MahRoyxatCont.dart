import 'package:flutter/material.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/Mahsulot/MahRoyxatView.dart';

enum Sarala {
  barchasi,
  borlar,
  yoqlar,
  umumiy
}

class MahRoyxatCont with Controller {
  late MahRoyxatView widget;
  List<Mahsulot> objectList = [];

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    showLoading(text: "Yuklanmoqda...");
    await loadItems();
    hideLoading();

    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> loadItems() async {
    /*(await MahQoldiq.service!.select()).forEach((key, value) {
      MahQoldiq.obyektlar[key] = MahQoldiq.fromJson(value);
    });*/
    objectList = (widget.turi == null ? Mahsulot.obyektlar.values : Mahsulot.obyektlar.values.where((element) => element.turi == widget.turi!.tr)).toList();
    /*objectList.sort((a, b) => -a.sana.compareTo(b.sana));*/
  }

  sarala(Sarala usuli){
    objectList = (widget.turi == null ? Mahsulot.obyektlar.values : Mahsulot.obyektlar.values.where((element) => element.turi == widget.turi!.tr)).toList();
    
    if(usuli == Sarala.borlar){
      objectList = objectList.where((element) => element.mQoldiq != null && element.mQoldiq!.qoldi > 0).toList();
    }
    else if(usuli == Sarala.yoqlar){
      objectList = objectList.where((element) => element.mQoldiq == null || element.mQoldiq!.qoldi <= 0).toList();
    }
    else{}

    setState((){
      objectList;
    });
  }

  Future<void> delete(Mahsulot element) async {
    await Mahsulot.service!.deleteId(element.tr);
    Mahsulot.obyektlar.remove(element.tr);
    setState(() {
      objectList.remove(element);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("O'chirib yuborildi"),
      duration: Duration(seconds: 5),
    ));
  }
  
}
