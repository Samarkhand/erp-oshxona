import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Bolimlar/KBolimIchiCont.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/kBolim.dart';

class KBolimIchiView extends StatefulWidget {
  KBolimIchiView(this.tr, {Key? key})
      : infomi = true,
        yangimi = false,
        turi = 0,
        super(key: key) {
    turi = KBolim.obyektlar[tr]!.turi;
  }
  KBolimIchiView.tahrir(this.tr, {Key? key})
      : yangimi = false,
        infomi = false,
        turi = 0,
        super(key: key) {
    turi = KBolim.obyektlar[tr]!.turi;
  }
  KBolimIchiView.yangi(this.turi, {Key? key, this.tanlansin = false})
      : yangimi = true,
        infomi = false,
        tr = 0,
        super(key: key);
  int turi;
  int tr;
  bool yangimi;
  bool infomi;
  bool tanlansin = false;

  @override
  State<KBolimIchiView> createState() => _KBolimIchiViewState();
}

class _KBolimIchiViewState extends State<KBolimIchiView> {
  final KBolimIchiCont _cont = KBolimIchiCont();
  bool yuklanmoqda = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
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
        actions: [
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
        ],
        title: Text((_cont.isLoading)
            ? _cont.loadingLabel
            : title ??
                (widget.yangimi
                    ? "Yangi bo'lim"
                    : "Tahrirlash: ${_cont.object.nomi}")));
  }

  Widget _body(context) {
    return Form(
      key: _cont.formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _cont.nomiController,
                  decoration: const InputDecoration(labelText: "Nomi:"),
                  onSaved: (value) => _cont.save(),
                  validator: (value) => _cont.validate(value, required: true),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          Material(
            elevation: 2,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 30.0),
                  child: Text("Saqlash".toUpperCase()),
                ),
                onPressed: () => _cont.save(),
              )),
            ),
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
