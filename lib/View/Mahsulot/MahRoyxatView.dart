import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/View/Mahsulot/MahIchiView.dart';
import 'package:erp_oshxona/View/Mahsulot/MahRoyxatCont.dart';
import 'package:erp_oshxona/View/Mahsulot/MahsulotIchiView.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:select_dialog/select_dialog.dart';

class MahRoyxatView extends StatefulWidget {
  const MahRoyxatView({Key? key, this.turi}) : super(key: key);

  final MTuri? turi;

  @override
  State<MahRoyxatView> createState() => _MahRoyxatViewState();
}

class _MahRoyxatViewState extends State<MahRoyxatView> {
  final MahRoyxatCont _cont = MahRoyxatCont();
  bool yuklanmoqda = false;

  int tanBolim = 0;
  int tanKont = 0;
  int turi = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, title: widget.turi?.nomi ?? "Maxsulotlar ro'yxati"),
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
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const QollanmaView(sahifa: 'mahsulot');
                },
              ),
            );
          },
        ),
      ],
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
    );
  }

  Widget _body(context) {
    return Column(
      children: [
        Material(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: OutlinedButton(
                          onPressed: () => _cont.sarala(Sarala.barchasi),
                          child: const Text("Barchasi")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: OutlinedButton(
                          onPressed: () => _cont.sarala(Sarala.borlar),
                          child: const Text("Qolganlar")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: OutlinedButton(
                          onPressed: () => _cont.sarala(Sarala.yoqlar),
                          child: const Text("Qolmaganlar")),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Yangi"),
                    onPressed: () async {
                      var value = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MahsulotIchiView.yangi(widget.turi ?? MTuri.mahsulot)),
                      );
                      setState(() {
                        _cont.objectList.add(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _cont.objectList.length,
            itemBuilder: (BuildContext context, int index) =>
                _buildItem(context, index),
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

  _buildItem(BuildContext context, int index) {
    if (_cont.objectList.length + 1 == index) {
      return const SizedBox(height: 60);
    }
    Mahsulot obj = _cont.objectList[index];
    MahQoldiq? objQoldiq = MahQoldiq.obyektlar[obj.tr];
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(obj.nomi),
      subtitle: objQoldiq != null && objQoldiq.qoldi != 0
          ? Text("${objQoldiq.qoldi} ${obj.mOlchov.nomi}")
          : Text("0 ${obj.mOlchov.nomi}",
              style: const TextStyle(color: Colors.redAccent)),
      trailing:
          objQoldiq != null ? Text(sumFormat.format(objQoldiq.sotnarxi)) : null,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MahIchiView(obj),
          ),
        );
        setState(() {
          _cont.loadItems();
        });
      },
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
                                              color: AMahsulotTur
                                                  .obyektlar[turi]!.ranggi,
                                            ),
                                            Text(
                                              " ${AMahsulotTur.obyektlar[turi]!.nomi}",
                                              style: TextStyle(
                                                color: AMahsulotTur
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
                                onPressed: () => setState(() {}),
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
    SelectDialog.showModal<AMahsulotTur>(
      context,
      label: "Amaliyot turini tanlang",
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
      selectedValue: AMahsulotTur.obyektlar[turi],
      items: AMahsulotTur.obyektlar.values.toList(),
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
