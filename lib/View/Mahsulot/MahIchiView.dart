import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Mahsulot/MahIchiCont.dart';
import 'package:erp_oshxona/View/Mahsulot/MahsulotIchiView.dart';
import 'package:erp_oshxona/Widget/card_amaliyot.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MahIchiView extends StatefulWidget {
  MahIchiView(this.object, {Key? key})
      : infomi = true,
        super(key: key) {
    turi = object.turi;
  }
  MahIchiView.tahrir(this.object, {Key? key}) : super(key: key) {
    turi = object.turi;
  }
  MahIchiView.yangi(this.turi, {Key? key})
      : yangimi = true,
        object = Mahsulot()..turi = turi,
        super(key: key);
  int turi = 0;
  late Mahsulot object;
  bool yangimi = false;
  bool infomi = false;

  @override
  State<MahIchiView> createState() => _MahIchiViewState();
}

class _MahIchiViewState extends State<MahIchiView> {
  final MahIchiCont _cont = MahIchiCont();
  bool yuklanmoqda = false;

  AppBar? _appBarInfo(BuildContext context, {String? title}) {
    return AppBar(
      title: Text(
        (_cont.isLoading)
            ? _cont.loadingLabel
            : title ??
                (widget.yangimi
                    ? "Yangi maxsulot"
                    : widget.infomi
                        ? _cont.object.nomi
                        : "Tahrirlash: ${_cont.object.nomi}"),
      ),
      bottom: TabBar(
        isScrollable: true,
        tabs: [
              const Tab(text: "Ma'lumot"),
              const Tab(text: "Kirim"),
              const Tab(text: "Chiqim"),
            ] +
            (widget.turi == MTuri.mahsulot.tr
                ? [const Tab(text: "Tarkib")]
                : []),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.turi == MTuri.mahsulot.tr ? 4 : 3,
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
    List<Widget> tabs = [
      _infoTab(),
      _amaliyotTab(),
      _transTab(),
    ];
    if (widget.turi == MTuri.mahsulot.tr) tabs.add(_tarkibTab());
    return TabBarView(children: tabs);
  }

  Widget _infoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_cont.object.nomi, style: MyTheme.d3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0, top: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Turi", style: MyTheme.infoText),
                          Text(_cont.object.mTuri.nomi),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Bo'lim", style: MyTheme.infoText),
                          Text(_cont.object.mBolim.nomi),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Brend", style: MyTheme.infoText),
                          Text(_cont.object.mBrend.nomi),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Wrap(
                        children: [
                          _cont.object.tanlangan
                              ? const Text("Tanlangan maxsulot")
                              : const SizedBox(),
                          _cont.object.tanlangan &&
                                  (_cont.object.tarozimi ||
                                      _cont.object.komplektmi)
                              ? const Text(",")
                              : const SizedBox(),
                          _cont.object.tanlangan
                              ? const SizedBox(width: 7.0)
                              : const SizedBox(),
                          _cont.object.tarozimi
                              ? const Text("Tarozida o'lchanadi")
                              : const SizedBox(),
                          _cont.object.tarozimi && _cont.object.komplektmi
                              ? const Text(",")
                              : const SizedBox(),
                          _cont.object.tarozimi
                              ? const SizedBox(width: 7.0)
                              : const SizedBox(),
                          _cont.object.komplektmi
                              ? const Text("Komplekt sotiladi")
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Qoldiq", style: MyTheme.infoText),
                          _cont.object.mQoldiq != null
                              ? Text(
                                  "${sumFormat.format(_cont.object.mQoldiq!.qoldi)} ${_cont.object.mOlchov.nomi}",
                                  style: MyTheme.h4,
                                )
                              : Text(
                                  "${sumFormat.format(0)} ${_cont.object.mOlchov.nomi}",
                                  style: MyTheme.h4,
                                ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Oy davomida sotildi", style: MyTheme.infoText),
                          _cont.object.mQoldiq != null
                              ? Text(
                                  "${sumFormat.format(_cont.object.mQoldiq!.sotildi)} ${_cont.object.mOlchov.nomi}",
                                )
                              : Text(
                                  "${sumFormat.format(0)} ${_cont.object.mOlchov.nomi}",
                                ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sotilish narxi", style: MyTheme.infoText),
                          Text(
                            _cont.object.mQoldiq != null
                                ? sumFormat
                                    .format(_cont.object.mQoldiq!.sotnarxi)
                                : sumFormat.format(0),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("So'nggi kirim narxi", style: MyTheme.infoText),
                          Text(
                            _cont.object.mQoldiq != null
                                ? sumFormat
                                    .format(_cont.object.mQoldiq!.tannarxi)
                                : sumFormat.format(0),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Qoldiq tannarxi", style: MyTheme.infoText),
                          Text(
                            _cont.object.mQoldiq != null
                                ? sumFormat
                                    .format(_cont.object.mQoldiq!.sumTannarxi)
                                : sumFormat.format(0),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10.0),
        Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tartib raqami", style: MyTheme.infoText),
                      Text(_cont.object.tr.toString()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Kiritilgan sana", style: MyTheme.infoText),
                      Text(dateFormat.format(_cont.object.vaqtDT)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Songgi o'zgargan vaqt", style: MyTheme.infoText),
                      Text(dateTimeFormat.format(_cont.object.vaqtSDT)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        _tanlanganCheck(),
        const SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text("Tahrirlash"),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MahsulotIchiView.tahrir(_cont.object.tr)),
                        );
                        setState(() {
                          /*widget.infomi = false;
                        widget.yangimi = false;*/
                          _cont.object;
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("O'chirish"),
                    onTap: () async {
                      // TODO: shart bilan o'chirilsin
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
            ),
          ],
        ),
      ]),
    );
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

  Widget _tarkibTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Card(
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
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _tarkiblarRoyxati(),
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
    for (var object in _cont.homAshyoList) {
      royxat.add(
        Material(
          child: InkWell(
            onDoubleTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(object.nomi + " ${object.nomi}"),
                  Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(3),
                        onTap: () {},
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
    return [
      TextFormField(),
      Expanded(
          child: ListView(
        children: royxat,
      )),
    ];
  }

  List<Widget> _tarkiblarRoyxati() {
    List<Widget> royxat = [];
    return royxat;
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
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
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
                                    Text(" ${dateFormat.format(_cont.sanaD)}"),
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
                                    Text(" ${dateFormat.format(_cont.sanaG)}"),
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
                            setState(() => _cont.sanaG = DateTime(today.year,
                                today.month, today.day, 23, 59, 59));

                            _cont.amaliyotList = Amaliyot.obyektlar.values
                                .where(
                                  (element) =>
                                      element.hisob == _cont.object.tr &&
                                      (element.turi != AmaliyotTur.transM.tr &&
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
                            _cont.amaliyotListT = Amaliyot.obyektlar.values
                                .where(
                                  (element) =>
                                      element.hisob == _cont.object.tr &&
                                      (element.turi == AmaliyotTur.transM.tr ||
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
                                      (element.turi != AmaliyotTur.transM.tr &&
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
                                      (element.turi == AmaliyotTur.transM.tr ||
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
        Mahsulot.service!.update({"tanlangan": _cont.object.tanlangan ? 1 : 0},
            where: " tr='${_cont.object.tr}'");
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
        Mahsulot.service!.update({"tarozimi": _cont.object.tarozimi ? 1 : 0},
            where: " tr='${_cont.object.tr}'");
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
        Mahsulot.service!.update(
            {"komplektmi": _cont.object.komplektmi ? 1 : 0},
            where: " tr='${_cont.object.tr}'");
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
