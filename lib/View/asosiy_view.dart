import 'package:erp_oshxona/View/Bolimlar/MBolimRoyxatView.dart';
import 'package:erp_oshxona/View/IshlabChiqarish/partiya_royxat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/hujjat_davomi.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:erp_oshxona/View/Auth/pincode_view.dart';
import 'package:erp_oshxona/View/Auth/registratsiya_view.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatRoyxatView.dart';
import 'package:erp_oshxona/View/Mahsulot/MahRoyxatView.dart';
import 'package:erp_oshxona/View/Sistem/exportimport_view.dart';
import 'package:erp_oshxona/View/Sistem/aloqa_view.dart';
import 'package:erp_oshxona/View/Auth/kirish_view.dart';
import 'package:erp_oshxona/View/Hisobot/hisobot_view.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/View/Sistem/sozlash_view.dart';
import 'package:erp_oshxona/View/asosiy_cont.dart';
import 'package:erp_oshxona/View/Bolimlar/KBolimRoyxatView.dart';
import 'package:erp_oshxona/View/Kont/KontRoyxatView.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AsosiyView extends StatefulWidget {
  const AsosiyView({Key? key}) : super(key: key);

  @override
  State<AsosiyView> createState() => _AsosiyViewState();
}

class _AsosiyViewState extends State<AsosiyView>
    with SingleTickerProviderStateMixin {
  final AsosiyCont _cont = AsosiyCont();

  List<Widget> hisoblar = [];

  List<TargetFocus> targets = [];

  GlobalKey keyQollanmaButton = GlobalKey(debugLabel: "qollanmaButton");
  GlobalKey keyYangiButton = GlobalKey(debugLabel: "keyYangiButton");
  GlobalKey keyChiqimTanlashButton =
      GlobalKey(debugLabel: "keyChiqimTanlashButton");

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: Scaffold(
            appBar: _appBar(context, title: "ERP Oshxona v 1.0 by INWARE"),
            body: (_cont.isLoading)
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
                : _body(),
            drawer: _drawer(),
          ),
        ));
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
      actions: [
        Sozlash.pinCodeBormi
            ? IconButton(
                icon: const Icon(Icons.lock_open),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AuthPinView(type: AuthPinViewType.auth),
                    ),
                  );
                },
              )
            : const SizedBox(),
        IconButton(
          key: keyQollanmaButton,
          icon: const Icon(Icons.question_mark_outlined),
          tooltip: "Sahifa bo'yicha qollanma",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return const QollanmaView(
                  sahifa: "asosiy",
                );
              },
            ));
          },
        ),
      ],
    );
  }

  Drawer _drawer() {
    final Drawer drawer2 = Drawer(
      semanticLabel: "INWARE",
      child: Column(
        children: <Widget>[
          Expanded(
              //flex: 100,
              child: ListView(children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.dark_mode),
                      onPressed: (){},
                    ),
                  ),
                  ListTile(
                    title: Text(Sozlash.ism,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(Sozlash.tel,
                        style: const TextStyle(color: Colors.white60)),
                    onLongPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KirishView(),
                          ));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Wrap(
                      children: [
                        const Icon(Icons.lock_clock,
                            color: Color(0x99FFFFFF), size: 17.5),
                        Text(
                          " Ilova ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(toMilliSecond(Sozlash.litVaqtGac)))}gacha faol",
                          style: const TextStyle(
                              color: Color(0x99FFFFFF), fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu
            ListTile(
              leading: const Icon(Icons.data_usage_sharp),
              title: const Text("Hisobotlar"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HisobotView(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Kontaktlar"),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KontRoyxatView(),
                    ));
                await _cont.songgiAmaliyotYangila();
                await _cont.songgiAMahsulotYukla();
                await _cont.songgiAOrderYangila();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: Wrap(
                children: const [
                  Text(" Kontakt bo'limlari"),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KBolimRoyxatView(),
                    ));
              },
            ),
            // ========================
            const Divider(
              thickness: 1.0,
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text("Maxsulot", style: MyTheme.d6),
            ),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: const Text("Buyumlar ro'yxati"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MahRoyxatView(turi: MTuri.buyum),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: const Text("Taomlar ro'yxati"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MahRoyxatView(turi: MTuri.mahsulot),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: const Text("Masalliqlar ro'yxati"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MahRoyxatView(turi: MTuri.homAshyo),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: Wrap(
                children: const [
                  Text(" Bo'limlari"),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MBolimRoyxatView(turi: MTuri.mahsulot),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text("Kirim hujjatlari"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HujjatRoyxatView(turi: HujjatTur.kirim),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text("Chiqim hujjatlari"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HujjatRoyxatView(turi: HujjatTur.chiqim),
                    ));
              },
            ),
            /*
            ExpansionTile(
              leading: const Icon(Icons.folder),
              title: const Text("Bo'limlar"),
              children: <Widget>[
                ListTile(
                  title: Wrap(
                    children: const [
                      Icon(Icons.sync, size: 20),
                      Text(" Mahsulot bolimlari"),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ABolimRoyxatView(
                              turi: ABolimTur.mahsulot.tr, bobo: 0),
                        ));
                  },
                ),
              ],
            ),*/
            // ========================
            const Divider(
              thickness: 1.0,
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text("Tizim", style: MyTheme.d6),
            ),
            ListTile(
              leading: const Icon(Icons.person_pin),
              title: const Text("Shaxsiy kabinet"),
              onTap: () {
                Navigator.of(context).pop();
                (Sozlash.tanishmi)
                    ? InwareServer.lichka(context)
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistratsiyaView(),
                        ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Muallif bilan aloqa"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AloqaView(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.memory),
              title: const Text("Ma'lumotlar rezervi"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExportimportView(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Sozlash"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SozlashView(),
                    ));
              },
            ),
            const SizedBox(height: 30.0),
          ])),
        ],
      ),
    );

    return drawer2;
  }

  Widget _body() {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      crossAxisCount: 6,
      children: [
        viewButton("Taomlar", onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MahRoyxatView(turi: MTuri.mahsulot)));
        }, icon: SvgPicture.asset("assets/sf_icons/box-full.svg", width: 50)),
        viewButton("Masalliqlar", onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MahRoyxatView(turi: MTuri.homAshyo)));
        }, icon: SvgPicture.asset("assets/sf_icons/box-full.svg", width: 50)),
        viewButton(
          "Taom tarqatish",
          onTap: () {},
        ),
        viewButton(
          "Taom tayyorlash",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HujjatPartiyaRoyxatView(),
                ));
          },
        ),
        viewButton(
          "Chiqim",
          icon: SvgPicture.asset("assets/sf_icons/box-out.svg", width: 50),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HujjatRoyxatView(turi: HujjatTur.chiqim),
                ));
          },
        ),
        viewButton(
          "Kirim",
          icon: SvgPicture.asset("assets/sf_icons/box-in.svg", width: 50),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HujjatRoyxatView(turi: HujjatTur.kirim),
                ));
          },
        ),
        viewButton(
          "Filialga chiqim",
          icon: SvgPicture.asset("assets/sf_icons/box-sync.svg", width: 50),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HujjatRoyxatView(turi: HujjatTur.chiqimFil),
                ));
          },
        ),
        viewButton(
          "Xarid buyurtma",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HujjatRoyxatView(turi: HujjatTur.buyurtma),
                ));
          },
        ),
        viewButton(
          "Qaytib berish",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HujjatRoyxatView(turi: HujjatTur.qaytibBerish),
                ));
          },
        ),
        viewButton(
          "Qaytib olish",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HujjatRoyxatView(turi: HujjatTur.qaytibOlish),
                ));
          },
        ),
        viewButton(
          "Qoldiqdan o'chirish",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HujjatRoyxatView(turi: HujjatTur.zarar),
                ));
          },
        ),
      ],
    );
  }

  Widget viewButton(String title,
      {Color color = Colors.white, Widget? icon, GestureTapCallback? onTap}) {
    return Material(
      color: color,
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              icon ?? const SizedBox(),
              const SizedBox(height: 10.0),
              Text(title, textAlign: TextAlign.center, style: MyTheme.d6),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState,
        context:
            context); /*
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    });*/
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return true;
  }
}
