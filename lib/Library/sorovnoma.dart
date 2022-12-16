import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class SorovnomaCont {
  static Map<String, Sorovnoma> obyektlar = {};

  /// hive box of Sorovnoma
  static late Box<Map> box;
  static init() async {
    box = await Hive.openBox("sorovnoma");
    //await box.clear();
    for (Map value in box.values) {
      var obj = Sorovnoma.fromJson(value);
      if (obj.jonatganVaqt != 0 &&
          obj.key != "qoniqdizmi_yoq" &&
          obj.key != "qoniqdizmi_qisman") {
        continue;
      }
      obyektlar[obj.key] = obj;
    }
  }

  static int sonngisvaqt = 0;

  static savolSaqla(List<Map> savollarData) async {
    await init();
    for (var element in savollarData) {
      var sorov = Sorovnoma.fromJson(element);
      obyektlar[sorov.key] = sorov;
      await box.put(sorov.key, sorov.toJson());
    }
  }

  static javobSaqla(BuildContext context, Sorovnoma sorov) async {
    sorov.javobVaqt = DateTime.now().millisecondsSinceEpoch;
    logConsole("Log console: ${sorov.javobVaqt}");
    await box.put(sorov.key, sorov.toJson());
    InwareServer.licTekshir(context, asosiymi: true);
  }

  static dialogQoniqdizmi(BuildContext context) {
    Sozlash.box.put("qoniqdizmiKorVaqt", DateTime.now().millisecondsSinceEpoch);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ilova ishlashi sizni qoniqtirdimi?'),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              dialogFeedback(
                  context, SorovnomaCont.obyektlar["qoniqdizmi_yoq"]!);
              Sozlash.box.put(
                  "qoniqdizmiJavobVaqt", DateTime.now().millisecondsSinceEpoch);
            },
            child: Text("Yo'q", style: TextStyle(color: Colors.red.shade900)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              dialogFeedback(
                  context, SorovnomaCont.obyektlar["qoniqdizmi_qisman"]!);
              Sozlash.box.put(
                  "qoniqdizmiJavobVaqt", DateTime.now().millisecondsSinceEpoch);
            },
            child: Text("Ha, qisman",
                style: TextStyle(color: Colors.grey.shade900)),
          ),
          TextButton(
            onPressed: () {
              Sozlash.box.put(
                  "qoniqdizmiJavobVaqt", DateTime.now().millisecondsSinceEpoch);
              Navigator.pop(context);
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                      "Dasturchilar ilovani siz uchun qulay va foydali bo'lishi uchun harakat qilishyapti, google playga o'tib, mehnatini baholashizni taklif qilamiz"),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          var uri = Uri.parse(InwareServer.linkGooglePlay);
                          if (await canLaunchUrl(uri)) {
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                            SorovnomaCont
                                    .obyektlar['qoniqdizmi_yoq']!.javobVaqt =
                                DateTime.now().millisecondsSinceEpoch;
                            SorovnomaCont
                                    .obyektlar['qoniqdizmi_qisman']!.javobVaqt =
                                DateTime.now().millisecondsSinceEpoch;
                            javobSaqla(context,
                                SorovnomaCont.obyektlar['qoniqdizmi_yoq']!);
                            javobSaqla(context,
                                SorovnomaCont.obyektlar['qoniqdizmi_qisman']!);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Internetga ulaning"),
                              duration: Duration(seconds: 5),
                              backgroundColor: Colors.amberAccent,
                            ));
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Text("Google Playga o'tish"),
                        )),
                  ],
                ),
              );
            },
            child: Text("Ha", style: TextStyle(color: Colors.blue.shade700)),
          ),
        ],
      ),
    );
  }

  static dialogFeedback(BuildContext context, Sorovnoma sorov) {
    var feedbackController = TextEditingController();
    Sozlash.box.put("songgiSorovVaqt", DateTime.now().millisecondsSinceEpoch);
    sorov.korganVaqt = DateTime.now().millisecondsSinceEpoch;
    box.put(sorov.key, sorov.toJson());
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(sorov.savol, style: const TextStyle(fontSize: 16.5)),
        contentPadding: const EdgeInsets.all(10),
        children: [
          TextFormField(
            autofocus: true,
            controller: feedbackController,
            decoration: const InputDecoration(
              labelText: "Javob",
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            maxLines: 3,
          ),
          Container(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () async {
                sorov.javob = feedbackController.text;
                javobSaqla(context, sorov);
                Navigator.pop(context);
              },
              child: const Text("Jo'natish"),
            ),
          ),
        ],
      ),
    );
  }
}

class Sorovnoma {
  int tr = 0;
  int korganVaqt = 0;
  int javobVaqt = 0;
  int jonatganVaqt = 0;
  String key = '';
  String savol = '';
  String javob = '';

  Sorovnoma(this.tr, this.key, {required this.savol, this.javob = ''});

  Sorovnoma.bosh();

  Sorovnoma.fromJson(Map json)
      : tr = int.parse(json['tr'].toString()),
        key = json['sorov_key'] ?? "",
        savol = json['savol'] ?? "",
        javob = json['javob'] ?? "",
        javobVaqt = json['javobVaqt'] ?? 0,
        korganVaqt = json['korganVaqt'] ?? 0,
        jonatganVaqt = json['jonatganVaqt'] ?? 0;

  Map<String, dynamic> toJson() => {
        "tr": tr,
        "sorov_key": key,
        "savol": savol,
        "javob": javob,
        "javobVaqt": javobVaqt,
        "korganVaqt": korganVaqt,
        "jonatganVaqt": jonatganVaqt,
      };

  Map<String, dynamic> toServer() => {
        "sorov_key": key,
        "javob": javob,
        "javobVaqt": toSecond(javobVaqt),
        "korganVaqt": toSecond(korganVaqt),
      };

  Sorovnoma fromServer(Map json) {
    tr = int.parse(json['tr'].toString());
    key = json['sorov_key'] ?? "";
    savol = json['savol'] ?? "";
    return this;
  }
}
