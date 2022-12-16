import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatRoyxatCont.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatIchiView.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:select_dialog/select_dialog.dart';

class HujjatRoyxatView extends StatefulWidget {
  const HujjatRoyxatView({Key? key, this.turi}) : super(key: key);

  final HujjatTur? turi;

  @override
  State<HujjatRoyxatView> createState() => _HujjatRoyxatViewState();
}

class _HujjatRoyxatViewState extends State<HujjatRoyxatView> {
  final HujjatRoyxatCont _cont = HujjatRoyxatCont();
  bool yuklanmoqda = false;

  int tanBolim = 0;
  int tanKont = 0;
  int turi = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, title: widget.turi?.nomi ?? "Hujjatlar" ),
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
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            await _dialogYangiHujjat(context);
          }),
    );
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            await _buildSearchField(context, setState);
            setState(() {
              _cont.objectList;
            });
          },
        ),
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
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
    );
  }

  Widget _body(context) {
    /*List<Widget> list = [];
    for (var element in _cont.objectList) {
      list.add(_buildItem(context, element));
    }*/

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(2),
            itemCount: _cont.objectList.length,
            itemBuilder: (BuildContext context, int index) {
              if (_cont.objectList.length + 1 == index) {
                return const SizedBox(height: 60);
              }
              return HujjatCard(
                _cont.objectList[index],
                cont: _cont,
                doAfterDelete: _cont.loadFromGlobal,
              );
            },
            /*separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 1,
            ),*/
            //children: list,
          ),
        ),
      ],
    );
  }

  _dialogYangiHujjat(BuildContext context) {
    if (!Global.ruhsatBormi) {
      return;
    }
    return showDialog(
        context: context,
        builder: (context) {
          List<Widget> list = [];
          for (var element in HujjatTur.obyektlar.values.toList()) {
            list.add(ListTile(
              leading: Icon(
                element.icon,
                color: element.ranggi,
              ),
              title:
                  Text(element.nomi, style: TextStyle(color: element.ranggi)),
              onTap: () async {
                Navigator.of(context).pop(0);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HujjatIchiView.yangi(element.tr)),
                );
                await _cont.loadFromGlobal();
                setState(() {
                  _cont.objectList;
                });
              },
            ));
          }
          return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            title: const Text("Yangi qayd kiritish"),
            children: <Widget>[const SizedBox(height: 10.0)] +
                list +
                <Widget>[
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.only(right: 20.0, bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                            child: Text(
                              "Qaytish".toUpperCase(),
                              style: const TextStyle(color: Colors.black38),
                            ),
                            //color: Theme.of(context).buttonColor,
                            onPressed: () {
                              Navigator.of(context).pop(0);
                            }),
                      ],
                    ),
                  ),
                ],
          );
        });
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
                            ],
                          ),
                          const SizedBox(height: 15),
                          Material(
                            color: Colors.tealAccent,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                turiTanlash(context, setState);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                    children: turi == 0
                                        ? [
                                            const Icon(Icons.layers,
                                                color: Colors.black87),
                                            const Text(
                                                " Amaliyot turini tanlang"),
                                          ]
                                        : [
                                            Icon(
                                              Icons.layers,
                                              color: HujjatTur
                                                  .obyektlar[turi]!.ranggi,
                                            ),
                                            Text(
                                              " ${HujjatTur.obyektlar[turi]!.nomi}",
                                              style: TextStyle(
                                                color: HujjatTur
                                                    .obyektlar[turi]!.ranggi,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Expanded(child: SizedBox()),
                                            TextButton(
                                              onPressed: () =>
                                                  setState(() => turi = 0),
                                              child: const Icon(
                                                Icons.close,
                                                size: 25,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Material(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                saqlashTuriTanlash(context, setState);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                    children: tanBolim == 0
                                        ? [
                                            const Icon(Icons.folder,
                                                color: Colors.black87),
                                            const Text(" Bo'limini tanlang"),
                                          ]
                                        : [
                                            const Icon(Icons.folder),
                                            Text(
                                                " ${ABolim.obyektlar[tanBolim]!.nomi}"),
                                            const Expanded(child: SizedBox()),
                                            TextButton(
                                                onPressed: () => setState(
                                                    () => tanBolim = 0),
                                                child: const Icon(Icons.close,
                                                    size: 25,
                                                    color: Colors.black)),
                                          ]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Material(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                kontTanlash(context, setState);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                    children: tanKont == 0
                                        ? [
                                            const Icon(Icons.person,
                                                color: Colors.black87),
                                            const Text(" Kontakt tanlang"),
                                          ]
                                        : [
                                            const Icon(Icons.person),
                                            Text(
                                                " ${Kont.obyektlar[tanKont]!.nomi}"),
                                            const Expanded(child: SizedBox()),
                                            TextButton(
                                                onPressed: () =>
                                                    setState(() => tanKont = 0),
                                                child: const Icon(Icons.close,
                                                    size: 25,
                                                    color: Colors.black)),
                                          ]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
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
                                  //_cont.objectList = Hujjat.obyektlar.toList();

                                  Navigator.pop(context);
                                  setState(() => _cont.objectList);
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

                                  //_cont.objectList = Hujjat.obyektlar.toList();

                                  _cont.objectList = _cont.objectList
                                      .where((element) =>
                                          element.sana >=
                                              _cont.sanaD
                                                  .millisecondsSinceEpoch &&
                                          element.sana <=
                                              _cont
                                                  .sanaG.millisecondsSinceEpoch)
                                      .toList();
                                  if (tanKont != 0) {
                                    _cont.objectList = _cont.objectList
                                        .where((element) =>
                                            element.kont == tanKont)
                                        .toList();
                                  }
                                  if (tanBolim != 0) {
                                    _cont.objectList = _cont.objectList
                                        .where((element) =>
                                            element.bolim == tanBolim)
                                        .toList();
                                  }
                                  if (turi != 0) {
                                    _cont.objectList = _cont.objectList
                                        .where((element) =>
                                            element.turi == turi)
                                        .toList();
                                  }
                                  setState(() => _cont.objectList);

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

  saqlashTuriTanlash(BuildContext context, StateSetter setState) {
    SelectDialog.showModal<ABolim>(
      context,
      label: "Bo'lim tanlang",
      selectedValue: ABolim.obyektlar[tanBolim],
      items: ABolim.obyektlar.values
          .where((element) => element.turi == ABolimTur.mahsulot.tr)
          .toList(),
      onChange: (selected) {
        setState(() => tanBolim = selected.tr);
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }

  kontTanlash(BuildContext context, StateSetter setState) {
    SelectDialog.showModal<Kont>(
      context,
      label: "Kontakt tanlang",
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      selectedValue: Kont.obyektlar[tanKont],
      items: Kont.obyektlar.values.toList(),
      onChange: (selected) {
        setState(() => tanKont = selected.tr);
      },
      itemBuilder: (context, object, selected) => ListTile(
        title: Text(object.nomi),
        trailing: Text(sumFormat.format(object.balans)),
      ),
    );
  }

  turiTanlash(BuildContext context, StateSetter setState) {
    SelectDialog.showModal<HujjatTur>(
      context,
      label: "Amaliyot turini tanlang",
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      selectedValue: HujjatTur.obyektlar[turi],
      items: HujjatTur.obyektlar.values.toList(),
      onChange: (selected) {
        setState(() => turi = selected.tr);
      },
      itemBuilder: (context, object, selected) => ListTile(
        title: Text(
          object.nomi,
          style: TextStyle(
            color: object.ranggi,
            fontWeight: FontWeight.bold,
          ),
        ),
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
