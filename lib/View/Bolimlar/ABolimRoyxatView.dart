import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Bolimlar/ABolimRoyxatCont.dart';
import 'package:erp_oshxona/View/Bolimlar/ABolimIchiView.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/aBolim.dart';

class ABolimRoyxatView extends StatefulWidget {
  ABolimRoyxatView({required this.bobo, required this.turi, Key? key})
      : super(key: key);
  int turi;
  int bobo;

  @override
  State<ABolimRoyxatView> createState() => _ABolimRoyxatViewState();
}

class _ABolimRoyxatViewState extends State<ABolimRoyxatView> {
  final ABolimRoyxatCont _cont = ABolimRoyxatCont();
  bool yuklanmoqda = false;
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context,
          title: "Bo'limlar: ${ABolimTur.obyektlar[widget.turi]!.nomi}"),
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
      floatingActionButton: widget.turi == ABolimTur.tizim.tr ? null : FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ABolimIchiView.yangi(widget.turi)),
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
      actions: _buildActions(),
      title: _isSearching
          ? _buildSearchField()
          : Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
    );
  }

  Widget _body(context) {
    List<Widget> list = [];
    for (var element in _cont.objectList) {
      list.add(_buildItem(context, element));
    }

    return Column(
      children: [
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.only(bottom: 75, top: 5, left: 10, right: 10),
            shrinkWrap: false,
            children: list,
            proxyDecorator: (widget, i, anim) {
              return Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
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
              for (ABolim object in _cont.objectList) {
                n++;
                object.tartib = n;
                ABolim.service!.update({'tartib': n}, where: "tr=${object.tr}");
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, element) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      key: Key('royhat_el_${element.tr}'),
      child: ListTile(
        title: Text(element.nomi),
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
      style:  TextStyle(color: Theme.of(context).appBarTheme.foregroundColor, fontSize: 16.0),
      cursorColor: Theme.of(context).appBarTheme.foregroundColor,
      onChanged: (value) {
        setState(() {
          _cont.objectList = ABolim.obyektlar.values
              .where((element) =>
                  element.turi == widget.turi &&
                  element.trBobo == widget.bobo &&
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
              _cont.objectList = ABolim.obyektlar.values
                  .where((element) =>
                      element.turi == widget.turi &&
                      element.trBobo == widget.bobo)
                  .toList();
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
              return const QollanmaView(sahifa: 'bolim');
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
                    builder: (context) => ABolimIchiView(element.tr)),
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
                    builder: (context) => ABolimIchiView.tahrir(element.tr)),
              );
              setState(() {
                element;
              });
            },
          ),
          element.turi == ABolimTur.tizim.tr ? const SizedBox() : ListTile(
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

  _delete(BuildContext context, ABolim element) {
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
