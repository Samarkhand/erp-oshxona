import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';
import 'package:erp_oshxona/Model/m_olchov.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/Widget/autocomplate_textfield.dart';
import 'package:erp_oshxona/View/Mahsulot/MahsulotIchiCont.dart';

class MahsulotIchiView extends StatefulWidget {
  MahsulotIchiView(this.tr, {Key? key})
      : infomi = true,
        yangimi = false,
        super(key: key);
  MahsulotIchiView.tahrir(this.tr, {Key? key})
      : yangimi = false,
        infomi = false,
        super(key: key);
  MahsulotIchiView.yangi({Key? key})
      : yangimi = true,
        infomi = false,
        tr = 0,
        super(key: key);
  int tr;
  bool yangimi;
  bool infomi;

  @override
  State<MahsulotIchiView> createState() => _MahsulotIchiViewState();
}

class _MahsulotIchiViewState extends State<MahsulotIchiView> {
  final MahsulotIchiCont _cont = MahsulotIchiCont();
  bool yuklanmoqda = false;

  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  List<String> olchovBirliklarSelect = MOlchov.obyektlar
      .map((key, value) => MapEntry(key, value.nomi))
      .values
      .toList();

  SimpleAutoCompleteTextField? textField;
  bool showWhichErrorText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
      title: Text(
        (_cont.isLoading)
            ? _cont.loadingLabel
            : title ??
                (widget.yangimi
                    ? "Yangi mahsulot"
                    : "Tahrirlash: ${_cont.object.tr}"),
      ),
    );
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
                  controller: _cont.nomiController,
                  decoration: InputDecoration(
                    labelText: "Nomi:",
                    labelStyle: const TextStyle(fontSize: 16),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (input) => _cont.object.nomi = input!,
                  onFieldSubmitted: (value) => _cont.save(context),
                  validator: (input) =>
                      _cont.nomiController.text == "" ? "Nomini yozing" : null,
                ),
                const SizedBox(height: oraliqPadding),
                SimpleAutoCompleteTextField(
                  key: key,
                  decoration: InputDecoration(
                    labelText: "O'lchov birligi:",
                    labelStyle: const TextStyle(fontSize: 16),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  controller: _cont.obController,
                  suggestions: olchovBirliklarSelect,
                  onFocusChanged: (value) {},
                  //textChanged: (text) => _cont.obController.text = text,
                  clearOnSubmit: false,
                  suggestionsAmount: 10,
                  textSubmitted: (text) => setState(
                    () {
                      if (text != "") {
                        _cont.obController.text = text;
                      }
                    },
                  ),
                ),
                const SizedBox(height: oraliqPadding),
                selectWidget(
                  onTap: () {
                    bolimTanlash(
                      context: context,
                      setState: setState,
                      label: "Mahsulot bo'limini tanlang",
                      items: MBolim.obyektlar.values.toList(),
                      selectedValue: _cont.object.mBolim,
                      onChange: (selected) {
                        setState(() => _cont.object.trBolim = selected.tr);
                      },
                    );
                  },
                  selectValue: _cont.object.trBolim == 0
                      ? [
                          const Text("Mahsulot bo'limini tanlang"),
                        ]
                      : [
                          const Icon(Icons.folder, size: 16),
                          Text(" ${_cont.object.mBolim.nomi}"),
                        ],
                  onTapPlus: () async {
                    int tr = 0;
                    /*int tr = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MBolimIchiView.yangi()),
                          );*/
                    if (tr == 0) {
                      return;
                    }
                    setState(() {
                      MBolim.obyektlar;
                      _cont.object.trBolim = tr;
                    });
                  },
                ),
                const SizedBox(height: 10.0),
                _tanlanganCheck(),
                const SizedBox(height: 10.0),
                _taroziCheck(),
                const SizedBox(height: 10.0),
                _komplektCheck(),
              ],
            ),
          ),
          Material(
            elevation: 2,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 30.0,
                      ),
                      child: Text("SAQLASH"),
                    ),
                    onPressed: () => _cont.save(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tanlanganCheck() {
    return check(
      title: const Text("Tanlash"),
      value: _cont.object.tanlangan,
      onChanged: (value) {
        logConsole("tr='${_cont.object.tr}'");
        setState(() {
          _cont.object.tanlangan = !_cont.object.tanlangan;
        });
        if (widget.infomi == false && widget.yangimi == false) {
          Mahsulot.service!.update(
            {"tanlangan": _cont.object.tanlangan ? 1 : 0},
            where: " tr='${_cont.object.tr}'",
          );
        }
      },
    );
  }

  Widget _taroziCheck() {
    return check(
      title: const Text("Tarozida o'lchanadi"),
      value: _cont.object.tarozimi,
      onChanged: (value) {
        logConsole("tr='${_cont.object.tr}'");
        setState(() {
          _cont.object.tarozimi = !_cont.object.tarozimi;
        });
        if (widget.infomi == false && widget.yangimi == false) {
          Mahsulot.service!.update(
            {"tarozimi": _cont.object.tarozimi ? 1 : 0},
            where: " tr='${_cont.object.tr}'",
          );
        }
      },
    );
  }

  Widget _komplektCheck() {
    return check(
      value: _cont.object.komplektmi,
      title: const Text("Komplekt mahsulot"),
      onChanged: (value) {
        logConsole("tr='${_cont.object.tr}'");
        setState(() {
          _cont.object.komplektmi = !_cont.object.komplektmi;
        });
        if (widget.infomi == false && widget.yangimi == false) {
          Mahsulot.service!.update(
            {"komplektmi": _cont.object.komplektmi ? 1 : 0},
            where: " tr='${_cont.object.tr}'",
          );
        }
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
