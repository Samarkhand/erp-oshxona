import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/static/qulf.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TarmoqAzoWidget extends StatefulWidget {
  const TarmoqAzoWidget({Key? key}) : super(key: key);

  @override
  State<TarmoqAzoWidget> createState() => _TarmoqAzoWidgetState();
}

class _TarmoqAzoWidgetState extends State<TarmoqAzoWidget> {
  bool botCheckLoading = false;
  bool chnCheckLoading = false;
  bool grpCheckLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      litOlishButton(context),
      const SizedBox(height: 20.0),
      Sozlash.tarmoqTBotAzosimiTas
          ? const SizedBox()
          : Card(
              margin: EdgeInsets.zero,
              color: Sozlash.tarmoqTBotAzosimiTas
                  ? Theme.of(context).cardColor.withOpacity(0.9)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.0),
                onTap: Sozlash.tarmoqTBotAzosimiTas
                    ? null
                    : () async {
                        setState(() {});
                        Sozlash.box.put("tarmoqTBotAzosimi", true);
                        InwareServer.botAzoBol(context);
                        setState(() {
                          Sozlash.tarmoqTBotAzosimi;
                        });
                      },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("1. Telegram Botga a'zo bo'ling",
                            style: MyTheme.d6, maxLines: 3, softWrap: true),
                        const Text(
                            "Qo'shimcha 3 kun dasturni bepul sinab ko'ring. Bot behuda bezovta qilmaydi"),
                        Container(
                          alignment: Alignment.topRight,
                          child: (botCheckLoading)
                              ? const SizedBox(
                                  height: 10.0,
                                  width: 10.0,
                                  child: CircularProgressIndicator(),
                                )
                              : Sozlash.tarmoqTBotAzosimi
                                  ? MaterialButton(
                                      color: Colors.blue,
                                      onPressed: azomi,
                                      child: const Text(
                                        "A'zo bo'ldim",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : !Sozlash.tarmoqTBotAzosimiTas
                                      ? MaterialButton(
                                          color: Colors.green,
                                          onPressed: () async {
                                            setState(() {});
                                            Sozlash.box
                                                .put("tarmoqTBotAzosimi", true);
                                            InwareServer.botAzoBol(context);
                                            setState(() {
                                              Sozlash.tarmoqTBotAzosimi;
                                            });
                                          },
                                          child: const Text(
                                            "A'zo bo'lish",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )
                                      : const SizedBox(),
                        )
                      ]),
                ),
              ),
            ),
      const SizedBox(height: 15.0),
      Sozlash.tarmoqTKnAzosimi || !Sozlash.tarmoqTBotAzosimiTas
          ? const SizedBox()
          : Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("2. Telegram kanalga a'zo bo'ling",
                          style: MyTheme.d6, maxLines: 3, softWrap: true),
                      const Text(
                          "Kanalda qanday foydalanish, ilova yangiliklari, foydali maslahatlar berib boriladi. Qo'shimcha yana 3 kun dasturni bepul sinab ko'ring."),
                      Container(
                        alignment: Alignment.topRight,
                        child: (botCheckLoading)
                            ? const SizedBox(
                                height: 10.0,
                                width: 10.0,
                                child: CircularProgressIndicator(),
                              )
                            : MaterialButton(
                                color: Colors.blue,
                                onPressed: azomi,
                                child: const Text(
                                  "A'zo bo'ldim",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  Sozlash.box.put("tarmoqTKnlAzosimi", true);
                  if (!Sozlash.tanishmi) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Avval ro'yxatdan o'ting"),
                      duration: Duration(seconds: 5),
                      backgroundColor: Colors.amber,
                    ));
                    return;
                  }
                  String url = "https://t.me/${InwareServer.telegramKanal}";
                  logConsole("URL Launch: $url");
                  Uri uri = Uri.parse(url);
                  if (!await launchUrl(uri,
                      mode: LaunchMode.externalApplication)) {
                    throw 'Could not launch url';
                  }
                },
              ),
            ),
      const SizedBox(height: 15.0),
      Sozlash.tarmoqTGrAzosimi || !Sozlash.tarmoqTBotAzosimiTas
          ? const SizedBox()
          : Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("3. Telegram guruhga a'zo bo'ling",
                          style: MyTheme.d6, maxLines: 3, softWrap: true),
                      const Text(
                          "Guruhda ilovadan koproq foyda olish va yanada qulaylashtirish bo'yicha fikr bildiring. Qo'shimcha yana 3 kun dasturni bepul sinab ko'ring."),
                      Container(
                        alignment: Alignment.topRight,
                        child: (botCheckLoading)
                            ? const SizedBox(
                                height: 10.0,
                                width: 10.0,
                                child: CircularProgressIndicator(),
                              )
                            : MaterialButton(
                                color: Colors.blue,
                                onPressed: azomi,
                                child: const Text(
                                  "A'zo bo'ldim",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  Sozlash.box.put("tarmoqTGrpAzosimi", true);
                  if (!Sozlash.tanishmi) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Avval ro'yxatdan o'ting"),
                      duration: Duration(seconds: 5),
                      backgroundColor: Colors.amber,
                    ));
                    return;
                  }
                  String url = "https://t.me/${InwareServer.telegramGroup}";
                  logConsole("URL Launch: $url");
                  Uri uri = Uri.parse(url);
                  if (!await launchUrl(uri,
                      mode: LaunchMode.externalApplication)) {
                    throw 'Could not launch url';
                  }
                },
              ),
            ),
    ]);
  }

  azomi() async {
    setState(() {
      botCheckLoading = true;
    });
    await InwareServer.azoBoldimiBotga(
        context); /*
    await Sozlash.box.put("tarmoqTBotAzosimi",  false);
    await Sozlash.box.put("tarmoqTBotAzosimiTas", false);
    await Sozlash.box.put("tarmoqTKnlAzosimi", false);
    await Sozlash.box.put("tarmoqTGrpAzosimi", false);*/
    setState(() {
      botCheckLoading = false;
      Sozlash.tarmoqTBotAzosimi;
      Sozlash.tarmoqTBotAzosimiTas;
      Sozlash.tarmoqTGrAzosimi;
      Sozlash.tarmoqTKnAzosimi;
    });
    if (Sozlash.tarmoqAzosimi) {
      // ignore: use_build_context_synchronously
      await InwareServer.licTekshir(context);
    }
  }
}
