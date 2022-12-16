import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/Sistem/exportimport_view.dart';
import 'package:erp_oshxona/View/Sistem/aloqa_view.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:erp_oshxona/View/Auth/registratsiya_view.dart';
import 'package:erp_oshxona/Model/static/qulf.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Auth/qulf_cont.dart';
import 'package:url_launcher/url_launcher.dart';

class QulfView extends StatefulWidget {
  const QulfView(this.sabab, {Key? key}) : super(key: key);
  final QulfSabab sabab;

  @override
  State<QulfView> createState() => _QulfViewState();
}

class _QulfViewState extends State<QulfView> {
  final QulfCont _cont = QulfCont();
  bool yuklanmoqda = false;
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _body(context),
      ),
    );
  }

  Widget _body(context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: RefreshIndicator(
        onRefresh: () async {
          _cont.showLoading(text: "");
          await InwareServer.licTekshir(context);
          _cont.hideLoading();
        },
        child: Form(
          key: _cont.formKey,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _dialogYangiAmaliyot(context),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text("Menyu"),
                      ),
                      icon: const Icon(Icons.menu, size: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      child:
                          Image.asset("assets/logo_finmaster.png", width: 100),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 30),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Image.asset("assets/lock.png", width: 160),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(widget.sabab.matn,
                    style: MyTheme.h3.copyWith(color: Colors.red.shade600),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Wrap(
                        children: [
                          Text("Tavsiya: ", style: MyTheme.h5, softWrap: true),
                          Text(widget.sabab.yechim, style: MyTheme.d5, softWrap: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              (widget.sabab.action != null)
                  ? widget.sabab.action!(context)
                  : const SizedBox(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  _dialogYangiAmaliyot(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          List<Widget> list = [];

          if (Sozlash.tanishmi) {
            list.add(ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text("Yangilash"),
              onTap: () async {
                _cont.showLoading(text: "");
                await InwareServer.licTekshir(context);
                _cont.hideLoading(); 
              },
            ));
            list.add(ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Shaxsiy kabinet"),
              onTap: (){InwareServer.lichka(context);},
            ));
          }
          else{
            list.add(ListTile(
              leading: const Icon(Icons.login),
              title: const Text("Ro'yxatdan o'tish"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return const RegistratsiyaView();
                  },
                ));
              },
            ));
          }
          list.add(ListTile(
            leading: const Icon(Icons.memory),
            title: const Text("Ma'lumotlar rezervi"),
            onTap: () async {
              await Controller.start();
              // ignore: use_build_context_synchronously
              await Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const ExportimportView();
                },
              ));
            },
          ));
          list.add(ListTile(
            leading: const Icon(Icons.mail),
            title: const Text("Muallif bilan aloqa"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AloqaView(),
                  ));
            },
          ));
          list.add(ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text("Yangiliklar"),
            onTap: () async {
              var uri = Uri.parse(InwareServer.linkYangiliklar);
              if (await canLaunchUrl(uri)) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                  content: Text("Internetga ulaning"),
                  duration: Duration(seconds: 5),
                  backgroundColor: Colors.amberAccent,
                ));
              }
            },
          ));
          list.add(ListTile(
            leading: const Icon(Icons.check),
            title: const Text("Foydalanish shartlari"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const QollanmaView(
                    sahifa: "foydalanish_shartlari",
                  );
                },
              ));
            },
          ));
          if (Sozlash.tanishmi) {
            list.add(ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Akkauntdan chiqish"),
              onTap: () {InwareServer.logout(context);},
            ));
          }
          return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            title: const Text("Menyu"),
            children: <Widget>[const SizedBox(height: 10.0)] +
                list +
                <Widget>[
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.only(right: 20.0, bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                            child: Text(
                              "Qaytish".toUpperCase(),
                              style: const TextStyle(color: Colors.black38),
                            ),
                            //color: Theme.of(context).buttonColor,
                            onPressed: () {
                              Navigator.of(context).pop(0);
                            }),
                      ],
                    ),
                  ),
                ],
          );
        });
  }

  @override
  void initState() {
    _cont.init(widget, setState, context: context);
    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
    super.initState();
  }
}
