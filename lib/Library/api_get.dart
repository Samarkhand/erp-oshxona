import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/Model/m_artikul.dart';
import 'package:erp_oshxona/Model/m_tarkib.dart';
import 'package:erp_oshxona/Model/mahal.dart';
import 'package:erp_oshxona/Model/smena.dart';
import 'package:erp_oshxona/Model/kBolim.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/Model/m_bolim.dart';
import 'package:erp_oshxona/Model/m_brend.dart';
import 'package:erp_oshxona/Model/m_code.dart';
import 'package:erp_oshxona/Model/m_olchov.dart';
import 'package:erp_oshxona/Model/mah_qoldiq.dart';
import 'package:erp_oshxona/Model/mahsulot.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SyncServer{
  
  static Future getData(BuildContext context, {bool asosiymi = false}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Internetga ulaning"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.amberAccent,
      ));
      return;
    }
    final url = "${InwareServer.urlGetInfo}&all=1";
    final Map<String, String> headers = {"Auth": Sozlash.token};
    final Map<dynamic, dynamic> bodyMap = {};

    logConsole("GET URL: $url");
    logConsole("REQUEST head: $headers");
    logConsole("REQUEST body: $bodyMap");
    Response reply = await apiPost(url, jsonMap: bodyMap, headers: headers);
    logConsole("RESPONSE head: (${reply.statusCode}) ${reply.headers}");
    logConsole("RESPONSE body: ${reply.body}");
    Map<dynamic, dynamic>? result = jsonDecode(reply.body);

    if(reply.statusCode == 200 && result != null){
      if(result['m_olchov'] != null && (result['m_olchov'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['m_olchov']){
          var object = MOlchov.fromServer(json);
          MOlchov.service!.replace(object.toJson());
          MOlchov.obyektlar[object.tr] = object;
        }
      }
      //
      if(result['m_bolim'] != null && (result['m_bolim'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['m_bolim']){
          var object = MBolim.fromServer(json);
          MBolim.service!.replace(object.toJson());
          MBolim.obyektlar[object.tr] = object;
        }
      }
      //
      if(result['m_brend'] != null && (result['m_brend'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['m_brend']){
          var object = MBrend.fromServer(json);
          MBrend.service!.replace(object.toJson());
          MBrend.obyektlar[object.tr] = object;
        }
      }
      //
      if(result['mahsulot'] != null && (result['mahsulot'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['mahsulot']){
          var object = Mahsulot.fromServer(json);
          Mahsulot.service!.replace(object.toJson());
          Mahsulot.obyektlar[object.tr] = object;
        }
      }
      //
      if(result['m_tarkib'] != null && (result['m_tarkib'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['m_tarkib']){
          var object = MTarkib.fromServer(json);
          MTarkib.service!.replace(object.toJson());
        }
      }
      //
      if(result['m_artikul'] != null && (result['m_artikul'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['m_artikul']){
          var object = MArtikul.fromServer(json);
          MArtikul.service!.replace(object.toJson());
        }
      }
      //
      if(result['m_code'] != null && (result['m_code'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['m_code']){
          var object = MCode.fromServer(json);
          MCode.service!.replace(object.toJson());
          MCode.obyektlar[object.code] = object;
        }
      }
      //
      if(result['qoldiq'] != null && (result['qoldiq'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['qoldiq']){
          var object = MahQoldiq.fromServer(json);
          MahQoldiq.service!.replace(object.toJson());
          MahQoldiq.obyektlar[object.tr] = object;
        }
      }
      //
      if(result['mahal'] != null && (result['mahal'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['mahal']){
          var object = Mahal.fromServer(json);
          Mahal.service!.replace(object.toJson());
          Mahal.obyektlar[object.tr] = object;
        }
      }
      //
      if(result['smena'] != null && (result['smena'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['smena']){
          var object = Smena.fromServer(json);
          Smena.service!.replace(object.toJson());
          Smena.obyektlar[object.tr] = object;
        }
      }
      //
      if(result['kBolim'] != null && (result['kBolim'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['kBolim']){
          var object = KBolim.fromServer(json);
          KBolim.service!.replace(object.toJson());
          KBolim.obyektlar[object.tr] = object;
        }
      }
      //
      if(result['kont'] != null && (result['kont'] as List).isNotEmpty){
        for(Map<String, dynamic> json in result['kont']){
          var object = Kont.fromServer(json);
          Kont.service!.replace(object.toJson());
          Kont.obyektlar[object.tr] = object;
        }
      }
    }

    if (result == null || result['alert'] == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${reply.statusCode} Serverdan hato javob qaytdi"),
        duration: const Duration(seconds: 5),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    } 
    else if (Sozlash.tanishmi || reply.statusCode != 401) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${reply.statusCode} ${result['alert']['title']}. ${result['alert']['description']}"),
        duration: const Duration(seconds: 6),
        backgroundColor: reply.statusCode == 200 ? null : Colors.redAccent,
      ));
    }
  }

}