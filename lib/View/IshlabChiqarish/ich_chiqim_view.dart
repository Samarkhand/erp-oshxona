import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/mah_chiqim_ich.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/system/alert.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_chiqim_cont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';

class IchiChiqimRoyxatView extends StatefulWidget {
  IchiChiqimRoyxatView(this.partiya, {Key? key})
      : barchaTarkib = [],
        super(key: key);
  const IchiChiqimRoyxatView.yangi(this.partiya, this.barchaTarkib, {Key? key})
      : super(key: key);

  final HujjatPartiya partiya;
  final List<Map> barchaTarkib;

  @override
  State<IchiChiqimRoyxatView> createState() => _IchiChiqimRoyxatViewState();
}

class _IchiChiqimRoyxatViewState extends State<IchiChiqimRoyxatView> {
  final IchiChiqimRoyxatCont _cont = IchiChiqimRoyxatCont();
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

  AppBar? _appBar(BuildContext context) {
    const kichikTS = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
    return AppBar(
      actions: _cont.isLoading ? [] : _buildActions(),
      title: _cont.isLoading ? Text(_cont.loadingLabel) : Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _cont.hujjat.qulf ? const Icon(Icons.lock) : const SizedBox(),
            Text(" ${_cont.hujjat.turiObj.nomi}  "),
            Text("No ${_cont.partiya.hujjat.raqami}, ", style: kichikTS),
            Text("${_cont.partiya.mahal.nomi}, ", style: kichikTS),
            Text("${dateFormat.format(_cont.partiya.hujjat.sanaDT)}  ",
                style: kichikTS),
            statusBadge(_cont.partiya.hujjat.status),
          ]),
    );
  }

  List<Widget>? _buildActions() {
    if (_cont.hujjat.sts != HujjatSts.tugallanganPrt.tr) {
      return <Widget>[
        IconButton(
            onPressed: () => _cont.qulflash(),
            icon: const Icon(Icons.lock),
            tooltip: "Qulflash"),
      ];
    } else {
      return <Widget>[
        IconButton(
            onPressed: () => _cont.tarkibQaytarish(),
            icon: const Icon(Icons.arrow_back),
            tooltip: "Tekshirish"),
      ];
    }
  }

  Widget _body(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cont.hujjat.sts != HujjatSts.homAshyoPrt.tr
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
      royxat.add(
        Material(
          child: InkWell(
            onDoubleTap: () => _cont.addToList(object),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${object.nomi} [${object.mOlchov.nomi}]"),
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
      Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.black54,
        ),
        child: const Text("Taom uchun masalliqlar ",
            style: TextStyle(color: Colors.white)),
      ),
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
      royxat.add(_tarkibItem(object, n));
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

  Widget _tarkibItem(MahChiqimIch object, int n) {
    return FutureBuilder<Alert?>(
      future: MahQoldiq.sotiladimi(
          object.mahsulot, _cont.chiqMahMap[object.mahsulot]!),
      builder: (BuildContext context, AsyncSnapshot<Alert?> snapshot) {
        return Material(
          child: InkWell(
            onTap: () async {
              _cont.kirimUchTanla(context, object);
              /*
              //_cont.dialogTextFieldCont.text = object.miqdori.toStringAsFixed(object.mahsulotTarkib.kasr);
              String? value = await inputDialog(context,
                  object.miqdori.toStringAsFixed(object.mahsulot.kasr));
              if (value != null && object.miqdori != num.tryParse(value)) {
                setState(() {
                  object.miqdori = num.tryParse(value) ?? 0;
                });
                MahChiqim.service!.update({'miqdori': object.miqdori},
                    where:
                        "trHujjat='${object.trHujjat}' AND tr='${object.tr}'");
              }*/
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$n. ${object.mahsulot.nomi}", style: const TextStyle(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _cont.chiqimCont[object.tr],
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
                              _cont.miqdorHisobla(object);
                              MahChiqimIch.service!.update(
                                  {'miqdori': object.miqdori},
                                  where:
                                      "trHujjat='${object.trHujjat}' AND tr='${object.tr}'");
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
                  object.trKirimUch == 0? const SizedBox() : Text("${object.kirimUch!.miqdori} ${object.kirimUch!.mahsulot.mOlchov.nomi} ${object.kirimUch!.mahsulot.nomi} uchun"),
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

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
