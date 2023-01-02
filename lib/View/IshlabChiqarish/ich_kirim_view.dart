import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/mah_buyurtma.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_kirim_cont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/kBolim.dart';

class IchKirimRoyxatView extends StatefulWidget {
  const IchKirimRoyxatView(this.partiya, {Key? key}) : super(key: key);

  final HujjatPartiya partiya;

  @override
  State<IchKirimRoyxatView> createState() => _IchKirimRoyxatViewState();
}

class _IchKirimRoyxatViewState extends State<IchKirimRoyxatView> {
  final IchKirimRoyxatCont _cont = IchKirimRoyxatCont();
  bool yuklanmoqda = false;
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();

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
          Text("${widget.partiya.hujjat.turiObj.nomi} ${widget.partiya.hujjat.raqami} "),
          Text("${dateFormat.format(widget.partiya.hujjat.sanaDT)} ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
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
          _cont.hujjat.sts != HujjatSts.ochilgan.tr ? const SizedBox() : Expanded(
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
                  children: _cont.hujjat.qulf ? _qulfHujjatIchiRoyxati() : _hujjatIchiRoyxati(),
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
    ];
  }

  List<Widget> _hujjatIchiRoyxati() {
    List<Widget> royxat = [];
    int n = 0;
    royxat.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("Ro'yxat", style: MyTheme.h5),
    ));
    for (var object in _cont.buyurtmaList) {
      n++;
      royxat.add(
        Material(
          child: InkWell(
            onTap: () async {/*
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
                          controller: _cont.buyurtmaCont[object.tr],
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 7.0, horizontal: 5.0),
                            border: const OutlineInputBorder(),
                            suffixText: " ${object.mahsulot.mOlchov.nomi}",
                          ),
                          onChanged: (value) {
                            if(value == '') value = '0';
                            if (object.miqdori != num.tryParse(value)) {
                              setState(() {
                                object.miqdori = num.tryParse(value) ?? 0;
                              });
                              MahBuyurtma.service!.update({'miqdori': object.miqdori},
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
    for (var object in _cont.buyurtmaList) {
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
                      Text("${object.miqdori.toStringAsFixed(object.mahsulot.kasr)} ${object.mahsulot.mOlchov.nomi}"),
                      
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
    if(_cont.hujjat.sts == HujjatSts.ochilgan.tr){
      return <Widget>[
        IconButton(onPressed: () => _cont.buyurtmaJonatish(), icon: const Icon(Icons.send), tooltip: "Buyurtma jo'natish"),
      ];
    }
    else if(_cont.hujjat.sts == HujjatSts.jonatilganBrtm.tr) {
      return <Widget>[
        IconButton(onPressed: () => _cont.buyurtmaTekshirish(), icon: const Icon(Icons.refresh), tooltip: "Tekshirish"),
      ];
    }
    else if(_cont.hujjat.sts == HujjatSts.tasdiqKutBrtm.tr) {
      return <Widget>[
        IconButton(onPressed: () => _cont.buyurtmaTekshirish(), icon: const Icon(Icons.refresh), tooltip: "Tekshirish"),
        IconButton(onPressed: () => _cont.buyurtmaTugallash(), icon: const Icon(Icons.check), tooltip: "Qabul qilish"),
        IconButton(onPressed: () => _cont.buyurtmaTugallash(), icon: const Icon(Icons.close), tooltip: "Qaytarib yuborish"),
      ];
    }
    else {
      return null;
    }
  }

  _delete(BuildContext context, KBolim element) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O`chirilsinmi?'),
        content: const Text(
            'O`chirmoqchi bo`lgan elementingizni qayta tiklab bo`lmaydi'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BEKOR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _cont.showLoading();
              await _cont.delete(element);
              _cont.hideLoading();
            },
            child: const Text('O`CHIRILSIN'),
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
