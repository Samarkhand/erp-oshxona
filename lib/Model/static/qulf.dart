import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Widget/tarmoq_azo_widget.dart';
import 'package:flutter/material.dart';

class Qulf {}

class QulfSabab {
  int tr;
  String matn;
  String yechim;
  Function? action;

  QulfSabab(this.tr, {required this.matn, required this.yechim, this.action});

  static Map<int, QulfSabab> obyektlar = {
    tolovQiling.tr: tolovQiling,
    sanaOzgargan.tr: sanaOzgargan,
    tarmoqAzoBol.tr: tarmoqAzoBol,
  };

  static final QulfSabab tolovQiling = QulfSabab(
    1,
    matn: "Ilovadan foydalanish muddati tugadi",
    yechim: """
Foydalanish muddatni uzaytirish uchun o'zingizga qulay tariflardan birini tanlang va litsenziya sotib oling.

Quyidagi tugmaga bosing 
👇👇👇        👇👇👇
""",
    // tariflar, nima uchun pullik?
    action: litOlishButton
  );
  static final QulfSabab sanaOzgargan = QulfSabab(
    2,
    matn: "Qurilmangiz sanasi noto'g'ri",
    yechim:
        "Sana va soatni to'g'ri belgilang va dasturdan butunlay chiqib qayta kiring",
  );
  static QulfSabab tarmoqAzoBol = QulfSabab(
    3,
    matn: "Bepul foydalanish davri tugadi",
    yechim: """Shaxsiy kabinetga kirib, litsenziya sotib oling yoki
Quyida berilgan shartlarni bajarib, dasturdan yana ma'lum muddat bepul foydalanishingiz mumkun""",
    action: (BuildContext context) => const TarmoqAzoWidget(),
  );
}

litOlishButton(BuildContext context) => Material(
      elevation: 2,
      color: Colors.blue,
      shape: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.0,
            color: Colors.blue.shade700
          ),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () async {
          InwareServer.lichkaTarif(context);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.person, color: Colors.white),
              SizedBox(width: 7.0),
              Text(
                "LITSENZIYA OLISH",
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );