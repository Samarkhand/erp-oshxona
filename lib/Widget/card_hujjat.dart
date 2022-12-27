import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatIchiView.dart';
import 'package:flutter/material.dart';

class HujjatCard extends StatelessWidget {
  const HujjatCard(this.object,
      {Key? key, required this.cont, required this.doAfterDelete})
      : super(key: key);
  final Hujjat object;
  final Controller cont;
  final Function doAfterDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onDoubleTap: () async {
          /*
          showDialog(
            context: context,
            builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10.0)), //this right here
            child: HujjatIchiView(object)),
          );*/
          Widget? view = openHujjat(object);
          if (view == null) return;
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => view,
              ));
          await doAfterDelete();
        },
        onTap: (() async {
          await showDialog(
            context: context,
            builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0)), //this right here
                child: HujjatIchiView(object)),
          );
          await doAfterDelete();
        }),
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
                    Wrap(children: [
                      //Icon(HujjatTur.obyektlar[object.turi]!.icon, size: 16),
                      Text(
                        "${object.raqami}-${HujjatTur.obyektlar[object.turi]!.nomi}",
                        style: MyTheme.h6.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 7.0),
                      statusBadge(object.status),
                      const SizedBox(width: 7.0),
                      object.trKont == 0
                          ? const SizedBox()
                          : Text(
                              Kont.obyektlar[object.trKont]!.nomi,
                            ),
                    ]),
                    object.trKont == 0
                        ? const SizedBox()
                        : Row(children: [
                            const Icon(Icons.person, size: 16),
                            Text(
                              Kont.obyektlar[object.kont]!.nomi,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
                    Text(sumFormat.format(object.summa)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget statusBadge(HujjatSts status) {
  return Material(
    color: status.ranggi,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      child: Text(
      status.nomi,
      style: const TextStyle(color: Colors.white),
    ),),
  );
}
