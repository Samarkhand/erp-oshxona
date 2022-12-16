import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/View/Amaliyot/AmaliyotIchiView.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:erp_oshxona/Model/static/mablag.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:flutter/material.dart';

class AmaliyotCard extends StatelessWidget {
  const AmaliyotCard(this.object,
      {Key? key, required this.cont, required this.doAfterDelete})
      : super(key: key);
  final Amaliyot object;
  final Controller cont;
  final Function doAfterDelete;

  @override
  Widget build(BuildContext context) {
    late final Text text;
    const sumStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 20);
    text = Text(
        "${AmaliyotTur.obyektlar[object.turi]!.amal} ${sumFormat.format(object.miqdor)}",
        style: sumStyle.copyWith(
            color: AmaliyotTur.obyektlar[object.turi]!.ranggi));
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () => AmaliyotTur.obyektlar[object.turi]!.editable
            ? _openItemActionDialog(context)
            : false,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(children: [
                      object.bolim == 0
                          ? const SizedBox()
                          : Icon(ABolim.obyektlar[object.bolim]!.icon,
                              size: 16),
                      Text(
                        object.bolim == 0
                            ? ""
                            : ABolim.obyektlar[object.bolim]!.nomi,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ]),
                    Row(children: [
                      object.kont == 0
                          ? const SizedBox()
                          : const Icon(Icons.person, size: 16),
                      Text(
                        object.kont == 0
                            ? ""
                            : Kont.obyektlar[object.kont]!.nomi,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ]),
                    Text(
                      object.izoh,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Wrap(children: [
                      Text(
                        dateFormat.format(object.sanaDT),
                        style: MyTheme.small.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hourMinuteFormat.format(object.vaqtDT),
                        style: MyTheme.small.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ]),
                    text,
                    Wrap(children: [
                      _badgeHisob(object),
                      const SizedBox(width: 5),
                      badgeSaqLashTuri(
                          Hisob.obyektlar[object.hisob]!.saqlashTuri, false),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeHisob(object) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Color(MablagSaqlashTuri
                .obyektlar[Hisob.obyektlar[object.hisob]!.saqlashTuri]!.color)
            .withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 12,
      ),
      child: Wrap(
        children: [
          Text(
            Hisob.obyektlar[object.hisob]!.nomi.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openItemActionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Amaliyotni tanlash'),
        children: [
          ListTile(
            title: const Text("Malumot"),
            leading: const Icon(Icons.info),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AmaliyotIchiView(object.tr)),
              );
              cont.setState(() {
                object;
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
                    builder: (context) => AmaliyotIchiView.tahrir(object.tr)),
              );
              cont.setState(() {
                object;
              });
            },
          ),
          ListTile(
            title: const Text("O`chirish"),
            leading: const Icon(Icons.delete),
            onTap: () {
              Navigator.pop(context);
              delete(context);
            },
          ),
        ],
      ),
    );
  }

  delete(BuildContext context) {
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
              cont.showLoading();
              await object.delete();
              doAfterDelete();
              cont.hideLoading();
            },
            child: const Text('O`CHIRILSIN'),
          ),
        ],
      ),
    );
  }
}
