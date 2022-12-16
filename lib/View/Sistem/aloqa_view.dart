import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Sistem/aloqa_cont.dart';
import 'package:url_launcher/url_launcher.dart';

class AloqaView extends StatefulWidget {
  const AloqaView({Key? key}) : super(key: key);

  @override
  State<AloqaView> createState() => _AloqaViewState();
}

class _AloqaViewState extends State<AloqaView> {
  final AloqaCont _cont = AloqaCont();
  bool yuklanmoqda = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context, title: "Muallif bilan aloqa"),
        body: _cont.isLoading
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _cont.formKey,
                child: Column(
                  children: [
                    (Sozlash.tanishmi)
                        ? const SizedBox()
                        : TextFormField(
                            autofocus: true,
                            controller: _cont.aloqaController,
                            maxLength: 64,
                            decoration: const InputDecoration(
                              labelText:
                                  "Telefon raqam yoki telegram user yozing",
                            ),
                            validator: (value) => _cont.validate(value,
                                required: true,
                                nomi:
                                    'Iltimos siz bilan bog`lana olishimiz uchun telefon raqam kiriting'),
                          ),
                    TextFormField(
                      controller: _cont.matnController,
                      autofocus: true,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: "Habar matni",
                      ),
                      maxLines: 2,
                      validator: (value) => _cont.validate(value,
                          required: true, nomi: 'Habar yozing'),
                    ),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: ElevatedButton(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            child: Wrap(children: [
                              const Icon(Icons.mail, size: 19),
                              const SizedBox(width: 5),
                              Text("Jo'natish".toUpperCase())
                            ]),
                          ),
                          onPressed: () {
                            _cont.send(context);
                          },
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  ListTile(
                    title: Row(children: [
                      const Icon(Icons.telegram, size: 19, color: Colors.blue),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("Telegram: @${InwareServer.linkTelegramMuallif}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600))
                    ]),
                    onTap: () async {
                      var uri = Uri.parse("https://t.me/${InwareServer.linkTelegramMuallif}");
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Internetga ulaning"),
                          duration: Duration(seconds: 5),
                          backgroundColor: Colors.amberAccent,
                        ));
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  ListTile(
                    title: Row(children: [
                      const Icon(Icons.mail, size: 19, color: Colors.orange),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("E-mail: ${InwareServer.linkEmailMuallif}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade600))
                    ]),
                    onTap: () async {
                      var uri = Uri.parse("mailto:${InwareServer.linkEmailMuallif}");
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Internetga ulaning"),
                          duration: Duration(seconds: 5),
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
