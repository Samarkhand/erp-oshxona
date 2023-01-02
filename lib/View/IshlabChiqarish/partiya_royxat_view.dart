import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/hujjat_partiya.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/ich_kirim_view.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/partiya_ichi_view.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/partiya_royxat_cont.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:select_dialog/select_dialog.dart';

class HujjatPartiyaRoyxatView extends StatefulWidget {
  HujjatPartiyaRoyxatView({Key? key}) : super(key: key);

  final int turi = HujjatTur.kirimIch.tr;

  @override
  State<HujjatPartiyaRoyxatView> createState() => _HujjatPartiyaRoyxatViewState();
}

class _HujjatPartiyaRoyxatViewState extends State<HujjatPartiyaRoyxatView> {
  final HujjatPartiyaRoyxatCont _cont = HujjatPartiyaRoyxatCont();
  bool yuklanmoqda = false;

  int tanBolim = 0;
  int tanKont = 0;
  int turi = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, title: HujjatTur.kirimIch.nomi),
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
              return HujjatCard(
                _cont.objectList[index].hujjat,
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
