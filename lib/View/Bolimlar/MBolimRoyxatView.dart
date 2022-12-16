import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Bolimlar/MBolimRoyxatCont.dart';
import 'package:erp_oshxona/View/Bolimlar/MBolimIchiView.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/View/asosiy_cont.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';

class MBolimRoyxatView extends StatefulWidget {
  const MBolimRoyxatView({Key? key, this.turi}) : super(key: key);

  final MTuri? turi;

  @override
  State<MBolimRoyxatView> createState() => _MBolimRoyxatViewState();
}

class _MBolimRoyxatViewState extends State<MBolimRoyxatView> {
  final MBolimRoyxatCont _cont = MBolimRoyxatCont();
  bool yuklanmoqda = false;
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context, title: "Kontakt bolimlar"),
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
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MBolimIchiView.yangi(0)),
              );
              await _cont.loadItems();
              setState(() {
                _cont.objectList;
              });
            }),
      ),
    );
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
      actions: _buildActions(),
      title: _isSearching
          ? _buildSearchField()
          : Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
    );
  }

  Widget _body(context) {
    List<Widget> list = [];
    num sumHaq = 0;
    num sumQarz = 0;
    for (var element in _cont.objectList) {
      list.add(_buildItem(context, element));
      sumHaq += element.sumHaq;
      sumQarz += element.sumQarz;
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await AsosiyCont.kBolimBalansYangila();
            },
            child: ReorderableListView(
              padding: const EdgeInsets.only(bottom: 75, top: 5),
              shrinkWrap: true,
              children: list,
              proxyDecorator: (widget, i, anim) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: widget,
                );
              },
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Object item = _cont.objectList.removeAt(oldIndex);
                  _cont.objectList.insert(newIndex, item);
                });
                int n = 0;
                for (MBolim object in _cont.objectList) {
                  n++;
                  object.tartib = n;
                  MBolim.service!
                      .update({'tartib': n}, where: "tr=${object.tr}");
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, element) {
    return Card(
      key: Key('Royhat el ${element.tr}'),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(element.nomi, style: MyTheme.h5),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Qarzi", style: MyTheme.small),
                        Text(sumFormat.format(element.sumQarz),
                            style: MyTheme.h6.copyWith(
                                color: Colors.red[700],
                                fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Haqi", style: MyTheme.small),
                        Text("+${sumFormat.format(element.sumHaq)}",
                            style: MyTheme.h6.copyWith(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () => _openItemActionDialog(context, element),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Saralash...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.8)),
      ),
      style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor, fontSize: 16.0),
      cursorColor: Theme.of(context).appBarTheme.foregroundColor,
      onChanged: (value) {
        setState(() {
          _cont.objectList = MBolim.obyektlar.values
              .where((element) =>
                  element.nomi.toLowerCase().contains(value.toLowerCase()))
              .toList();
        });
      },
    );
  }

  List<Widget>? _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchQueryController.text = '';
            setState(() {
              _isSearching = false;
              _cont.objectList = MBolim.obyektlar.values.toList();
            });
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            _isSearching = true;
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.question_mark_outlined),
        tooltip: "Sahifa bo'yicha qollanma",
        onPressed: () {
          Navigator.push(context, MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return const QollanmaView(sahifa: 'bkont');
            },
          ));
        },
      ),
    ];
  }

  void _openItemActionDialog(BuildContext context, element) {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Tanlash'),
        children: [
          ListTile(
            title: const Text("Malumot"),
            leading: const Icon(Icons.info),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MBolimIchiView(element.tr)),
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
                    builder: (context) => MBolimIchiView.tahrir(element.tr)),
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

  _delete(BuildContext context, MBolim element) {
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

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
