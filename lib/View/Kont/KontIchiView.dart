import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Bolimlar/KBolimIchiView.dart';
import 'package:erp_oshxona/View/Kont/KontIchiCont.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/system/form.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class KontIchiView extends StatefulWidget {
  KontIchiView(this.tr, {Key? key})
      : infomi = true,
        yangimi = false,
        super(key: key);
  KontIchiView.tahrir(this.tr, {Key? key})
      : yangimi = false,
        infomi = false,
        super(key: key);
  KontIchiView.yangi({Key? key, this.tanlansin = false})
      : yangimi = true,
        infomi = false,
        tr = 0,
        super(key: key);
  int tr;
  bool yangimi;
  bool infomi;
  bool tanlansin = false;

  @override
  State<KontIchiView> createState() => _KontIchiViewState();
}

class _KontIchiViewState extends State<KontIchiView> {
  final KontIchiCont _cont = KontIchiCont();
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
                  return const QollanmaView(sahifa: 'kont');
                },
              ));
            },
          ),
        ],
        title: Text((_cont.isLoading)
            ? _cont.loadingLabel
            : title ??
                (widget.yangimi
                    ? "Yangi kontakt"
                    : "Tahrirlash: ${_cont.object.nomi}")));
  }

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
                    autocorrect: true,
                    autofocus: true,
                    validator: (value) => _cont.validate(value, required: true),
                  ),
                  const SizedBox(height: 20.0),
                  IntlPhoneField(
                    initialCountryCode: _cont.object.davKod,
                    initialValue: _cont.object.tel,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      label: const Text("Telefon"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      //prefixIcon: const Icon(Icons.phone),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    ),
                    autofocus: true,
                    onCountryChanged: (country) {
                      //logConsole('Country changed to: ' + country.name);
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _cont.tel = value;
                      }
                    },
                    onChanged: (value) {
                      _cont.object.davKod = value.countryISOCode;
                      _cont.object.telKod = value.countryCode;
                      _cont.object.tel = value.number;
                    },
                    validator: (value) => _cont.validate(value?.completeNumber, required: true),
                  ),
                  const SizedBox(height: 20.0),
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
                        onTap: () => _cont.saqlashTuriTanlash(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                              children: _cont.object.bolim == 0
                                  ? [
                                      const Icon(Icons.folder,
                                          color: Colors.black87),
                                      const Text(" Bo'limini tanlang"),
                                    ]
                                  : [
                                      const Icon(Icons.folder),
                                      Text(
                                          " ${KBolim.obyektlar[_cont.object.bolim]!.nomi}"),
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
                                builder: (context) =>
                                    KBolimIchiView.yangi(0, tanlansin: true)),
                          );

                          if (tr == null) {
                            return;
                          }
                          setState(() {
                            KBolim.obyektlar;
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
                      ? Text(
                          _cont.formValidator[_cont.formKeySelectBolim]!.text,
                          style: TextStyle(
                              color: Colors.red.shade900, fontSize: 12))
                      : const SizedBox(),
                  const SizedBox(height: 20.0),
                  !widget.yangimi
                      ? const SizedBox()
                      : TextFormField(
                          controller: _cont.balansController,
                          decoration: InputDecoration(
                            labelText: "Haqqi:",
                            labelStyle: const TextStyle(fontSize: 16),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          validator: (value) => _cont.validate(value),
                          keyboardType: TextInputType.number,
                          inputFormatters: Global.doubleRegEx,
                          textAlign: TextAlign.center,
                        ),
                  widget.yangimi
                      ? const SizedBox(height: 20.0)
                      : const SizedBox(),
                  widget.yangimi
                      ? TextFormField(
                          controller: _cont.balansqController,
                          decoration: InputDecoration(
                            labelText: "Qarzi:",
                            labelStyle: const TextStyle(fontSize: 16),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          validator: (value) => _cont.validate(value),
                          keyboardType: TextInputType.number,
                          inputFormatters: Global.doubleRegEx,
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox(),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _cont.izohController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Izoh",
                      labelStyle: const TextStyle(fontSize: 16),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    validator: (value) => _cont.validate(value),
                  ),
                  const SizedBox(height: 50),
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
                  onPressed: () => _cont.save(),
                )),
              ),
            ),
          ],
        ));
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
