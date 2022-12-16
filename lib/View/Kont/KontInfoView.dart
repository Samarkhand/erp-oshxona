import 'package:erp_oshxona/View/Kont/KontIchiView.dart';
import 'package:erp_oshxona/View/Kont/KontInfoCont.dart';
import 'package:erp_oshxona/Widget/card_amahsulot.dart';
import 'package:erp_oshxona/Widget/card_amaliyot.dart';
import 'package:erp_oshxona/Widget/card_aorder.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:url_launcher/url_launcher.dart';

class KontInfoView extends StatefulWidget {
  const KontInfoView(this.object, {Key? key}) : super(key: key);

  final Kont object;

  @override
  State<KontInfoView> createState() => _KontInfoViewState();
}

class _KontInfoViewState extends State<KontInfoView> {
  final KontInfoCont _cont = KontInfoCont();
  bool yuklanmoqda = false;

  int tanBolim = 0;
  int tanBolimTuri = 0;
  int tanHisob = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: SafeArea(
            child: Scaffold(
          appBar: _appBar(context, title: _cont.object.nomi),
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
        )));
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
      bottom: const TabBar(
        isScrollable: true,
        tabs: [
          Tab(text: "Ma'lumot"),
          Tab(text: "Mablag'"),
          Tab(text: "Xizmat"),
          Tab(text: "Mahsulot"),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            await _buildSearchField(context, setState);
            setState(() {
              _cont.amaliyotList;
              _cont.mahsulotList;
              _cont.orderList;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.question_mark_outlined),
          tooltip: "Sahifa bo'yicha qollanma",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return const QollanmaView(sahifa: 'kont_info');
              },
            ));
          },
        ),
      ],
    );
  }

  Widget _body(context) {
    return TabBarView(children: [
      _malumotTab(),
      _amaliyotTab(),
      _orderTab(),
      _mahsulotTab(),
    ]);
  }

  Widget _malumotTab() {
    TextStyle dataTS = const TextStyle(fontSize: 16);
    TextStyle titleTS =
        dataTS.copyWith(fontWeight: FontWeight.w700, fontSize: 15);
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Balansi", style: titleTS),
                      Text(sumFormat.format(_cont.object.balans),
                          style: MyTheme.h4.copyWith(
                              color: _cont.object.balans < 0
                                  ? Colors.red
                                  : Colors.blue)),
                    ],
                  ),
                  const Divider(thickness: 1.0),
                  Text("Nomi", style: titleTS),
                  Text(_cont.object.nomi, style: dataTS),
                  const SizedBox(height: 10.0),
                  Text("Telefon", style: titleTS),
                  _cont.object.tel == '' ? const SizedBox() : Row(children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var uri = Uri.parse("tel:${_cont.object.telKod}${_cont.object.tel}"); 
                        if(await canLaunchUrl(uri)){
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.phone, color: Colors.blue, size: 18),
                    ),
                    Text("${_cont.object.telKod} ${_cont.object.tel}", style: dataTS.copyWith(color: Colors.blue)),
                  ]),
                  const SizedBox(height: 10.0),
                  Text("Bo'lim", style: titleTS),
                  Text(KBolim.obyektlar[_cont.object.bolim]!.nomi,
                      style: dataTS),
                  const SizedBox(height: 10.0),
                  Text("Kiritilgan sana", style: titleTS),
                  Text(
                    "${dateFormat.format(_cont.object.vaqt)} ${hourMinuteFormat.format(_cont.object.vaqt)}",
                    style: dataTS.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text("Dasturga kiritilgan boshlang'ich balansi",
                      style: titleTS, softWrap: true),
                  Text(sumFormat.format(_cont.object.boshBalans),
                      style: dataTS.copyWith(
                          color: _cont.object.boshBalans < 0
                              ? Colors.red
                              : Colors.blue)),
                  const SizedBox(height: 10.0),
                  _cont.object.izoh == ""
                      ? const SizedBox()
                      : const Text("Qo'shimcha ma'lumot"),
                  Text(_cont.object.izoh, style: dataTS),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text("Tahrirlash"),
                    leading: const Icon(Icons.edit),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                KontIchiView.tahrir(_cont.object.tr)),
                      );
                      setState(() {
                        _cont.object;
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  ListTile(
                    title: const Text("O`chirish"),
                    leading: const Icon(Icons.delete),
                    onTap: () {
                      _delete(context, _cont.object);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
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

  Widget _orderTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(2),
            itemCount: _cont.orderList.length,
            itemBuilder: (BuildContext context, int index) {
              if (_cont.orderList.length > 1) {
                if (_cont.orderList.length + 1 == index) {
                  return const SizedBox(height: 60);
                }
              }
              return _cont.orderList[index] != null
                  ? AOrderCard(
                      _cont.orderList[index],
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

  Widget _mahsulotTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(2),
            itemCount: _cont.mahsulotList.length,
            itemBuilder: (BuildContext context, int index) {
              if (_cont.mahsulotList.length > 1) {
                if (_cont.mahsulotList.length + 1 == index) {
                  return const SizedBox(height: 60);
                }
              }
              return _cont.mahsulotList[index] != null
                  ? AMahsulotCard(
                      _cont.mahsulotList[index],
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

  _delete(BuildContext context, Kont element) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O`chirilsinmi?'),
        content: const Text(
            'O`chirmoqchi bo`lgan elementingizni qayta tiklab bo`lmaydi'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BEKOR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _cont.showLoading();
              await _cont.delete(element);
              _cont.hideLoading();
            },
            child: const Text('O`CHIRILSIN'),
          ),
        ],
      ),
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
                                  _cont.amaliyotList = Amaliyot.obyektlar.values
                                      .where((element) =>
                                          element.kont == _cont.object.tr)
                                      .toList();
                                  _cont.mahsulotList = AMahsulot
                                      .obyektlar.values
                                      .where((element) =>
                                          element.kont == _cont.object.tr)
                                      .toList();
                                  _cont.orderList = AOrder.obyektlar.values
                                      .where((element) =>
                                          element.kont == _cont.object.tr)
                                      .toList();
                                  Navigator.pop(context);
                                  setState(() => _cont.amaliyotList);
                                  setState(() => _cont.mahsulotList);
                                  setState(() => _cont.orderList);
                                  setState(() => _cont.sanaD =
                                      DateTime(today.year, today.month));
                                  setState(() => _cont.sanaG = DateTime(
                                      today.year,
                                      today.month,
                                      today.day,
                                      23,
                                      59,
                                      59));
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

                                  _cont.amaliyotList = _cont.amaliyotList
                                      .where((element) =>
                                          element.kont == _cont.object.tr &&
                                          (element.sana >=
                                                  _cont.sanaD
                                                      .millisecondsSinceEpoch &&
                                              element.sana <=
                                                  _cont.sanaG
                                                      .millisecondsSinceEpoch))
                                      .toList();
                                  setState(() => _cont.amaliyotList);

                                  _cont.mahsulotList =
                                      AMahsulot.obyektlar.values.toList();

                                  _cont.mahsulotList = _cont.mahsulotList
                                      .where((element) =>
                                          element.kont == _cont.object.tr &&
                                          (element.sana >=
                                                  _cont.sanaD
                                                      .millisecondsSinceEpoch &&
                                              element.sana <=
                                                  _cont.sanaG
                                                      .millisecondsSinceEpoch))
                                      .toList();
                                  setState(() => _cont.mahsulotList);

                                  _cont.orderList =
                                      AOrder.obyektlar.values.toList();

                                  _cont.orderList = _cont.orderList
                                      .where((element) =>
                                          element.kont == _cont.object.tr &&
                                          (element.sana >=
                                                  _cont.sanaD
                                                      .millisecondsSinceEpoch &&
                                              element.sana <=
                                                  _cont.sanaG
                                                      .millisecondsSinceEpoch))
                                      .toList();
                                  setState(() => _cont.mahsulotList);

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
