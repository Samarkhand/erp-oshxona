import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sorovnoma.dart';
import 'package:erp_oshxona/Model/hisob.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erp_oshxona/Model/aBolim.dart';

class Sozlash {

  /// are values of settings empty? 
  static bool get hasInited => box.isOpen && box.isNotEmpty;
  // avto sozlanadigan
  static bool get tanishmi => box.get("tanishmi", defaultValue: false);
  static bool get blokmi => box.get("blokmi", defaultValue: false);
  static int get blokSabab => box.get("blok_sabab", defaultValue: 0);
  // User
  static int get tr => box.get("tr", defaultValue: 0);
  static String get ism => box.get("ism", defaultValue: "");
  static String get davKod => box.get("davKod", defaultValue: 'UZ');
  static String get telKod => box.get("telKod", defaultValue: '');
  static String get tel => box.get("tel", defaultValue: '');
  static String get token => box.get("token") == null ? "" : "Tanish ${box.get("token")}";
  /// so'nggi dasturga kirgan vaqti
  static int get sdkVaqt => box.get("sdkVaqt", defaultValue: 0);
  /// so'nggi sinxronizatsiya vaqti
  static int get sinVaqt => box.get("sinVaqt", defaultValue: 0);
  /// birinchi kirgan vaqti
  static int get autVaqt => box.get("autVaqt", defaultValue: 0);
  /// registrantsiya vaqti
  static int get regVaqt => box.get("regVaqt", defaultValue: 0);
  /// birinchi kirgan vaqti
  static int get kirVaqt => box.get("kirVaqt", defaultValue: 0);
  /// pinCode
  static String get pinCode => box.get("pinCode", defaultValue: "");
  /// pinCodeBormi
  static bool get pinCodeBormi => box.get("pinCodeBormi", defaultValue: false);
  ///Litsenziya
  static String get litsenziya => box.get("litsenziya", defaultValue: "");
  static int get litVaqtDan => box.get("litVaqtDan", defaultValue: 0);
  static int get litVaqtGac => box.get("litVaqtGac", defaultValue: 0);
  // avto =========================
  static bool get tutored => box.get("tutored", defaultValue: false);
  static bool get tarmoqAzosimi => box.get("tarmoqAzosimi", defaultValue: false);
  static bool get tarmoqTBotAzosimi => box.get("tarmoqTBotAzosimi", defaultValue: false);
  static bool get tarmoqTBotAzosimiTas => box.get("tarmoqTBotAzosimiTas", defaultValue: false);
  static bool get tarmoqTKnAzosimi => box.get("tarmoqTKnlAzosimi", defaultValue: false);
  static bool get tarmoqTGrAzosimi => box.get("tarmoqTGrpAzosimi", defaultValue: false);
  static bool get deviceRegBolganmi => box.get("deviceRegBolganmi", defaultValue: false);
  static int get qoniqdizmiKorVaqt => box.get("qoniqdizmiKorVaqt", defaultValue: 0);
  static int get qoniqdizmiJavobVaqt => box.get("qoniqdizmiJavobVaqt", defaultValue: 0);
  static int get songgiSorovVaqt => box.get("songgiSorovVaqt", defaultValue: 0);
  // odam sozlaydigan
  static Hisob get tanlanganHisob => Hisob.obyektlar[box.get("tanlanganHisob")] ?? Hisob.bosh();
  static ABolim get abolimKomissiya => ABolim.obyektlar[box.get("abolimTrKomissiya")] ?? ABolim();
  static ABolim get abolimMahUchun => ABolim.obyektlar[box.get("abolimMahUchun")] ?? ABolim();
  static ABolim get abolimTransP => ABolim.obyektlar[box.get("abolimTransP")] ?? ABolim();
  static ABolim get abolimTransM => ABolim.obyektlar[box.get("abolimTransM")] ?? ABolim();
  static ABolim get abolimQarzB => ABolim.obyektlar[box.get("abolimQarzB")] ?? ABolim();
  static ABolim get abolimQarzO => ABolim.obyektlar[box.get("abolimQarzO")] ?? ABolim();

  static ABolim get abolimTrMahKirChiq => ABolim.obyektlar[box.get("abolimTrMahKirChiq")] ?? ABolim();
  static ABolim get abolimTrMahSvdTush => ABolim.obyektlar[box.get("abolimTrMahSvdTush")] ?? ABolim();
  // Hisob-kitob 
  static int get yaxlit => box.get("yaxlit", defaultValue: 1);
  
  /// hive box of settings
  static late Box<dynamic> box;

  /// initialize settings every time
  static init() async {
    box = await Hive.openBox("sozlash");
    if(!hasInited) await initValues();
  }

  /// initialize settings first time
  static initValues() async {
    // avto sozlanadigan ####################################################
    await box.put("tanishmi", false);
    await box.put("blokmi", false);
    await box.put("blok_sabab", 0);
    await box.put("sdkVaqt", 0);
    await box.put("sinVaqt", 0);
    await box.put("regVaqt", 0);
    await box.put("autVaqt", 0);
    if(!hasInited)  await box.put("kirVaqt", DateTime.now().millisecondsSinceEpoch);
    // license data
    await box.put("litsenziya", "");
    await box.put("litVaqtDan", 0);
    await box.put("litVaqtGac", 0);
    // user data
    await box.put("tr", 0);
    await box.put("ism", "Yangi");
    await box.put("davKod", "UZ");
    await box.put("telKod", "+998");
    await box.put("tel", "+998001000000");
    await box.put("token", null);
    await box.put("pinCode", null);
    await box.put("pinCodeBormi", false);
    // install
    await box.put("tutored", false);
    await box.put("tarmoqAzosimi", false);
    await box.put("tarmoqTBotAzosimi", false);
    await box.put("tarmoqTBotAzosimiTas", false);
    await box.put("tarmoqTKnlAzosimi", false);
    await box.put("tarmoqTGrpAzosimi", false);
    await box.put("deviceRegBolganmi", false);
    await box.put("qoniqdizmiKorVaqt", 0);
    await box.put("qoniqdizmiJavobVaqt", 0);
    await box.put("songgiSorovVaqt", 0);

    // odam sozlaydigan ####################################################
    await box.put("tanlanganHisob", 0);
    await box.put("abolimTrKomissiya", 0);
    await box.put("abolimMahUchun", 0);
    await box.put("abolimTransP", 0);
    await box.put("abolimTransM", 0);
    await box.put("abolimQarzB", 0);
    await box.put("abolimQarzO", 0);
    /*await box.put("abolimTrMahKirChiq", 0);
    await box.put("abolimTrMahSvdTush", 0);*/
    // TODO: Device register
    // birinchi kirishiga registratsiya qiladi
    // await InwareServer.deviceRegister();

    await SorovnomaCont.init();
    SorovnomaCont.obyektlar["qoniqdizmi_yoq"] = Sorovnoma(1, 'qoniqdizmi_yoq', savol: """Nima sababdan qoniqmayabsiz?
Noqulaylik bo'lsa bartaraf etish ustida ishlaymiz""");
    SorovnomaCont.obyektlar["qoniqdizmi_qisman"] = Sorovnoma(2, 'qoniqdizmi_qisman', savol: "Sizga yana qanday imkoniyat kerak yoki nima noqulaylik bor?");
    await SorovnomaCont.box.put("qoniqdizmi_yoq", SorovnomaCont.obyektlar["qoniqdizmi_yoq"]!.toJson());
    await SorovnomaCont.box.put("qoniqdizmi_qisman", SorovnomaCont.obyektlar["qoniqdizmi_qisman"]!.toJson());
  }
}
