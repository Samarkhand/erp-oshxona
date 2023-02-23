import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mah_kirim.dart';
import 'package:erp_oshxona/View/MahTarqat/tarqat_cont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:erp_oshxona/Widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:flutter/services.dart';

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
    return RawKeyboardListener(
      //autofocus: true,
      onKey: ((value) {
        //print(value);
        if (value.data.physicalKey.debugName == "F9") {
          _cont.tagInputFN.requestFocus();
        }
      }),
      focusNode: _cont.keyListenerFN,
      child: SafeArea(
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
      ),
    );
  }

  AppBar? _appBar(BuildContext context) {
    const kichikTS = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
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
            Text("${dateFormat.format(_cont.hujjat.sanaDT)}  ",
                style: kichikTS),
            statusBadge(_cont.hujjat.status),
          ]),
    );
  }

  List<Widget>? _buildActions() {
    if (_cont.hujjat.sts == HujjatSts.ochilgan.tr) {
      return <Widget>[
        IconButton(onPressed: () {}, icon: const Icon(Icons.lock), tooltip: "Qulflash"),
      ];
    } else {
      return <Widget>[
        IconButton(onPressed: () {}, icon: const Icon(Icons.lock_open), tooltip: "Qulfdan ochish"),
      ];
    }
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
                  child: _taomnomaRoyxati(),
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
    return SizedBox(
      height: 300, 
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: Theme.of(context).primaryColor,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: 
          Stack(
            fit: StackFit.loose,
            children: [
              Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _cont.tagInputCont,
                  focusNode: _cont.tagInputFN,
                  decoration: InputDecoration(
                    hintText: "(F9) Enter NFC Card",
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
                    _cont.kontAddFN.requestFocus();
                  },
                ),
                const SizedBox(height: 15),
                Text("Hodim", style: MyTheme.d5.copyWith(color: Colors.white70)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    (_cont.ikkinchiHujjat[kont?.tr] ?? 0) > 0 ? const Icon(Icons.warning, color: Colors.orange) : const SizedBox(),
                    (_cont.ikkinchiHujjat[kont?.tr] ?? 0) > 0 ? const SizedBox(width: 10) : const SizedBox(),
                    Expanded(
                      child: Text(kont?.nomi ?? "Noma'lum",
                        style: MyTheme.h3.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
                Text(kont?.mBolim.nomi ?? "",
                    style: MyTheme.d5.copyWith(color: Colors.white)),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kartochka raqami",
                              style: MyTheme.d5.copyWith(color: Colors.white70)),
                          const SizedBox(height: 5),
                          Text(kont?.tag ?? "Noma'lum",
                              style: MyTheme.h5.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                    InkWell(
                      focusNode: _cont.kontAddFN,
                      borderRadius: BorderRadius.circular(15.0),
                      child: Material(
                        color: Colors.white.withAlpha(200),
                        borderRadius: BorderRadius.circular(15.0),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Icon(
                            Icons.chevron_right,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      onTap: () async {
                        _cont.tagInputFN.requestFocus();
                        bool kiritaver = true;
                        String? izoh;
                        if (_cont.hodim == null) {
                          izoh = await _cont.izohSora();
                          if (izoh == null) kiritaver = false;
                        }
                        if ((_cont.ikkinchiHujjat[_cont.hodim?.tr] ?? 0) > 1) {
                          izoh = await _cont.izohSora();
                          if (izoh == null) kiritaver = false;
                        }
                        if (kiritaver) {
                          _cont.add(_cont.hodim, _cont.taomnoma, izoh: izoh ?? "");
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Izoh kiritish shart"),
                            duration: Duration(seconds: 5),
                          ));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
              _cont.kontLoading ? Material(color: Colors.white30, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: const Center(child: CircularProgressIndicator())) : const SizedBox(),
          ]),
      ),
    );
  }

  Widget _taomnomaRoyxati() {
    List<Widget> royxat = [];
    royxat.add(const SizedBox(height: 10));
    for (var object in _cont.taomnoma) {
      royxat.add(
        Material(
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.remove_red_eye),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(object.mahsulot.nomi,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text("${object.qoldi} ${object.mahsulot.mOlchov.nomi}"),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: _miqdorOzgartirTF(object),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    royxat.add(const SizedBox(height: 60));
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Taomnoma", style: MyTheme.h5),
                  TextButton.icon(
                    label: const Text("Qoshimcha"),
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _cont.saqlashTuriTanlash(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView(
              children: royxat,
            )),
          ],
        ),
      ),
    );
  }

  List<Widget> _tarqatilganRoyxati() {
    List<Widget> royxat = [];
    int n = _cont.tarqatilganlar.length + 1;
    _cont.tarqatilganlar.sort(((a, b) {
      return -a.tr.compareTo(b.tr);
    }));
    for (var object in _cont.tarqatilganlar) {
      n--;
      royxat.add(
        Material(
          color: object.trKont == 0
              ? Colors.orange.withOpacity(0.3)
              : (_cont.ikkinchiHujjat[object.trKont] ?? 0) > 1
                  ? Colors.red.withOpacity(0.3)
                  : Colors.transparent,
          child: InkWell(
            onTap: () async {},
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "$n. ${object.trKont == 0 ? "Mehmon" : object.kont!.nomi}"),
                      object.izoh.isNotEmpty
                          ? Text(object.izoh,
                              style: const TextStyle(color: Colors.black38))
                          : const SizedBox(),
                    ],
                  )),
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

  _miqdorOzgartirTF(MahKirim object) {
    TextEditingController cont = _cont.taomnomaCont[object.tr]!;
    return TextField(
      controller: cont,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
      ],
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
        border: const OutlineInputBorder(),
        suffixText: " ${object.mahsulot.mOlchov.nomi}",
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            num value = (num.tryParse(cont.text) ?? 0);
            if ((value - 1) < 0) {
              cont.text = '0';
            } else {
              cont.text = (value + 1).toStringAsFixed(object.mahsulot.kasr);
            }
          },
        ),
        prefixIcon: IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            num value = (num.tryParse(cont.text) ?? 0);
            if ((value - 1) < 0) {
              cont.text = '0';
            } else {
              cont.text = (value - 1).toStringAsFixed(object.mahsulot.kasr);
            }
          },
        ),
      ),
      onChanged: (value) {
        var val = num.tryParse(value);
        if (val == null || val < 0) {
          cont.text = '';
        } /*
        else {
          cont.text = val.toStringAsFixed(object.mahsulot.kasr);
        } */
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
