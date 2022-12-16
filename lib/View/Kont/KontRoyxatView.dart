import 'package:erp_oshxona/View/Kont/KontInfoView.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Kont/KontRoyxatCont.dart';
import 'package:erp_oshxona/View/Kont/KontIchiView.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:select_dialog/select_dialog.dart';

class KontRoyxatView extends StatefulWidget {
  const KontRoyxatView({Key? key}) : super(key: key);

  @override
  State<KontRoyxatView> createState() => _KontRoyxatViewState();
}

class _KontRoyxatViewState extends State<KontRoyxatView> {
  final KontRoyxatCont _cont = KontRoyxatCont();
  bool yuklanmoqda = false;
  bool nomiInput = false;
  int tanBolim = 0;
  final TextEditingController _searchQueryController = TextEditingController();

  late String _priority = 'Barchasi';
  final List<String> _prioritys = [
    'Barchasi',
    'Qarzdorlar -',
    'Haqdorlar +',
    'Qarz ham, haq ham emas'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, title: "Kontaktlar"),
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
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KontIchiView.yangi()),
            );
            await _cont.loadItems();
            setState(() {
              _cont.objectList;
            });
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
                return const QollanmaView(sahifa: 'kont');
              },
            ));
          },
        ),
      ],
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
    );
  }

  Widget _body(context) {
    List<Widget> list = [];
    num sumHaq = 0;
    num sumQarz = 0;
    for (var element in _cont.objectList) {
      list.add(_buildItem(context, element));
      if (element.balans > 0) {
        sumHaq += element.balans;
      } else {
        sumQarz += element.balans;
      }
    }

    return Column(
      children: [
        Material(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Kontaktlar qarzi", style: MyTheme.small),
                    Text(sumFormat.format(sumQarz.abs()),
                        style: MyTheme.h2.copyWith(color: Colors.red[700])),
                  ],
                ),
                Column(
                  children: [
                    Text("Kontaktlar haqi", style: MyTheme.small),
                    Text(sumFormat.format(sumHaq.abs()),
                        style: MyTheme.h2.copyWith(color: Colors.orange[700])),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(
                bottom: 75, top: 5, right: 10.0, left: 10.0),
            shrinkWrap: true,
            children: list,
          ),
        ),
      ],
    );
  }

  static const balansStyle = TextStyle(fontSize: 22, color: Colors.black);
  Widget _buildItem(BuildContext context, element) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      key: Key('Royhat el ${element.tr}'),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        title: Wrap(
          children: [
            Text(element.nomi),
            const SizedBox(width: 7.0),
          ],
        ),
        subtitle: Row(
          children: [
            _badgeBolim(element.bolim),
            const Expanded(child: SizedBox(width: 7.0)),
            Text(
              sumFormat.format(element.balans),
              style: balansStyle,
            ),
          ],
        ),
        onTap: () => _openItemActionDialog(context, element),
      ),
    );
  }

  Widget _badgeBolim(int tr) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: KBolim.obyektlar[tr]!.color,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 16,
      ),
      child: Wrap(
        children: [
          Icon(KBolim.obyektlar[tr]!.icon, size: 16, color: Colors.white),
          const SizedBox(width: 7.0),
          Text(
            KBolim.obyektlar[tr]!.nomi,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  void _openItemActionDialog(BuildContext context, element) {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Kontaktni tanlash'),
        children: [
          ListTile(
            title: const Text("Malumot"),
            leading: const Icon(Icons.info),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KontInfoView(element)),
              );
              setState(() {
                element;
              });
            },
          ),
          ListTile(
            title: const Text("Tahrirlash"),
            leading: const Icon(Icons.edit),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => KontIchiView.tahrir(element.tr)),
              );
              setState(() {
                element;
              });
            },
          ),
          ListTile(
            title: const Text("O`chirish"),
            leading: const Icon(Icons.delete),
            onTap: () {
              Navigator.pop(context);
              _delete(context, element);
            },
          ),
        ],
      ),
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

  Future _buildSearchField(context, StateSetter setState) async {
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
                  SingleChildScrollView(
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
                        TextFormField(
                          controller: _searchQueryController,
                          autofocus: true,
                          decoration: InputDecoration(
                            label: const Text("Nomi / Ismi"),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            suffixIcon: nomiInput
                                ? IconButton(
                                    onPressed: () {
                                      if (_searchQueryController.text.isEmpty) {
                                        setState(() => nomiInput = true);
                                      } else {
                                        setState(() => nomiInput = false);
                                        setState(() =>
                                            _searchQueryController.text = '');
                                      }
                                    },
                                    icon: const Icon(Icons.close),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() => nomiInput = false);
                            } else {
                              setState(() => nomiInput = true);
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField(
                          icon: const Icon(Icons.arrow_drop_down),
                          decoration: const InputDecoration(
                            labelText: "Balansi",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          onChanged: (value) {
                            setState(() => _priority = value.toString());
                          },
                          items: _prioritys.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          value: _priority,
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
                              padding: const EdgeInsets.all(15),
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
                                            " ${KBolim.obyektlar[tanBolim]!.nomi}"),
                                        const Expanded(child: SizedBox()),
                                        TextButton(
                                          onPressed: () =>
                                              setState(() => tanBolim = 0),
                                          child: const Icon(Icons.close,
                                              size: 27, color: Colors.black),
                                        ),
                                      ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
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
                                onPressed: () => setState(() {
                                  _cont.objectList =
                                      Kont.obyektlar.values.toList();
                                  Navigator.pop(context);
                                  setState(() => _cont.objectList);
                                  setState(() => tanBolim = 0);
                                  setState(() => _priority = 'Barchasi');
                                  setState(
                                      () => _searchQueryController.text = '');
                                  setState(() => nomiInput = false);
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
                                onPressed: () {
                                  _cont.objectList =
                                      Kont.obyektlar.values.toList();

                                  if (_priority.isNotEmpty) {
                                    if (_priority == 'Qarzdorlar -') {
                                      _cont.objectList = _cont.objectList
                                          .where(
                                              (element) => element.balans < 0)
                                          .toList();
                                    }
                                    if (_priority == 'Haqdorlar +') {
                                      _cont.objectList = _cont.objectList
                                          .where(
                                              (element) => element.balans > 0)
                                          .toList();
                                    }
                                    if (_priority == 'Qarz ham, haq ham emas') {
                                      _cont.objectList = _cont.objectList
                                          .where(
                                              (element) => element.balans == 0)
                                          .toList();
                                    }
                                    if (_priority == 'Barchasi') {
                                      _cont.objectList =
                                          _cont.objectList.toList();
                                    }
                                  }

                                  if (tanBolim != 0) {
                                    _cont.objectList = _cont.objectList
                                        .where((element) =>
                                            element.bolim == tanBolim)
                                        .toList();
                                  }
                                  if (_searchQueryController.text.isEmpty ==
                                      false) {
                                    _cont.objectList = _cont.objectList
                                        .where((element) => element.nomi
                                            .toLowerCase()
                                            .contains(_searchQueryController
                                                .text
                                                .toLowerCase()))
                                        .toList();
                                  }
                                  setState(() => _cont.objectList);

                                  Navigator.pop(context);
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

  saqlashTuriTanlash(context, StateSetter setState) {
    SelectDialog.showModal<KBolim>(
      context,
      label: "Bo'lim tanlang",
      selectedValue: KBolim.obyektlar[tanBolim],
      items: KBolim.obyektlar.values.toList(),
      onChange: (selected) {
        setState(() => tanBolim = selected.tr);
      },
      searchBoxDecoration: const InputDecoration(hintText: "Izlash"),
    );
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
