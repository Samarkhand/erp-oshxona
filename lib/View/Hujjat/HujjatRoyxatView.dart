import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatRoyxatCont.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatIchiView.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Widget/card_hujjat.dart';
import 'package:select_dialog/select_dialog.dart';

class HujjatRoyxatView extends StatefulWidget {
  const HujjatRoyxatView({Key? key, this.turi}) : super(key: key);

  final HujjatTur? turi;

  @override
  State<HujjatRoyxatView> createState() => _HujjatRoyxatViewState();
}

class _HujjatRoyxatViewState extends State<HujjatRoyxatView> {
  final HujjatRoyxatCont _cont = HujjatRoyxatCont();
  bool yuklanmoqda = false;

  int tanBolim = 0;
  int tanKont = 0;
  int turi = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, title: "${widget.turi?.nomi ?? "Hujjatlar"} hujjatlar reystri" ),
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
                                BorderRadius.circular(10.0)), //this right here
                        child: HujjatIchiView.yangi(widget.turi!.tr)),
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
                _cont.objectList[index],
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
