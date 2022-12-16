import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/View/AMahsulot/AMahsulotIchiView.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:flutter/material.dart';

class AMahsulotCard extends StatelessWidget {
  const AMahsulotCard(this.object,
      {Key? key, required this.cont, required this.doAfterDelete})
      : super(key: key);
  final AMahsulot object;
  final Controller cont;
  final Function doAfterDelete;

  @override
  Widget build(BuildContext context) {
    late final Text miqdori;
    const sumStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 20);
    if (object.turi == AMahsulotTur.savdo.tr ||
        object.turi == AMahsulotTur.vozvratChiq.tr ||
        object.turi == AMahsulotTur.spisanya.tr) {
      miqdori = Text("- ${sumFormat.format(object.miqdor)}",
          style: sumStyle.copyWith(
              color: AMahsulotTur.obyektlar[object.turi]!.ranggi));
    } else if (object.turi == AMahsulotTur.kirim.tr ||
        object.turi == AMahsulotTur.vozvratKir.tr) {
      miqdori = Text("+ ${sumFormat.format(object.miqdor)}",
          style: sumStyle.copyWith(
              color: AMahsulotTur.obyektlar[object.turi]!.ranggi));
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () => _openItemActionDialog(context),
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
                    miqdori,
                    _badgeTuri(object),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeTuri(object) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AMahsulotTur.obyektlar[object.turi]!.ranggi,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 12,
      ),
      child: Wrap(
        children: [
          Text(
            AMahsulotTur.obyektlar[object.turi]!.nomi.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  void _openItemActionDialog(BuildContext context) {
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
                    builder: (context) => AMahsulotIchiView(object.tr)),
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
                    builder: (context) => AMahsulotIchiView.tahrir(object.tr)),
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
              _delete(context);
            },
          ),
        ],
      ),
    );
  }

  _delete(BuildContext context) {
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
