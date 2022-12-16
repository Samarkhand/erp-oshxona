import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/View/Auth/pincode_view.dart';
import 'package:erp_oshxona/View/Sistem/aloqa_view.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/View/Sistem/sozlash_cont.dart';
import 'package:url_launcher/url_launcher.dart';

class SozlashView extends StatefulWidget {
  const SozlashView({Key? key}) : super(key: key);

  @override
  State<SozlashView> createState() => _SozlashViewState();
}

class _SozlashViewState extends State<SozlashView> {
  final SozlashCont _cont = SozlashCont();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, title: "Sozlash"),
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
      title: Text(title ?? ""),
    );
  }

  Widget _body(context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: 10.0, top: 0, left: 0.0, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mablag'", style: Theme.of(context).textTheme.headline4),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  ListTile(
                    title: Text(Sozlash.abolimKomissiya.nomi),
                    subtitle: const Text(
                        "Hisoblar aro o'tkazmada to'lanadigan komissiya bo'limi"),
                    onTap: () {
                      _cont.komissiyaBolimTanlash(Sozlash.abolimKomissiya.tr, ABolimTur.chiqim);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    isThreeLine: true,
                  ),
                  ListTile(
                    title: Text(Sozlash.abolimMahUchun.nomi),
                    subtitle: const Text(
                        "Mahsulot uchun to'lov qilinganda yoki to'lov olinganda ushbu bo'lim avtomat tanlanadi"),
                    onTap: () {
                      _cont.mahBolimTanlash("abolimTrMahKirChiq", Sozlash.abolimMahUchun.tr, ABolimTur.chiqim);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    isThreeLine: true,
                  ),
                  ListTile(
                    title: Text(Sozlash.abolimMahUchun.nomi),
                    subtitle: const Text(
                        "Mahsulot savdo uchun mablag' tushum bo'limi. Mahsulot Savdo oynasida avtomat tanlangan holatda bo'ladi"),
                    onTap: () {
                      _cont.mahBolimTanlash("abolimTrMahSvdTush", Sozlash.abolimMahUchun.tr, ABolimTur.tushum);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    isThreeLine: true,
                  ),
                  ListTile(
                    title: Text(Sozlash.tanlanganHisob.nomi),
                    subtitle: const Text(
                        "Doim avtomat tanlanadigan hisob. Chiqim va tushum kiritishda qulaylik uchun"),
                    onTap: () {
                      _cont.hisobBolimTanlash();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    isThreeLine: true,
                  ),
                ],
              ),
            ),
          ),
          //========================= Aloqa
          Padding(
            padding: const EdgeInsets.only(
                bottom: 10.0, top: 20.0, left: 0.0, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Aloqa", style: Theme.of(context).textTheme.headline4),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  ListTile(
                    title: Row(children: [
                      const Icon(Icons.person, size: 19, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text("Shaxsiy kabinet",
                          style: TextStyle(color: Colors.blue.shade600)),
                    ]),
                    subtitle: const Text(
                        "Litsenziya olish, parol va shaxsiy ma'lumotlarni o'zgartirish"),
                    isThreeLine: true,
                    onTap: () {
                      InwareServer.lichka(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  ListTile(
                    title: Row(children: [
                      const Icon(Icons.mail, size: 19, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text("Muallif bilan aloqa",
                          style: TextStyle(color: Colors.blue.shade600))
                    ]),
                    subtitle: const Text(
                        "Muallif telegram akkaunti, pochtasi va ilovadan habar yuborish"),
                    isThreeLine: true,
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const AloqaView();
                        },
                      ));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  ListTile(
                    title: Row(children: [
                      const Icon(Icons.newspaper, size: 19, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text("Yangiliklar",
                          style: TextStyle(color: Colors.blue.shade600))
                    ]),
                    subtitle: const Text("Ilova haqida yangiliklar berib boriladigan telegram kanal - @FinMasterApp"),
                    onTap: () async {
                      /*Navigator.push(context, MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const NewsView();
                        },
                      ));*/

                      var uri = Uri.parse(InwareServer.linkYangiliklar);
                      if (await canLaunchUrl(uri)) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Internetga ulaning"),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.amberAccent,
                        ));
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ],
              ),
            ),
          ),
          //========================= Xavfsizlik
          Padding(
            padding: const EdgeInsets.only(
                bottom: 10.0, top: 20.0, left: 0.0, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Himoya",
                    style: Theme.of(context).textTheme.headline4),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Sozlash.pinCodeBormi
                      ? Column(children: [
                          ListTile(
                            title: Row(children: const [
                              Icon(Icons.mode_edit_outlined, size: 19),
                              SizedBox(
                                width: 10,
                              ),
                              Text("PIN kodni o'zgartirish",
                                  style: TextStyle(fontSize: 16))
                            ]),
                            onTap: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return AuthPinView(
                                      type: AuthPinViewType.update);
                                },
                              ));
                              setState(() {
                                Sozlash.pinCodeBormi;
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          ListTile(
                            title: Row(children: const [
                              Icon(Icons.delete, size: 19),
                              SizedBox(
                                width: 10,
                              ),
                              Text("PIN kodni o'chirish",
                                  style: TextStyle(fontSize: 16))
                            ]),
                            onTap: () {
                              _openDeletePinCodeActionDialog(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          )
                        ])
                      : ListTile(
                          title: Row(children: const [
                            Icon(Icons.lock, size: 19),
                            SizedBox(
                              width: 10,
                            ),
                            Text("PIN kod bilan himoyalash",
                                style: TextStyle(fontSize: 16))
                          ]),
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                return AuthPinView(
                                    type: AuthPinViewType.insert);
                              },
                            ));
                            setState(() {
                              Sozlash.pinCodeBormi;
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                ],
              ),
            ),
          ),
          //=========================
          (!Sozlash.tanishmi)
                      ? const SizedBox()
                      : Padding(
            padding: const EdgeInsets.only(
                bottom: 10.0, top: 20.0, left: 0.0, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Litsenziya",
                    style: Theme.of(context).textTheme.headline4),
              ],
            ),
          ),
          (!Sozlash.tanishmi)
                      ? const SizedBox()
                      : Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      children: [
                        const Text("Litsenziya: ",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(Sozlash.litsenziya.substring(0, 12)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 7),
                    child: Row(
                      children: [
                        const Text("Boshlanishi: ",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(dateFormat.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                toMilliSecond(Sozlash.litVaqtDan)))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7, left: 7),
                    child: Row(
                      children: [
                        const Text("Tugashi: ",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(
                            "${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(toMilliSecond(Sozlash.litVaqtGac)))} ${hourMinuteFormat.format(DateTime.fromMillisecondsSinceEpoch(toMilliSecond(Sozlash.litVaqtGac)))}"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      children: [
                        const Text("Qoldi: ",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(
                            "${((toMilliSecond(Sozlash.litVaqtGac) - DateTime.now().millisecondsSinceEpoch) / 1000 / 60 / 60 / 24).toStringAsFixed(0)} kun"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: Row(children: const [
                            Icon(Icons.refresh),
                            SizedBox(width: 10),
                            Text("Yangilash"),
                          ]),
                          onPressed: () async {
                            _cont.showLoading(text: "Litsenziya yangilanmoqda");
                            await InwareServer.licTekshir(context,
                                asosiymi: true);
                            _cont.hideLoading();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          //========================= Ma'lumot
          Padding(
            padding: const EdgeInsets.only(
                bottom: 10.0, top: 20.0, left: 0.0, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ma'lumot", style: Theme.of(context).textTheme.headline4),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Ommaviy oferta"),
                    onTap: () async {
                      var uri = Uri.parse(InwareServer.linkOferta);
                      if (await canLaunchUrl(uri)) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Internetga ulaning"),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.amberAccent,
                        ));
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  ListTile(
                    title: const Text("Foydalanish shartlari"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const QollanmaView(
                            sahifa: "foydalanish_shartlari",
                          );
                        },
                      ));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          //=========================
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  ListTile(
                    title: Row(children: [
                      const Icon(Icons.exit_to_app_rounded,
                          size: 19, color: Colors.red),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("Akkauntdan chiqish",
                          style: TextStyle(color: Colors.red.shade600))
                    ]),
                    onTap: () {
                      _openItemActionDialog(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Text("FinMaster by INWARE. 2022"),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  _openItemActionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Akkauntingizdan chiqib ketmoqchimisiz?'),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("YO'Q"),
          ),
          TextButton(
            onPressed: () => InwareServer.logout(context),
            child: Text("HA", style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  _openDeletePinCodeActionDialog(BuildContext context) async {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN kodni rostdan ham o`chirib yubormoqchimisiz?'),
        /*content: const Text(
            'Akkauntdan'),*/
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("YO'Q"),
          ),
          TextButton(
            onPressed: () async {
              await Sozlash.box.put("pinCode", '');
              await Sozlash.box.put("pinCodeBormi", false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  "PIN kod o'chirib yuborildi",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.blueAccent,
              ));
              setState(() {
                Sozlash.pinCodeBormi;
              });
              Navigator.pop(context);
            },
            child: Text("HA", style: TextStyle(color: Colors.red.shade700)),
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
