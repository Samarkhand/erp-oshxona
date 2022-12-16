import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Hisob/HisobRoyxatCont.dart';
import 'package:erp_oshxona/View/Hisob/HisobIchiView.dart';
import 'package:erp_oshxona/View/Hisob/transfer_view.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/static/mablag.dart';

class HisobRoyxatView extends StatefulWidget {
  const HisobRoyxatView({Key? key}) : super(key: key);

  @override
  State<HisobRoyxatView> createState() => _HisobRoyxatViewState();
}

class _HisobRoyxatViewState extends State<HisobRoyxatView> {
  final HisobRoyxatCont _cont = HisobRoyxatCont();
  bool yuklanmoqda = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, title: "Hisoblar"),
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
              MaterialPageRoute(builder: (context) => HisobIchiView.yangi(0)),
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
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
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
      elevation: 1,
    );
  }

  Widget _body(context) {
    List<Widget> list = [];
    num sumBalans = 0;
    for (var element in _cont.objectList) {
      list.add(_buildItem(context, element));
      sumBalans += element.balans;
    }

    return Column(
      children: [
        Material(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Text("Qoldiq", style: MyTheme.small),
                Text(sumFormat.format(sumBalans), style: MyTheme.h1),
                Container(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransferView(),
                        ),
                      );

                      setState(() {
                        Hisob.obyektlar;
                      });
                    },
                    icon: const Icon(Icons.repeat),
                    label: const Text("Hisoblar aro o'tkazma"),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView(
            padding:
                const EdgeInsets.only(bottom: 75, left: 10, right: 10, top: 10),
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
              for(Hisob object in _cont.objectList){
                n++;
                object.tartib = n;
                Hisob.service!.update({'tartib':n}, where: "tr=${object.tr}");
              }
            },
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
            _badgeSaqLashTuri(element.saqlashTuri),
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

  Widget _badgeSaqLashTuri(int tr) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Color(MablagSaqlashTuri.obyektlar[tr]!.color).withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 16,
      ),
      child: Wrap(
        children: [
          Icon(MablagSaqlashTuri.obyektlar[tr]!.icon,
              size: 16, color: Colors.white),
          const SizedBox(width: 7.0),
          Text(
            MablagSaqlashTuri.obyektlar[tr]!.nomi,
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
        title: const Text('Hisobni tanlash'),
        children: [
          ListTile(
            title: const Text("Malumot"),
            leading: const Icon(Icons.info),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HisobIchiView(element.tr)),
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
                    builder: (context) => HisobIchiView.tahrir(element.tr)),
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

  _delete(BuildContext context, Hisob element) {
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
