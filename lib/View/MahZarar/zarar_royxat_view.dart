import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mah_chiqim_zar.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/View/MahZarar/zarar_royxat_cont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';

class ChiqZararRoyxatView extends StatefulWidget {
  const ChiqZararRoyxatView(this.hujjat, {Key? key}) : super(key: key);

  final Hujjat hujjat;

  @override
  State<ChiqZararRoyxatView> createState() => _ChiqZararRoyxatViewState();
}

class _ChiqZararRoyxatViewState extends State<ChiqZararRoyxatView> {
  final ChiqZararRoyxatCont _cont = ChiqZararRoyxatCont();
  bool yuklanmoqda = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context),
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
      actions: _buildActions(),
      title: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _cont.hujjat.qulf ? const Icon(Icons.lock) : const SizedBox(),
            Text("${widget.hujjat.turiObj.nomi} ${widget.hujjat.raqami} "),
            Text("${dateFormat.format(widget.hujjat.sanaDT)} ",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal)),
            statusBadge(_cont.hujjat.status),
          ]),
    );
  }

  Widget _body(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cont.hujjat.sts != HujjatSts.ochilgan.tr
              ? const SizedBox()
              : Expanded(
                  flex: 4,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _mahlarRoyxati(),
                      ),
                    ),
                  ),
                ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _cont.hujjat.qulf
                      ? _qulfHujjatIchiRoyxati()
                      : _hujjatIchiRoyxati(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _mahlarRoyxati() {
    List<Widget> royxat = [];
    for (var object in _cont.mahsulotList) {
      var objQoldiq = object.mQoldiq;
      if (objQoldiq == null || objQoldiq.qoldi == 0) {
        continue;
      }
      royxat.add(
        Material(
          child: InkWell(
            onDoubleTap: () => _cont.addToList(object),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(object.nomi),
                      objQoldiq != null && objQoldiq.qoldi != 0
                          ? Text(
                              "${objQoldiq.qoldi.toStringAsFixed(objQoldiq.mahsulot!.kasr)} ${object.mOlchov.nomi}")
                          : Text("0 ${object.mOlchov.nomi}",
                              style: const TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                  Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _cont.addToList(object),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    royxat.add(const SizedBox(height: 60));
    return [
      Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(hintText: "Izlash..."),
              onChanged: (value) {
                _cont.mahIzlash(value);
              },
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _cont.mahTuri = _cont.mahTuri == MTuri.homAshyo.tr
                      ? MTuri.mahsulot.tr
                      : MTuri.homAshyo.tr;
                });
                _cont.loadFromGlobal();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                alignment: Alignment.centerLeft,
                child: Text("${MTuri.obyektlar[_cont.mahTuri]!.nomi} ro'yxati",
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
      Expanded(
          child: ListView(
        children: royxat,
      )),
    ];
  }

  List<Widget> _hujjatIchiRoyxati() {
    List<Widget> royxat = [];
    int n = 0;
    royxat.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("Ro'yxat", style: MyTheme.h5),
    ));
    for (var object in _cont.chiqimList) {
      n++;
      royxat.add(
        Material(
          child: InkWell(
            onTap: () async {
              /*
              //_cont.dialogTextFieldCont.text = object.miqdori.toStringAsFixed(object.mahsulotTarkib.kasr);
              String? value = await inputDialog(context,
                  object.miqdori.toStringAsFixed(object.mahsulot.kasr));
              if (value != null && object.miqdori != num.tryParse(value)) {
                setState(() {
                  object.miqdori = num.tryParse(value) ?? 0;
                });
                MahBuyurtma.service!.update({'miqdori': object.miqdori},
                    where:
                        "trHujjat='${object.trHujjat}' AND tr='${object.tr}'");
              }*/
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$n. ${object.mahsulot.nomi}"),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _cont.miqdorCont[object.tr],
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "Miqdori",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 7.0, horizontal: 5.0),
                            border: const OutlineInputBorder(),
                            suffixText: " ${object.mahsulot.mOlchov.nomi}",
                          ),
                          onChanged: (value) {
                            if (value == '') value = '0';
                            if (object.miqdori != num.tryParse(value)) {
                              setState(() {
                                object.miqdori = num.tryParse(value) ?? 0;
                              });
                              MahChiqimZar.service!.update(
                                  {'miqdori': object.miqdori},
                                  where: "tr='${object.tr}'");
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 130,
                        child: TextField(
                          controller: _cont.tannarxiCont[object.tr],
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            hintText: "Narxi",
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 7.0, horizontal: 5.0),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value == '') value = '0';
                            if (object.tannarxi != num.tryParse(value)) {
                              setState(() {
                                object.tannarxi = num.tryParse(value) ?? 0;
                              });
                              MahChiqimZar.service!.update(
                                  {'tannarxi': object.tannarxi},
                                  where: "tr='${object.tr}'");
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () => deleteDialog(context,
                            yes: () => _cont.remove(object)),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    royxat.add(const SizedBox(height: 60));
    return [
      Expanded(
          child: ListView(
        children: royxat,
      )),
    ];
  }

  List<Widget> _qulfHujjatIchiRoyxati() {
    List<Widget> royxat = [];
    int n = 0;
    royxat.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("Ro'yxat", style: MyTheme.h5),
    ));
    for (var object in _cont.chiqimList) {
      n++;
      royxat.add(
        Material(
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.lock),
                      Text("$n. ${object.mahsulot.nomi}"),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                          "${object.miqdori.toStringAsFixed(object.mahsulot.kasr)} ${object.mahsulot.mOlchov.nomi}"),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () => deleteDialog(context,
                            yes: () => _cont.remove(object)),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    royxat.add(const SizedBox(height: 60));
    return [
      Expanded(
          child: ListView(
        children: royxat,
      )),
    ];
  }

  List<Widget>? _buildActions() {
    if (_cont.hujjat.sts == HujjatSts.ochilgan.tr) {
      return <Widget>[
        IconButton(
          onPressed: () {
            _cont.qulflash();
          },
          icon: const Icon(Icons.lock),
          tooltip: "Qulflash",
        ),
      ];
    } else {
      return null;
    }
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
