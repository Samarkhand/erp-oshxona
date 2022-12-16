import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Bolimlar/ABolimIchiView.dart';
import 'package:erp_oshxona/View/AMahsulot/AMahsulotIchiCont.dart';
import 'package:erp_oshxona/View/Kont/KontIchiView.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/system/form.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AMahsulotIchiView extends StatefulWidget {
  AMahsulotIchiView(this.tr, {Key? key})
      : infomi = true,
        yangimi = false,
        turi = 0,
        super(key: key) {
    turi = AMahsulot.obyektlar[tr]!.turi;
  }
  AMahsulotIchiView.tahrir(this.tr, {Key? key})
      : yangimi = false,
        infomi = false,
        turi = 0,
        super(key: key) {
    turi = AMahsulot.obyektlar[tr]!.turi;
  }
  AMahsulotIchiView.yangi(this.turi, {Key? key})
      : yangimi = true,
        infomi = false,
        tr = 0,
        super(key: key);
  int turi;
  int tr;
  bool yangimi;
  bool infomi;

  @override
  State<AMahsulotIchiView> createState() => _AMahsulotIchiViewState();
}

class _AMahsulotIchiViewState extends State<AMahsulotIchiView> {
  final AMahsulotIchiCont _cont = AMahsulotIchiCont();
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
                    ? "Yangi qayd: ${AMahsulotTur.obyektlar[widget.turi]!.nomi}"
                    : (widget.infomi)
                        ? AMahsulotTur.obyektlar[widget.turi]!.nomi
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
                TextFormField(
                  autofocus: true,
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
                  onFieldSubmitted: (value) => _cont.bolimTanlash(context),
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    if (value != "") {
                      _cont.object.miqdor = num.parse(value);
                      if (_cont.amaliyotBormi) {
                      } else {
                        _cont.miqdor = num.parse(value);
                        _cont.miqdorAmaliyotController.text = value;
                      }
                    } else {
                      _cont.object.miqdor = 0;
                      if (_cont.amaliyotBormi) {
                      } else {
                        _cont.miqdor = 0;
                        _cont.miqdorAmaliyotController.text = '';
                      }
                    }
                  },
                  validator: (value) => _cont.validate(value, required: true),
                ),
                const SizedBox(height: oraliqPadding),
                Row(children: [
                  Expanded(
                      child: Material(
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
                (FormAlertType.danger ==
                        _cont.formValidator[_cont.formKeySelectBolim]!.type)
                    ? Text(_cont.formValidator[_cont.formKeySelectBolim]!.text,
                        style:
                            TextStyle(color: Colors.red.shade900, fontSize: 12))
                    : const SizedBox(),
                const SizedBox(height: oraliqPadding),
                Row(children: [
                  Expanded(
                      child: Material(
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
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        shape: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: (FormAlertType.danger ==
                                    _cont
                                        .formValidator[_cont.formKeySelectDate]!
                                        .type)
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
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(children: [
                              const Icon(Icons.date_range),
                              Text(
                                  " ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_cont.object.sana))}"),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    (FormAlertType.danger ==
                            _cont.formValidator[_cont.formKeySelectDate]!.type)
                        ? Text(
                            _cont.formValidator[_cont.formKeySelectDate]!.text,
                            style: TextStyle(
                                color: Colors.red.shade900, fontSize: 12))
                        : const SizedBox(),
                    widget.yangimi &&
                            _cont.object.turi != AMahsulotTur.spisanya.tr
                        ? const SizedBox(width: oraliqPadding)
                        : const SizedBox(),
                    widget.yangimi &&
                            _cont.object.turi != AMahsulotTur.spisanya.tr
                        ? Material(
                            color: const Color.fromARGB(255, 252, 188, 165),
                            shape: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            //borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () async {
                                await _xizmatTolov(context, setState);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(children: [
                                  const Icon(Icons.attach_money),
                                  SizedBox(
                                    width: 100,
                                    child: _cont.object.turi ==
                                                AMahsulotTur.savdo.tr ||
                                            _cont.object.turi ==
                                                AMahsulotTur.vozvratChiq.tr
                                        ? const Text(
                                            " To'lov oldim",
                                            style: TextStyle(fontSize: 13),
                                          )
                                        : const Text(
                                            " To'lov qildim",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                  ),
                                ]),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                (FormAlertType.danger ==
                        _cont.formValidator[_cont.formKeySelectDate]!.type)
                    ? Text(_cont.formValidator[_cont.formKeySelectDate]!.text,
                        style:
                            TextStyle(color: Colors.red.shade900, fontSize: 12))
                    : const SizedBox(),
                const SizedBox(height: oraliqPadding),
                TextFormField(
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

  Widget _info(context) {
    final turi = AMahsulotTur.obyektlar[_cont.object.turi]!;
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

  _xizmatTolov(context, StateSetter setState) async {
    _cont.objectAmaliyot = _cont.objectAmaliyot ?? Amaliyot();
    return await showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Material(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cont.object.turi == AMahsulotTur.savdo.tr ||
                              _cont.object.turi == AMahsulotTur.vozvratChiq.tr
                          ? Text(" To'lov oldim", style: MyTheme.h5)
                          : Text(" To'lov qildim", style: MyTheme.h5),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Form(
                    key: _cont.formKeyAmaliyot,
                    child: Column(
                      children: [
                        const SizedBox(height: oraliqPadding),
                        const SizedBox(height: oraliqPadding),
                        TextFormField(
                          autofocus: true,
                          controller: _cont.miqdorAmaliyotController,
                          decoration: InputDecoration(
                            labelText: "Miqdori",
                            labelStyle: const TextStyle(fontSize: 16),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
                              _cont.hisobTanlash(context, setState),
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          validator: (value) =>
                              _cont.validate(value, required: true),
                        ),
                        const SizedBox(height: oraliqPadding),
                        Material(
                          color: _cont.hisob != 0
                              ? Hisob.obyektlar[_cont.hisob]!.color
                                  .withOpacity(0.5)
                              : Colors.lightGreenAccent,
                          shape: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: (FormAlertType.danger ==
                                      _cont
                                          .formValidatorAmaliyot[
                                              _cont.formKeySelectHisob]!
                                          .type)
                                  ? Colors.red.shade900
                                  : Colors.white.withOpacity(0),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          //borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => _cont.hisobTanlash(context, setState),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: _cont.hisob == 0
                                    ? [
                                        const Icon(
                                            Icons.account_balance_wallet),
                                        const Text(" Hisob tanlash"),
                                      ]
                                    : [
                                        if (Hisob.obyektlar[_cont.hisob] !=
                                            null)
                                          Icon(Hisob
                                              .obyektlar[_cont.hisob]!.icon)
                                        else
                                          const Icon(
                                              Icons.account_balance_wallet),
                                        Text(
                                            Hisob.obyektlar[_cont.hisob]!.nomi),
                                      ],
                              ),
                            ),
                          ),
                        ),
                        (FormAlertType.danger ==
                                _cont
                                    .formValidatorAmaliyot[
                                        _cont.formKeySelectHisob]!
                                    .type)
                            ? Text(
                                _cont
                                    .formValidatorAmaliyot[
                                        _cont.formKeySelectHisob]!
                                    .text,
                                style: TextStyle(
                                    color: Colors.red.shade900, fontSize: 12))
                            : const SizedBox(),
                        const SizedBox(height: oraliqPadding),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Text("Bekor qilish"),
                                ),
                                onPressed: () {
                                  setState(() => _cont.hisob = 0);
                                  setState(() => _cont.miqdor = 0);
                                  setState(() => _cont.amaliyotBormi = false);

                                  _cont.miqdorAmaliyotController.text =
                                      _cont.miqdorController.text;

                                  setState(() =>
                                      _cont.miqdorAmaliyotController.text);

                                  _cont
                                      .formValidatorAmaliyot[
                                          _cont.formKeySelectHisob]!
                                      .type = FormAlertType.none;
                                  _cont
                                      .formValidatorAmaliyot[
                                          _cont.formKeySelectHisob]!
                                      .text = "";

                                  setState(() => _cont.formValidatorAmaliyot[
                                      _cont.formKeySelectHisob]);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Text("Saqlash"),
                                ),
                                onPressed: () async {
                                  await _cont.saveAmaliyot(context, setState);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
