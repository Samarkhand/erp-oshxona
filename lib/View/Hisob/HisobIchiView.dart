import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Widget/card_amaliyot.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/static/tTuri.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Hisob/HisobIchiCont.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/static/mablag.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HisobIchiView extends StatefulWidget {
  HisobIchiView(this.tr, {Key? key})
      : infomi = true,
        super(key: key) {
    turi = Hisob.obyektlar[tr]!.turi;
  }
  HisobIchiView.tahrir(this.tr, {Key? key}) : super(key: key) {
    turi = Hisob.obyektlar[tr]!.turi;
  }
  HisobIchiView.yangi(this.turi, {Key? key})
      : yangimi = true,
        super(key: key);
  int turi = 0;
  int tr = 0;
  bool yangimi = false;
  bool infomi = false;

  @override
  State<HisobIchiView> createState() => _HisobIchiViewState();
}

class _HisobIchiViewState extends State<HisobIchiView> {
  final HisobIchiCont _cont = HisobIchiCont();
  bool yuklanmoqda = false;

  @override
  Widget build(BuildContext context) {
    return widget.infomi
        ? _bodyInfo(context)
        : SafeArea(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            tooltip: "Sahifa bo'yicha qollanma",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const QollanmaView(sahifa: 'hisob');
                },
              ));
            },
          ),
        ],
        title: Text((_cont.isLoading)
            ? _cont.loadingLabel
            : title ??
                (widget.yangimi
                    ? "Yangi hisob"
                    : widget.infomi
                        ? _cont.object.nomi
                        : "Tahrirlash: ${_cont.object.nomi}")));
  }

  AppBar? _appBarInfo(BuildContext context, {String? title}) {
    return AppBar(
      title: Text(
        (_cont.isLoading)
            ? _cont.loadingLabel
            : title ??
                (widget.yangimi
                    ? "Yangi hisob"
                    : widget.infomi
                        ? _cont.object.nomi
                        : "Tahrirlash: ${_cont.object.nomi}"),
      ),
      bottom: const TabBar(
        isScrollable: true,
        tabs: [
          Tab(text: "Ma'lumot"),
          Tab(text: "Amaliyot"),
          Tab(text: "Tranzaksiya"),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            await _buildSearchField(context, setState);
            setState(() {
              _cont.amaliyotList;
              _cont.amaliyotListT;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.question_mark_outlined),
          tooltip: "Sahifa bo'yicha qollanma",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return const QollanmaView(sahifa: 'hisob');
              },
            ));
          },
        ),
      ],
    );
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
                  autofocus: true,
                  controller: _cont.nomiController,
                  decoration: InputDecoration(
                    labelText: "Nomi:",
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  validator: (value) => _cont.validate(value, required: true),
                ),
                const SizedBox(height: 20.0),
                !widget.yangimi
                    ? const SizedBox()
                    : TextFormField(
                        decoration: InputDecoration(
                          labelText: "Boshlang'ich balansi",
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
                            _cont.validate(context, required: true),
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          if (value != "") {
                            _cont.object.balans = num.parse(value);
                          } else {
                            _cont.object.balans = 0;
                          }
                        },
                        validator: (value) =>
                            _cont.validate(value, required: true),
                      ),
                !widget.yangimi
                    ? const SizedBox()
                    : const SizedBox(height: 20.0),
                Material(
                  color: _cont.object.saqlashTuri != 0
                      ? Color(MablagSaqlashTuri
                              .obyektlar[_cont.object.saqlashTuri]!.color)
                          .withOpacity(1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _cont.saqlashTuriTanlash(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                          children: _cont.object.saqlashTuri == 0
                              ? [
                                  const Text("Saqlash turini tanlang"),
                                ]
                              : [
                                  Icon(
                                      MablagSaqlashTuri
                                          .obyektlar[_cont.object.saqlashTuri]!
                                          .icon,
                                      color: Colors.white),
                                  Text(
                                    " ${MablagSaqlashTuri.obyektlar[_cont.object.saqlashTuri]!.nomi}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ]),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: const Text("Asosiy oynada ko'rinsin"),
                    value: _cont.object.abh,
                    onChanged: (value) {
                      setState(() {
                        _cont.object.abh = !_cont.object.abh;
                      });
                      Hisob.service!.update({"abh": _cont.object.abh ? 1 : 0},
                          where: " tr='${_cont.object.tr}'");
                    },
                  ),
                ),
                const SizedBox(height: 60),
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
      ),
    );
  }

  Widget _bodyInfo(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: _appBarInfo(context, title: _cont.object.nomi),
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
              : _info(context),
        ),
      ),
    );
  }

  Widget _info(context) {
    return TabBarView(children: [
      SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    _cont.object.nomi,
                    style: MyTheme.h4.copyWith(color: _cont.object.color),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Qoldiq balansi", style: MyTheme.infoText),
                        Text(sumFormat.format(_cont.object.balans),
                            style: MyTheme.h4),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mablag' saqlash turi", style: MyTheme.infoText),
                        Text(SaqlashTuri
                            .obyektlar[_cont.object.saqlashTuri]!.nomi),
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
            child: SwitchListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text("Asosiy oynada ko'rinsin"),
              value: _cont.object.abh,
              onChanged: (value) {
                logConsole("tr='${_cont.object.tr}'");
                setState(() {
                  _cont.object.abh = !_cont.object.abh;
                });
                Hisob.service!.update({"abh": _cont.object.abh ? 1 : 0},
                    where: " tr='${_cont.object.tr}'");
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
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
      ),
      _amaliyotTab(),
      _transTab(),
    ]);
  }

  Widget _amaliyotTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(2),
            itemCount: _cont.amaliyotList.length,
            itemBuilder: (BuildContext context, int index) {
              if (_cont.amaliyotList.length > 1) {}
              return _cont.amaliyotList[index] != null
                  ? AmaliyotCard(
                      _cont.amaliyotList[index],
                      cont: _cont,
                      doAfterDelete: _cont.loadFromGlobal,
                    )
                  : const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _transTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(2),
            itemCount: _cont.amaliyotListT.length,
            itemBuilder: (BuildContext context, int index) {
              if (_cont.amaliyotListT.length > 1) {}
              return _cont.amaliyotListT[index] != null
                  ? AmaliyotCard(
                      _cont.amaliyotListT[index],
                      cont: _cont,
                      doAfterDelete: _cont.loadFromGlobal,
                    )
                  : const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  _buildSearchField(context, StateSetter setState) async {
    return await showMaterialModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Material(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Saralash', style: MyTheme.h3),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      onTap: () =>
                                          _cont.sanaTanlashD(context, setState),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(children: [
                                          const Icon(Icons.date_range),
                                          Text(
                                              " ${dateFormat.format(_cont.sanaD)}"),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      onTap: () =>
                                          _cont.sanaTanlashG(context, setState),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(children: [
                                          const Icon(Icons.date_range),
                                          Text(
                                              " ${dateFormat.format(_cont.sanaG)}"),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                          const SizedBox(height: 15),
                          const SizedBox(height: 15),
                          Row(children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Text("Bekor qilish"),
                                ),
                                onPressed: () => setState(() {
                                  setState(() => _cont.sanaD =
                                      DateTime(today.year, today.month));
                                  setState(() => _cont.sanaG = DateTime(
                                      today.year,
                                      today.month,
                                      today.day,
                                      23,
                                      59,
                                      59));

                                  _cont.amaliyotList = Amaliyot.obyektlar.values
                                      .where(
                                        (element) =>
                                            element.hisob == _cont.object.tr &&
                                            (element.turi !=
                                                    AmaliyotTur.transM.tr &&
                                                element.turi !=
                                                    AmaliyotTur.transP.tr) &&
                                            (element.sana >=
                                                    _cont.sanaD
                                                        .millisecondsSinceEpoch &&
                                                element.sana <=
                                                    _cont.sanaG
                                                        .millisecondsSinceEpoch),
                                      )
                                      .toList();
                                  _cont.amaliyotListT = Amaliyot
                                      .obyektlar.values
                                      .where(
                                        (element) =>
                                            element.hisob == _cont.object.tr &&
                                            (element.turi ==
                                                    AmaliyotTur.transM.tr ||
                                                element.turi ==
                                                    AmaliyotTur.transP.tr) &&
                                            (element.sana >=
                                                    _cont.sanaD
                                                        .millisecondsSinceEpoch &&
                                                element.sana <=
                                                    _cont.sanaG
                                                        .millisecondsSinceEpoch),
                                      )
                                      .toList();
                                  Navigator.pop(context);
                                  setState(() => _cont.amaliyotList);
                                  setState(() => _cont.amaliyotListT);
                                }),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Text("Saralash"),
                                ),
                                onPressed: () async {
                                  await _cont.loadItems();

                                  _cont.amaliyotList =
                                      Amaliyot.obyektlar.values.toList();

                                  _cont.amaliyotListT =
                                      Amaliyot.obyektlar.values.toList();

                                  _cont.amaliyotList = _cont.amaliyotList
                                      .where(
                                        (element) =>
                                            element.hisob == _cont.object.tr &&
                                            (element.turi !=
                                                    AmaliyotTur.transM.tr &&
                                                element.turi !=
                                                    AmaliyotTur.transP.tr) &&
                                            (element.sana >=
                                                    _cont.sanaD
                                                        .millisecondsSinceEpoch &&
                                                element.sana <=
                                                    _cont.sanaG
                                                        .millisecondsSinceEpoch),
                                      )
                                      .toList();

                                  _cont.amaliyotListT = _cont.amaliyotListT
                                      .where(
                                        (element) =>
                                            element.hisob == _cont.object.tr &&
                                            (element.turi ==
                                                    AmaliyotTur.transM.tr ||
                                                element.turi ==
                                                    AmaliyotTur.transP.tr) &&
                                            (element.sana >=
                                                    _cont.sanaD
                                                        .millisecondsSinceEpoch &&
                                                element.sana <=
                                                    _cont.sanaG
                                                        .millisecondsSinceEpoch),
                                      )
                                      .toList();
                                  setState(() => _cont.amaliyotList);
                                  setState(() => _cont.amaliyotListT);

                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ]),
                          const SizedBox(height: 3),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ));
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
