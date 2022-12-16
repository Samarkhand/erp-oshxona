import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/View/Hisob/transfer_controller.dart';
import 'package:erp_oshxona/Model/transfer.dart';
import 'package:erp_oshxona/Model/hisob.dart';

class TransferView extends StatefulWidget {
  const TransferView({Key? key, this.trans}) : super(key: key);
  final Transfer? trans;

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  final TransferCont _cont = TransferCont();
  String _title = "";

  List<DropdownMenuItem<Hisob>> hisoblarItemList = [];
  Hisob? itemSelHisobdan;
  Hisob? itemSelHisobga;

  int _etap = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      //backgroundColor: Color(0xfff0f0f0),
      body: Builder(
        builder: (context) => (!_cont.yuklanibBoldi)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : (hisoblarItemList.isEmpty)
                ? const Center(
                    child: Text(
                      "Hisoblar mavjud emas",
                      style: TextStyle(color: Colors.black54, fontSize: 20.0),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 20.0),
                            child: Card(
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _etap == 1
                                      ? _hisobTanlash()
                                      : _miqdorKiritish(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        elevation: 2,
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: _etap == 2
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _etap--;
                                          });
                                        },
                                        icon: const Icon(Icons.chevron_left),
                                        label: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                          child: Text("Qaytish"),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      ElevatedButton(
                                        onPressed: () {
                                          _saqla(context);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 30.0),
                                          child: Text("Saqlash",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ],
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _etap++;
                                      });
                                    },
                                    label: const Icon(Icons.chevron_right),
                                    icon: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 10.0),
                                      child: Text("Keyingi qadam",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  List<Widget> _hisobTanlash() {
    return [
      DropdownButtonFormField(
        decoration: const InputDecoration(
          labelText: "Chiqim hisob",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        isExpanded: true,
        //isDense: true,
        value: itemSelHisobdan,
        items: hisoblarItemList,
        //hint: const Text("Chiqim hisob", style: TextStyle(color: Colors.black54)),
        onChanged: (Hisob? value) {
          setState(() {
            itemSelHisobdan = value;
            _cont.trans.trHisobdan = value!.tr;
          });
          _cont.transferTempTanla(value!.tr, true);
        },
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const <Widget>[
          Icon(
            Icons.arrow_downward,
            color: Colors.grey,
          ),
        ],
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField(
        decoration: const InputDecoration(
          labelText: "Tushum hisob",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        isExpanded: true,
        value: itemSelHisobga,
        items: hisoblarItemList,
        //hint:,
        onChanged: (Hisob? value) {
          setState(() {
            itemSelHisobga = value;
            _cont.trans.trHisobga = value!.tr;
          });
          _cont.transferTempTanla(value!.tr, false);
        },
      ),
    ];
  }

  List<Widget> _miqdorKiritish() {
    return [
      TextFormField(
        autofocus: true,
        controller: _cont.miqdorController,
        //cursorColor: Theme.of(context).cursorColor,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Mablag' miqdori",
          //suffix:
        ),
        onChanged: (String value) {
          setState(() {
            if (value == "") {
              _cont.trans.miqdor = 0;
            } else {
              _cont.trans.miqdor = num.parse(value);
            }
          });
        },
      ),
      Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: TextFormField(
              //autofocus: true,
              controller: _cont.foizController,
              //cursorColor: Theme.of(context).cursorColor,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Komissiya (%):",
                //suffix:
              ),
              onChanged: (String value) {
                setState(() {
                  if (value == "") {
                    _cont.trans.foiz = 0;
                  } else {
                    _cont.trans.foiz = num.parse(value);
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 0.0,
                bottom: 0.0,
                left: 10.0,
                right: 20.0,
              ),
              child: TextFormField(
                //autofocus: true,
                controller: _cont.sumController,
                // cursorColor: Theme.of(context).cursorColor,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Komissiya summa",
                  //suffix:
                ),
                onChanged: (String value) {
                  setState(() {
                    if (value == "") {
                      _cont.trans.sum = 0;
                    } else {
                      _cont.trans.sum = num.parse(value);
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
            ),
            child: Wrap(
              children: [
                const Text("Summa chiquvchi: ",
                    style: TextStyle(color: Colors.black54)),
                Text(
                    sumFormat.format(
                        (_cont.trans.miqdor + _cont.trans.getSumXizmat())),
                    style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
      TextFormField(
        controller: _cont.izohController,
        //cursorColor: Theme.of(context).cursorColor,
        maxLength: 255,
        decoration: const InputDecoration(
          labelText: "Izoh",
        ),
        maxLines: 2,
      ),
    ];
  }

  void _saqla(BuildContext context) async {
    var hatobor = false;

    if (_cont.trans.trHisobdan == 0 || _cont.trans.trHisobga == 0) {
      hatobor = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Hisob tanlang"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.orangeAccent,
      ));
    }
    if (_cont.miqdorController.text == "") {
      hatobor = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Miqdor kiriting"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.orangeAccent,
      ));
    }
    if (hatobor) {
      return;
    }
    _cont.saqla(context);
  }

  @override
  void initState() {
    super.initState();

    if (widget.trans != null) {
      _title = "Tahrirlash: Transfer";
    } else {
      _title = "Hisoblar aro transfer";
    }

    initialize();

    setState(() {
      _cont.trans;
    });
  }

  void initialize() async {
    _cont.init(widget, setState, context);
    var items = await _cont.olHisoblar();
    items.sort((a, b) => a.tartib.compareTo(b.tartib));
    for (Hisob item in items) {
      if (item.tr == 0) continue;
      hisoblarItemList.add(DropdownMenuItem(
        value: item,
        onTap: item.active && item.tr != 0 ? null : () => {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.nomi,
              style:
                  TextStyle(color: item.active ? Colors.black87 : Colors.grey),
            ),
            Text(
              sumFormat.format(item.balans),
              style:
                  TextStyle(color: item.active ? Colors.black87 : Colors.grey),
            ),
          ],
        ),
      ));
    }
    setState(() {
      // ignore: unnecessary_statements
      hisoblarItemList;
      _cont.yuklanibBoldi = true;
    });
  }
}
