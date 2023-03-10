import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/mah_chiqim.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/system/alert.dart';
import 'package:erp_oshxona/View/MahChiqim/chiqim_royxat_cont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';

class ChiqimRoyxatView extends StatefulWidget {
  const ChiqimRoyxatView(this.hujjat, {Key? key}) : super(key: key);

  final Hujjat hujjat;

  @override
  State<ChiqimRoyxatView> createState() => _ChiqimRoyxatViewState();
}

class _ChiqimRoyxatViewState extends State<ChiqimRoyxatView> {
  final ChiqimRoyxatCont _cont = ChiqimRoyxatCont();
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
        children: (!_cont.hujjat.qulf
                ? <Widget>[
                    Expanded(
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
                  ]
                : <Widget>[]) +
            <Widget>[
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
                          : _tarkiblarRoyxati(),
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
      royxat.add(
        Material(
          child: InkWell(
            onDoubleTap: () => _cont.addToList(object),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(object.nomi),
                      const Spacer(),
                      Text(sumFormat.format(object.mQoldiq!.tannarxi)),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => _cont.addToList(object),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      object.mQoldiq != null && object.mQoldiq!.qoldi != 0
                          ? Text(
                              "${object.mQoldiq!.qoldi.toStringAsFixed(object.kasr)} ${object.mOlchov.nomi}")
                          : Text("0 ${object.mOlchov.nomi}",
                              style: const TextStyle(color: Colors.redAccent))
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
      TextFormField(
        decoration: const InputDecoration(hintText: "Izlash..."),
        onChanged: (value) {
          _cont.mahIzlash(value);
        },
      ),
      Expanded(
          child: ListView(
        children: royxat,
      )),
    ];
  }

  List<Widget> _tarkiblarRoyxati() {
    List<Widget> royxat = [];
    int n = 0;
    royxat.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("Ro'yxat", style: MyTheme.h5),
    ));
    for (var object in _cont.tarkibList) {
      n++;
      royxat.add(
        _tarkibItem(object, n)
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
    for (var object in _cont.tarkibList) {
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

  Widget _tarkibItem(MahChiqim object, int n) {
    return FutureBuilder<Alert?>(
          future: MahQoldiq.sotiladimi(object.mahsulot, _cont.chiqMahMap[object.mahsulot]!),
          builder: (BuildContext context, AsyncSnapshot<Alert?> snapshot) {
            return Material(
          child: InkWell(
            onTap: () async {
              //_cont.dialogTextFieldCont.text = object.miqdori.toStringAsFixed(object.mahsulotTarkib.kasr);
              String? value = await inputDialog(context,
                  object.miqdori.toStringAsFixed(object.mahsulot.kasr));
              if (value != null && object.miqdori != num.tryParse(value)) {
                setState(() {
                  object.miqdori = num.tryParse(value) ?? 0;
                });
                _cont.miqdorHisobla(object);
                MahChiqim.service!.update({'miqdori': object.miqdori},
                    where:
                        "trHujjat='${object.trHujjat}' AND tr='${object.tr}'");
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$n. ${object.mahsulot.nomi}"),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _cont.tarkibCont[object.tr],
                              textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                isDense: true,
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
                                  MahChiqim.service!.update(
                                      {'miqdori': object.miqdori},
                                      where:
                                          "trHujjat='${object.trHujjat}' AND tr='${object.tr}'");
                                }
                                _cont.miqdorHisobla(object);
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
                  snapshot.data != null
                      ? Row(children: [
                          Expanded(
                              child: Text(
                            "${snapshot.data!.title}. ${snapshot.data!.desc}",
                            softWrap: true,
                            style: const TextStyle(color: Colors.redAccent),
                          ))
                        ])
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        );
          },
        );
  }

  List<Widget>? _buildActions() {
    return _cont.hujjat.qulf
        ? <Widget>[
            IconButton(
                onPressed: () => _cont.qulfOch(),
                icon: const Icon(Icons.lock_open),
                tooltip: "Qulfdan ochish"),
          ]
        : <Widget>[
            IconButton(
                onPressed: () => _cont.qulfla(),
                icon: const Icon(Icons.lock),
                tooltip: "Qulflash"),
          ];
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
  
}
