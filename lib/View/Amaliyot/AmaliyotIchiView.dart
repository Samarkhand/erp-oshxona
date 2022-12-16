import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Bolimlar/ABolimIchiView.dart';
import 'package:erp_oshxona/View/Amaliyot/AmaliyotIchiCont.dart';
import 'package:erp_oshxona/View/Kont/KontIchiView.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:erp_oshxona/Model/system/form.dart';

class AmaliyotIchiView extends StatefulWidget {
  AmaliyotIchiView(this.tr, {Key? key})
      : infomi = true,
        turi = 0,
        super(key: key) {
    turi = Amaliyot.obyektlar[tr]!.turi;
  }
  AmaliyotIchiView.tahrir(this.tr, {Key? key})
      : turi = 0,
        super(key: key) {
    turi = Amaliyot.obyektlar[tr]!.turi;
  }
  AmaliyotIchiView.yangi(this.turi, {Key? key})
      : yangimi = true,
        tr = 0,
        super(key: key);
  int turi;
  int tr;
  bool yangimi = false;
  bool infomi = false;

  @override
  State<AmaliyotIchiView> createState() => _AmaliyotIchiViewState();
}

class _AmaliyotIchiViewState extends State<AmaliyotIchiView> {
  final AmaliyotIchiCont _cont = AmaliyotIchiCont();
  bool yuklanmoqda = false;

  List<TargetFocus> targets = [];

  GlobalKey keyMiqdor = GlobalKey(debugLabel: "keyMiqdor");
  GlobalKey keyBolimTan = GlobalKey(debugLabel: "keyBolimTan");
  GlobalKey keyBolimYan = GlobalKey(debugLabel: "keyBolimYan");
  GlobalKey keyHisob = GlobalKey(debugLabel: "keyHisob");
  GlobalKey keyKontaktTan = GlobalKey(debugLabel: "keyKontaktTan");
  GlobalKey keyKontaktYan = GlobalKey(debugLabel: "keyKontaktYan");
  GlobalKey keySanaTan = GlobalKey(debugLabel: "keySanaTan");
  GlobalKey keyIzoh = GlobalKey(debugLabel: "keyIzoh");

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
                  return const QollanmaView(sahifa: 'amaliyot');
                },
              ));
            },
          ),
        ],
        title: Text((_cont.isLoading)
            ? _cont.loadingLabel
            : title ??
                (widget.yangimi
                    ? "${AmaliyotTur.obyektlar[widget.turi]!.nomi} kiritish "
                    : (widget.infomi)
                        ? AmaliyotTur.obyektlar[widget.turi]!.nomi
                        : "Tahrirlash: ${_cont.object.tr}")));
  }

  static const double oraliqPadding = 12;
  Widget _body(context) {
    return Form(
      key: _cont.formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        key: keyMiqdor,
                        autofocus: Sozlash.tutored,
                        controller: _cont.miqdorController,
                        decoration: InputDecoration(
                          labelText: "Miqdori",
                          labelStyle: const TextStyle(fontSize: 16),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[+-]?([0-9]*[.])?[0-9]+'))
                        ],
                        onFieldSubmitted: (value) =>
                            _cont.bolimTanlash(context),
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          if (value != "") {
                            _cont.object.miqdor = num.parse(value);
                          } else {
                            _cont.object.miqdor = 0;
                          }
                        },
                        validator: (value) =>
                            _cont.validate(value, required: true),
                      ),
                    ),
                    const SizedBox(width: oraliqPadding),
                    _qarzCheckbox(),
                  ],
                ),
                _cont.qarzmi ? const SizedBox() : const SizedBox(height: oraliqPadding),
                _cont.qarzmi ? const SizedBox() : Row(children: [
                  Expanded(
                      child: Material(
                    key: keyBolimTan,
                    color: Colors.orangeAccent,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (FormAlertType.danger ==
                                _cont.formValidator[_cont.formKeySelectBolim]!
                                    .type)
                            ? Colors.red.shade900
                            : Colors.white.withOpacity(0),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () => _cont.bolimTanlash(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                            children: _cont.object.bolim == 0
                                ? [
                                    const Icon(Icons.folder),
                                    const Text(" Bo'lim tanlash"),
                                  ]
                                : [
                                    const Icon(Icons.folder),
                                    Text(
                                        " ${ABolim.obyektlar[_cont.object.bolim]!.nomi}"),
                                  ]),
                      ),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Material(
                    key: keyBolimYan,
                    color: Colors.white,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (FormAlertType.danger ==
                                _cont.formValidator[_cont.formKeySelectBolim]!
                                    .type)
                            ? Colors.white
                            : Colors.white.withOpacity(0),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () async {
                        var tr = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ABolimIchiView.yangi(
                                    widget.turi,
                                    tanlansin: true,
                                  )),
                        );

                        if (tr == null) {
                          return;
                        }
                        setState(() {
                          ABolim.obyektlar;
                          _cont.object.bolim = tr;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ]),
                (!_cont.qarzmi && FormAlertType.danger ==
                        _cont.formValidator[_cont.formKeySelectBolim]!.type)
                    ? Text(_cont.formValidator[_cont.formKeySelectBolim]!.text,
                        style:
                            TextStyle(color: Colors.red.shade900, fontSize: 12))
                    : const SizedBox(),
                const SizedBox(height: oraliqPadding),
                Material(
                  key: keyHisob,
                  color: _cont.object.hisob != 0
                      ? Hisob.obyektlar[_cont.object.hisob]!.color
                          .withOpacity(0.5)
                      : Colors.lightGreenAccent,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: (FormAlertType.danger ==
                              _cont.formValidator[_cont.formKeySelectHisob]!
                                  .type)
                          ? Colors.red.shade900
                          : Colors.white.withOpacity(0),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _cont.hisobTanlash(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                          children: _cont.object.hisob == 0
                              ? [
                                  const Icon(Icons.account_balance_wallet),
                                  const Text(" Hisob tanlash"),
                                ]
                              : [
                                  if (Hisob.obyektlar[_cont.object.hisob] !=
                                      null)
                                    Icon(Hisob
                                        .obyektlar[_cont.object.hisob]!.icon)
                                  else
                                    const Icon(Icons.account_balance_wallet),
                                  Text(Hisob
                                      .obyektlar[_cont.object.hisob]!.nomi),
                                ]),
                    ),
                  ),
                ),
                (FormAlertType.danger ==
                        _cont.formValidator[_cont.formKeySelectHisob]!.type)
                    ? Text(_cont.formValidator[_cont.formKeySelectHisob]!.text,
                        style:
                            TextStyle(color: Colors.red.shade900, fontSize: 12))
                    : const SizedBox(),
                const SizedBox(height: oraliqPadding),
                Row(children: [
                  Expanded(
                      child: Material(
                    key: keyKontaktTan,
                    color: Colors.greenAccent,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () => _cont.kontTanlash(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _cont.object.kont == 0
                                ? [
                                    Row(
                                      children: const [
                                        Icon(Icons.person),
                                        Text(" Kontakt tanlash"),
                                      ],
                                    ),
                                  ]
                                : [
                                    Wrap(
                                      children: [
                                        const Icon(Icons.person, size: 17),
                                        Text(
                                            " ${Kont.obyektlar[_cont.object.kont]!.nomi}"),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () => {
                                        setState(() {
                                          _cont.object.kont = 0;
                                        })
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.zero,
                                        child: Icon(Icons.close),
                                      ),
                                    ),
                                  ]),
                      ),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Material(
                    key: keyKontaktYan,
                    color: Colors.white,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (FormAlertType.danger ==
                                _cont.formValidator[_cont.formKeySelectBolim]!
                                    .type)
                            ? Colors.white
                            : Colors.white.withOpacity(0),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () async {
                        var tr = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => KontIchiView.yangi(
                                    tanlansin: true,
                                  )),
                        );
                        if (tr == null) {
                          return;
                        }
                        setState(() {
                          Kont.obyektlar;
                          _cont.object.kont = tr;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: oraliqPadding),
                Material(
                  key: keySanaTan,
                  color: Colors.white,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: (FormAlertType.danger ==
                              _cont
                                  .formValidator[_cont.formKeySelectDate]!.type)
                          ? Colors.red.shade900
                          : Colors.white.withOpacity(0),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _cont.sanaTanlash(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        const Icon(Icons.date_range),
                        Text(
                            " ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_cont.object.sana))}"),
                      ]),
                    ),
                  ),
                ),
                (FormAlertType.danger ==
                        _cont.formValidator[_cont.formKeySelectDate]!.type)
                    ? Text(_cont.formValidator[_cont.formKeySelectDate]!.text,
                        style:
                            TextStyle(color: Colors.red.shade900, fontSize: 12))
                    : const SizedBox(),
                const SizedBox(height: oraliqPadding),
                TextFormField(
                  key: keyIzoh,
                  controller: _cont.izohController,
                  decoration: InputDecoration(
                    labelText: "Izoh",
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (value) => _cont.save(context),
                  maxLines: 2,
                  validator: (value) => _cont.validate(value, required: false),
                ),
                const SizedBox(height: oraliqPadding),
                widget.yangimi
                    ? const SizedBox()
                    : Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(children: [
                            Text("Qo'shimcha ma'lumot", style: MyTheme.h6),
                            const SizedBox(height: 5.0),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Kiritilgan vaqti",
                                      style: MyTheme.infoText),
                                  Text(
                                      " ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_cont.object.vaqt))} ${hourMinuteFormat.format(DateTime.fromMillisecondsSinceEpoch(_cont.object.vaqt))}"),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Tartib raqami",
                                      style: MyTheme.infoText),
                                  Text("${_cont.object.tr}"),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Kiritgan", style: MyTheme.infoText),
                                  Text(Sozlash.ism),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
              ],
            ),
          ),
          Material(
            elevation: 2,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 30.0),
                  child: Text("Saqlash".toUpperCase()),
                ),
                onPressed: () => _cont.save(context),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qarzCheckbox() {
    return SizedBox(
      width: 56,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _cont.qarzCheck,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(children: [
              const Text("Qarz"),
              Icon(_cont.qarzmi
                  ? Icons.check_box
                  : Icons.check_box_outline_blank),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _info(context) {
    final turi = AmaliyotTur.obyektlar[_cont.object.turi]!;
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
                _cont.object.bolim == 0
                    ? const SizedBox()
                    : Text(
                        ABolim.obyektlar[_cont.object.bolim]!.nomi,
                        style: MyTheme.h4,
                      ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Miqdori", style: MyTheme.infoText),
                      Text(sumFormat.format(_cont.object.miqdor),
                          style: MyTheme.h6.copyWith(color: turi.ranggi)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Hisob", style: MyTheme.infoText),
                      Text(" ${Hisob.obyektlar[_cont.object.hisob]!.nomi}"),
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
                            Text("Kontakt", style: MyTheme.infoText),
                            Wrap(
                              children: [
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
    targets.add(
      TargetFocus(
        identify: "miqdori",
        keyTarget: keyMiqdor,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Chiqim miqdori",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Bu yerga raqamlarda mablag' miqdori kiritiladi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "* Keyingi qadamga o'tish uchun belgilangan hududga bosing ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "bo'lim",
        keyTarget: keyBolimTan,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Chiqim bo'limi tanlash",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Bo'lim - hisobotda jami chiqim yoki tushumlarni oson ko'rish va nazorat qilish uchun tanlanadi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "* Keyingi qadamga o'tish uchun belgilangan hududga bosing ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "bo'lim yan",
        keyTarget: keyBolimYan,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Yangi bo'lim kiritish",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Shu oynani o'zidan yangi bo'lim kiritish mumkun",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "* Keyingi qadamga o'tish uchun belgilangan hududga bosing ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "hisob",
        keyTarget: keyHisob,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Hisob tanlash",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Tushum yoki chiqim amalga oshirilgan hisobni tanlash. Hisob balansi avtomat ozayadi yoki ko'payadi. Hisoblar mablag' qoldig'ingizni kuzatish uchun tanlanadi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "* Keyingi qadamga o'tish uchun belgilangan hududga bosing ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "kont",
        keyTarget: keyKontaktTan,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Kontakt tanlash",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Ixtiyoriy. Qarz oldi-berdi, nasiya mahsulot & nasiya xizmat ko'rsatilgan taqdirda kontragent tanlash mumkun",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "* Keyingi qadamga o'tish uchun belgilangan hududga bosing ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "kont yan",
        keyTarget: keyKontaktYan,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Kontakt qo'shish",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Shu oynani o'zidan yangi kontakt kiritish mumkun",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "* Keyingi qadamga o'tish uchun belgilangan hududga bosing ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "sana",
        keyTarget: keySanaTan,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Sana tanlash",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Sana tanlash ixtiyoriy. Avvalgi kungi sanani tanlash va qaydlarni kiritish mumkun. Avtomat bugungi sana tanlangan holda bo'ladi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "* Keyingi qadamga o'tish uchun belgilangan hududga bosing ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "izoh",
        keyTarget: keyIzoh,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Izoh kiritish maydonchasi",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Kiritish ixtiyoriy",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "* Keyingi qadamga o'tish uchun belgilangan hududga bosing ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!Sozlash.tutored) {
        showTutorial(targets, context);
        logConsole("showTutorial");
        //Sozlash.box.put("tutored", true);
      }
    });
    super.initState();
  }

  void showTutorial(List<TargetFocus> target, BuildContext context) {
    TutorialCoachMark tutorial = TutorialCoachMark(
      targets: target,
      colorShadow: Colors.black,
      alignSkip: Alignment.bottomLeft,
      textSkip: "O'tkazib yuborish",
      // hideSkip: true,
      // paddingFocus: 10,
      // focusAnimationDuration: Duration(milliseconds: 500),
      // unFocusAnimationDuration: Duration(millisconds: 500),
      // pulseAnimationDuration: Duration(milliseconds: 500),
      // pulseVariation: Tween(begin: 1.0, end: 0.99),
      onFinish: () {
        logConsole("finish");
        Sozlash.box.put("tutored", true);
      },
      /*onClickTargetWithTapPosition: (target, tapDetails) {
        logConsole("onClickTargetWithTapPosition: $target");
        logConsole(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },*/
      onClickTarget: (target) {
        logConsole("onClickTarget: $target");
        if (target.identify == "ChiqimTanlash") {}
      },
      onSkip: () {
        logConsole("skip");
      },
    );
    tutorial.show(context: context);

    // tutorial.skip();
    // tutorial.finish();
    // tutorial.next(); // call next target programmatically
    // tutorial.previous(); // call previous target programmatically
  }
}
