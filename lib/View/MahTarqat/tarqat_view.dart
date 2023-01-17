import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/View/MahTarqat/tarqat_cont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';

class TarqatishView extends StatefulWidget {
  TarqatishView(this.hujjat, {Key? key}) : super(key: key);
  const TarqatishView.yangi(this.hujjat, {Key? key}) : super(key: key);

  final Hujjat hujjat;

  @override
  State<TarqatishView> createState() => _TarqatishViewState();
}

class _TarqatishViewState extends State<TarqatishView> {
  final TarqatishCont _cont = TarqatishCont();
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
    const kichikTS =  TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal);
    return AppBar(
      actions: _buildActions(),
      title: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _cont.hujjat.qulf ? const Icon(Icons.lock) : const SizedBox(),
            Text(" ${_cont.hujjat.turiObj.nomi}  "),
            Text("No ${_cont.hujjat.raqami}, ", style: kichikTS),
            Text("${_cont.partiya.mahal.nomi}, ", style: kichikTS),
            Text("${dateFormat.format(_cont.hujjat.sanaDT)}  ", style: kichikTS),
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
          Expanded(
            flex: 5,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _kontCard(),
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
                        children: _taomnomaRoyxati(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.only(top: 15, bottom: 5),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _tarqatilganRoyxati(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kontCard() {
    var kont = _cont.hodim;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: Theme.of(context).primaryColor,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _cont.tagInputCont,
              focusNode: _cont.tagInputFN,
              decoration: InputDecoration(
                hintText: "Enter NFC Card",
                hintStyle: const TextStyle(color: Colors.white70),
                contentPadding: const EdgeInsets.all(10),
                prefixIcon:
                    const Icon(Icons.card_membership, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white70,
                  onPressed: () {
                    _cont.tagInputCont.text = '';
                    setState(() {
                      _cont.hodim = null;
                    });
                  },
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(width: 3, color: Colors.red),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.orange),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.white),
                ),
                fillColor: Colors.white10,
                filled: true,
                focusColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              showCursor: false,
              onChanged: (value) {},
              onFieldSubmitted: (value) {
                _cont.tagInputCont.text = '';
                _cont.kontTop(value);
                _cont.tagInputFN.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            Text("Hodim", style: MyTheme.d5.copyWith(color: Colors.white70)),
            const SizedBox(height: 5),
            Text(kont?.nomi ?? "Ismi noma'lum",
                style: MyTheme.h3.copyWith(color: Colors.white)),
            Text(kont?.mBolim.nomi ?? "Bo'limi noma'lum",
                style: MyTheme.d5.copyWith(color: Colors.white)),
            const SizedBox(height: 15),
            Text("Kartochka raqami",
                style: MyTheme.d5.copyWith(color: Colors.white70)),
            const SizedBox(height: 5),
            Text(kont?.tag ?? "Noma'lum",
                style: MyTheme.h5.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  List<Widget> _taomnomaRoyxati() {
    List<Widget> royxat = [];
    for (var object in _cont.taomnoma) {
      royxat.add(
        Material(
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "${object.mahsulot.nomi} [${object.mahsulot.mOlchov.nomi}]"),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _cont.taomnomaCont[object.tr],
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
                          MahKirim.service!.update({'miqdori': object.miqdori},
                              where:
                                  "trHujjat='${object.trHujjat}' AND tr='${object.tr}'");
                        }
                      },
                    ),
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
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text("Taomnoma", style: MyTheme.h5),
      ),
      Expanded(
          child: ListView(
        children: royxat,
      )),
    ];
  }

  List<Widget> _tarqatilganRoyxati() {
    List<Widget> royxat = [];
    int n = 0;
    for (var object in _cont.tarqatilganlar) {
      n++;
      royxat.add(
        Material(
          child: InkWell(
            onTap: () async {},
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$n. ${object.kont!.nomi}"),
                  OutlinedButton(
                    onPressed: () =>
                        deleteDialog(context, yes: () => _cont.remove(object)),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
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
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text("Taom olgan", style: MyTheme.h5),
      ),
      Expanded(
          child: ListView(
        children: royxat,
      )),
    ];
  }

  List<Widget>? _buildActions() {
    if (_cont.hujjat.sts == HujjatSts.ochilgan.tr) {
      return <Widget>[
        //IconButton(onPressed: () => _cont.tarkibTuzish(), icon: const Icon(Icons.arrow_forward), tooltip: "Buyurtma jo'natish"),
      ];
    } else {
      return <Widget>[
        //IconButton(onPressed: () => _cont.tarkibQaytarish(), icon: const Icon(Icons.refresh), tooltip: "Tekshirish"),
      ];
    }
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
