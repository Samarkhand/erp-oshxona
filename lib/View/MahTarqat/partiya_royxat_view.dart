import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_kirim_view.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/partiya_ichi_view.dart';
import 'package:erp_oshxona/View/MahTarqat/partiya_royxat_cont.dart';
import 'package:erp_oshxona/View/MahTarqat/tarqat_view.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:select_dialog/select_dialog.dart';

class HujjatPTRoyxatView extends StatefulWidget {
  HujjatPTRoyxatView({Key? key}) : super(key: key);

  final int turi = HujjatTur.tarqatish.tr;

  @override
  State<HujjatPTRoyxatView> createState() => _HujjatPTRoyxatViewState();
}

class _HujjatPTRoyxatViewState extends State<HujjatPTRoyxatView> {
  final HujjatPTRoyxatCont _cont = HujjatPTRoyxatCont();
  bool yuklanmoqda = false;

  int tanBolim = 0;
  int tanKont = 0;
  int turi = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, title: HujjatTur.tarqatish.nomi),
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
                const SizedBox(),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Yangi"),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10.0)),
                        child: HujjatPartiyaIchiView.yangi(widget.turi)),
                      );
                      await _cont.loadFromGlobal();
                      /*
                      var value = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HujjatIchiView.yangi(widget.turi!.tr)),
                      );
                      setState(() {
                        _cont.objectList.add(value);
                      });*/
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _cont.objectList.length,
            itemBuilder: (BuildContext context, int index) {
              if (_cont.objectList.length + 1 == index) {
                return const SizedBox(height: 60);
              }
              return _hujjatCard(_cont.objectList[index]);
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

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
  
  Widget _hujjatCard(Hujjat object) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onDoubleTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TarqatishView(object),
              ));
        },
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


class HujjatPartiyaCard extends StatelessWidget {
  HujjatPartiyaCard(this.partiya,
      {Key? key, required this.cont, required this.doAfterDelete})
      : hujjat = partiya.hujjat, super(key: key);
  final HujjatPartiya partiya;
  final Hujjat hujjat;
  final Controller cont;
  final Function doAfterDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onDoubleTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IchKirimRoyxatView(partiya),
              ));
          await doAfterDelete();
        },
        onTap: (() async {
          await showDialog(
            context: context,
            builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0)),
                child: HujjatPartiyaIchiView(hujjat)),
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
                      //Icon(HujjatTur.obyektlar[hujjat.turi]!.icon, size: 16),
                      Text(
                        "${hujjat.raqami}-${HujjatTur.obyektlar[hujjat.turi]!.nomi}",
                        style: MyTheme.h6.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 7.0),
                      statusBadge(hujjat.status),
                      const SizedBox(width: 7.0),
                      hujjat.trKont == 0
                          ? const SizedBox()
                          : Text(
                              Kont.obyektlar[hujjat.trKont]!.nomi,
                            ),
                    ]),
                    hujjat.trKont == 0
                        ? const SizedBox()
                        : Row(children: [
                            const Icon(Icons.person, size: 16),
                            Text(
                              Kont.obyektlar[hujjat.kont]!.nomi,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ]),
                    Text(
                      hujjat.izoh,
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
                        dateFormat.format(hujjat.sanaDT),
                        style: MyTheme.small.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hourMinuteFormat.format(hujjat.vaqtDT),
                        style: MyTheme.small.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ]),
                    Text(sumFormat.format(hujjat.summa)),
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
