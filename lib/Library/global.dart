// ignore: constant_identifier_names
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:process_run/shell.dart';

final sumFormat = NumberFormat.currency(
  locale: "am", // ru, am
  name: "",
  symbol: "",
  decimalDigits: 0,
  customPattern: "#,###",
);

final DateFormat dateFormat = DateFormat('dd.MM.yyyy');
final DateFormat dateTimeFormat = DateFormat('dd.MM.yyyy H:m');
final DateFormat hourMinuteFormat = DateFormat('H:m');

DateTime get now => DateTime.now();
DateTime today =
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
/*
final String formatted = formatter.format(now);
*/

class Global {
  static const bool ruhsatBormi = true;
  static const int database = 1;
  static final Map<int, Database> databases = {
    1: Database()
      ..tr = 1
      ..nomi = "Base 1"
      ..faylNomi = 'base-1',
    2: Database()
      ..tr = 2
      ..nomi = "Base 2"
      ..faylNomi = 'base-2',
  };

  static const String jwtKey =
      "u#IK3@fyCV~9N4Fjrk6XviOoLGdh2*D801aQxIK\$kjHAB@hUtQCaST3F";
  static const String licenseSalt = "5bPxTd~D92hLJniA";

  static List<TextInputFormatter> doubleRegEx = [
    FilteringTextInputFormatter.allow(RegExp(r'[+-]?([0-9]*[.])?[0-9]+'))
  ];

  static Future<Map<String, dynamic>> deviceInfo() async {
    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      // import 'dart:io'
      IosDeviceInfo data = await deviceInfo.iosInfo;
      //data.identifierForVendor; // unique ID on iOS
      /*return <String, dynamic>{
        'os.type': "iOS",
        'name': data.name,
        'systemName': data.systemName,
        'systemVersion': data.systemVersion,
        'model': data.model,
        'localizedModel': data.localizedModel,
        'identifierForVendor': data.identifierForVendor,
        'isPhysicalDevice': data.isPhysicalDevice,
        'utsname.sysname:': data.utsname.sysname,
        'utsname.nodename:': data.utsname.nodename,
        'utsname.release:': data.utsname.release,
        'utsname.version:': data.utsname.version,
        'utsname.machine:': data.utsname.machine,
      };*/
      return <String, dynamic>{
        'device_id': data.identifierForVendor,
        'brand': data.name,
        'model': data.model,
        'os_type': "iOS",
        'os': data.systemName,
        'os_version': data.systemVersion,
        'isPhysicalDevice': data.isPhysicalDevice,
      };
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo build = await deviceInfo.androidInfo;
      //build.androidId; // unique ID on Android
      /*return <String, dynamic>{
        'os.type': "Adroid",
        'version.securityPatch': build.version.securityPatch,
        'version.sdkInt': build.version.sdkInt,
        'version.release': build.version.release,
        'version.previewSdkInt': build.version.previewSdkInt,
        'version.incremental': build.version.incremental,
        'version.codename': build.version.codename,
        'version.baseOS': build.version.baseOS,
        'board': build.board,
        'bootloader': build.bootloader,
        'brand': build.brand,
        'device': build.device,
        'display': build.display,
        'fingerprint': build.fingerprint,
        'hardware': build.hardware,
        'host': build.host,
        'id': build.id,
        'manufacturer': build.manufacturer,
        'model': build.model,
        'product': build.product,
        'supported32BitAbis': build.supported32BitAbis,
        'supported64BitAbis': build.supported64BitAbis,
        'supportedAbis': build.supportedAbis,
        'tags': build.tags,
        'type': build.type,
        'isPhysicalDevice': build.isPhysicalDevice,
        'androidId': build.androidId,
        'systemFeatures': build.systemFeatures,
      };*/
      return <String, dynamic>{
        'device_id': build.androidId,
        'brand': build.brand,
        'model': build.model,
        'os_type': "Android",
        'os': build.version.sdkInt,
        'os_version': build.version.release,
        'isPhysicalDevice': build.isPhysicalDevice,
      };
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      var shell = Shell();

      var deviceData = await shell.run('''
wmic diskdrive get model
wmic diskdrive get serialnumber

wmic cpu get Name
wmic cpu get ProcessorId

wmic csproduct get Vendor
wmic csproduct get Name 
wmic csproduct get UUID
wmic csproduct get IdentifyingNumber''');

      /*
        for(var res in result){
          ret[res.outLines.elementAt(0)] = res.outLines.elementAt(2);
        }*/

      Map<String, dynamic> ret = {};
      ret['hddModel'] = deviceData[0].outLines.elementAt(2);
      ret['hddSerial'] = deviceData[1].outLines.elementAt(2);

      ret['cpuModel'] = deviceData[2].outLines.elementAt(2);
      ret['cpuId'] = deviceData[3].outLines.elementAt(2);

      ret['csName'] =
          "${deviceData[4].outLines.elementAt(2)} ${deviceData[5].outLines.elementAt(2)}";
      ret['csId'] = deviceData[6].outLines.elementAt(2);
      ret['csIn'] = deviceData[7].outLines.elementAt(2);
      return ret;
    } else {
      return {};
    }
  }
}

class Database {
  int tr = 0;
  String nomi = '';
  String faylNomi = '';

  Database();
}
