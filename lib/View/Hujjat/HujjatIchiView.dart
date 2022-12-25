import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatIchiCont.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/system/form.dart';

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
        hujjat = Hujjat(turi)
          ..turi = turi
          ..sana = today.millisecondsSinceEpoch,
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

  String _title = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
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
    );
  }

  static const double oraliqPadding = 12;
  Widget _body(context) {
    return Form(
      key: _cont.formKey,
      child: Material(
        color: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [Text(_title, style: MyTheme.h2), const SizedBox(width: 10),
                      statusBadge(_cont.object.status),],),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _raqamInput(),
                const SizedBox(height: oraliqPadding),
                _sanaTanla(),
                const SizedBox(height: oraliqPadding),
                _izohInput(),
                const SizedBox(height: 60),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  TextButton(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 30.0,
                      ),
                      child: Text("YOPISH"),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  widget.yangimi
                      ? const SizedBox()
                      : TextButton(
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text("Hujjat ichi"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      openHujjat(_cont.object)!,
                                ));
                          },
                        ),
                  const Spacer(),
                  ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 30.0,
                      ),
                      child: Text("SAQLASH"),
                    ),
                    onPressed: () async {
                      _cont.showLoading(text: "Saqlanmoqda");
                      await _cont.save(context);
                      _cont.hideLoading();
                    },
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _info(context) {
    final turi = HujjatTur.obyektlar[_cont.object.turi]!;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(10),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [Text(_title, style: MyTheme.h2), const SizedBox(width: 10),
                      statusBadge(_cont.object.status),],),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.all(20.0), children: [
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
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
                  _cont.object.trKont == 0
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 7.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                children: [
                                  Text("Hujjat ", style: MyTheme.infoText),
                                  Text(
                                      " ${HujjatTur.obyektlar[_cont.object.turi]!.nomi}"),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                ListTile(
                  title: const Text("Hujjat ichi"),
                  leading: const Icon(Icons.login),
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => openHujjat(_cont.object)!,
                        ));
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
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
                ListTile(
                  title: const Text("O'chirish",
                      style: TextStyle(color: Colors.red)),
                  leading: const Icon(Icons.delete, color: Colors.red),
                  onTap: () => _delete(context, _cont.object),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ]),
            ),
          ),
        ]),
      ),
      Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              TextButton(
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 30.0,
                  ),
                  child: Text("YOPISH"),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              widget.yangimi
                  ? const SizedBox()
                  : TextButton(
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Hujjat ichi"),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => openHujjat(_cont.object)!,
                            ));
                      },
                    ),
              const Spacer(),
            ],
          ),
        ),
      )
    ]);
  }

  /* Widgets ================= */

  Widget _raqamInput() {
    return TextFormField(
      controller: _cont.raqamController,
      decoration: InputDecoration(
        labelText: "Hujjat raqami",
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
      ],
      validator: (value) => _cont.validate(value, required: true),
    );
  }

  Widget _sanaTanla() {
    return Material(
      color: Theme.of(context).cardColor,
      shape: OutlineInputBorder(
        borderSide: BorderSide(
          color: (FormAlertType.danger ==
                  _cont.formValidator[_cont.formKeySelectDate]!.type)
              ? Colors.red.shade900
              : Colors.grey,
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
    );
  }

  Widget _izohInput() {
    return TextFormField(
      controller: _cont.izohController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: "Izoh",
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      validator: (value) => _cont.validate(value),
    );
  }

  /* Dialogs ================= */

  var focusDeleteYesBtn = FocusNode();
  _delete(BuildContext context, Hujjat element) {
    var paddingContext = context;
    showDialog<void>(
      context: context,
      builder: (context) {
        focusDeleteYesBtn.requestFocus();
        return AlertDialog(
          title: const Text("O'chirilsinmi?"),
          content: const Text(
              "O'chirmoqchi bo'lgan elementingizni qayta tiklab bo'lmaydi"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BEKOR', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              focusNode: focusDeleteYesBtn,
              onPressed: () async {
                Navigator.pop(context);
                Navigator.pop(paddingContext);
                _cont.showLoading();
                await element.delete();
                _cont.hideLoading();
              },
              child: const Text('O`CHIRILSIN'),
            ),
          ],
        );
      },
    );
  }

  /* Methods ================= */

  @override
  void initState() {
    if (widget.yangimi) {
      _title = "Yangi ${HujjatTur.obyektlar[widget.turi]!.nomi}";
    } else if (widget.infomi) {
      _title =
          "${HujjatTur.obyektlar[widget.turi]!.nomi} ${widget.hujjat.raqami}";
    } else {
      _title = "${HujjatTur.obyektlar[widget.turi]!.nomi} - tahrirlash";
    }
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }

  @override
  void dispose() {
    focusDeleteYesBtn.dispose();
    super.dispose();
  }
}
