import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Bolimlar/ABolimIchiView.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatIchiCont.dart';
import 'package:erp_oshxona/View/Kont/KontIchiView.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/form.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HujjatIchiView extends StatefulWidget {
  HujjatIchiView(this.hujjat, {Key? key})
      : infomi = true,
        yangimi = false,
        turi = 0,
        super(key: key) {
    turi = hujjat.turi;
  }
  HujjatIchiView.tahrir(this.hujjat, {Key? key})
      : yangimi = false,
        infomi = false,
        turi = 0,
        super(key: key) {
    turi = hujjat.turi;
  }
  HujjatIchiView.yangi(this.turi, {Key? key})
      : yangimi = true,
        infomi = false,
        hujjat = Hujjat(),
        super(key: key);
  int turi;
  Hujjat hujjat;
  bool yangimi;
  bool infomi;

  @override
  State<HujjatIchiView> createState() => _HujjatIchiViewState();
}

class _HujjatIchiViewState extends State<HujjatIchiView> {
  final HujjatIchiCont _cont = HujjatIchiCont();
  bool yuklanmoqda = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(
        child: _cont.isLoading
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
            : widget.infomi
                ? _info(context)
                : _body(context),
      ),
    );
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            tooltip: "Sahifa bo'yicha qollanma",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const QollanmaView(sahifa: 'mahsulot');
                },
              ));
            },
          ),
        ],
        title: Text((_cont.isLoading)
            ? _cont.loadingLabel
            : title ??
                (widget.yangimi
                    ? "Yangi qayd: ${HujjatTur.obyektlar[widget.turi]!.nomi}"
                    : (widget.infomi)
                        ? HujjatTur.obyektlar[widget.turi]!.nomi
                        : "Tahrirlash: ${_cont.object.tr}")));
  }

  static const double oraliqPadding = 12;
  Widget _body(context) {
    return Form(
      key: _cont.formKey,
      child: SizedBox(),
    );
  }

  Widget _info(context) {
    final turi = HujjatTur.obyektlar[_cont.object.turi]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(children: [
        Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _cont.object.turi == 0
                    ? const SizedBox()
                    : Text(
                        HujjatTur.obyektlar[_cont.object.turi]!.nomi,
                        style: MyTheme.h4,
                      ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Miqdori", style: MyTheme.infoText),
                      Text(sumFormat.format(_cont.object.summa),
                          style: MyTheme.h6.copyWith(color: turi.ranggi)),
                    ],
                  ),
                ),
                _cont.object.kont == 0
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 7.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              children: [
                                Text("Kontakt", style: MyTheme.infoText),
                                Text(
                                    " ${Kont.obyektlar[_cont.object.kont]!.nomi}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sana", style: MyTheme.infoText),
                      Text(
                          " ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_cont.object.sana))}"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Kiritilgan vaqti", style: MyTheme.infoText),
                      Text(
                          " ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_cont.object.vaqt))} ${hourMinuteFormat.format(DateTime.fromMillisecondsSinceEpoch(_cont.object.vaqt))}"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tartib raqami", style: MyTheme.infoText),
                      Text("${_cont.object.tr}"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Kiritgan", style: MyTheme.infoText),
                      Text(Sozlash.ism),
                    ],
                  ),
                ),
                (_cont.object.izoh.isEmpty)
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 7.0),
                        child: Row(
                          children: [
                            Text("Izoh: ", style: MyTheme.infoText),
                            Text(_cont.object.izoh,
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Column(children: [
            ListTile(
              title: const Text("Tahrirlash"),
              leading: const Icon(Icons.edit),
              onTap: () async {
                setState(() {
                  widget.infomi = false;
                  widget.yangimi = false;
                  _cont.object;
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ]),
        ),
      ]),
    );
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
