import 'package:erp_oshxona/Model/system/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

  Future<String?> inputDialog(BuildContext context, String? qiymat, {String title = 'Miqdor kiriting', String hintText = "Miqdori", Function? onCancel, Function? onSave}) async {
    var cont = TextEditingController(text: qiymat);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: cont,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
            ],
            autofocus: true,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hintText,
              suffix: IconButton(
                icon: const Icon(Icons.close), 
                onPressed: () {
                  cont.text = "";
                  qiymat = "";
                },
              ),
            ),
            onChanged: ((value) => qiymat = value),
            onSubmitted: (value) {
              onSave ?? false;
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Bekor', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                onCancel ?? false;
                qiymat = null;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Saqlash'),
              onPressed: () {
                onSave ?? false;
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
    return qiymat;
  }

  Future<void>? deleteDialog(BuildContext context, {Function()? yes, Function()? cancel}) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O`chirilsinmi?'),
        content: const Text(
            'O`chirmoqchi bo`lgan elementingizni qayta tiklab bo`lmaydi'),
        actions: [
          TextButton(
            onPressed: (){
              yes != null ? yes() : null;
              Navigator.pop(context);
            },
            child: const Text('O`CHIRILSIN'),
          ),
          TextButton(
            onPressed: (){
              cancel != null ? cancel() : null;
              Navigator.pop(context);
            },
            child: const Text('BEKOR', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void>? alertDialog(BuildContext context, Alert alert, {Function()? yes, Function()? cancel}) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: Text(alert.desc),
        actions: [
          TextButton(
            onPressed: (){
              yes != null ? yes() : null;
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: (){
              cancel != null ? cancel() : null;
              Navigator.pop(context);
            },
            child: const Text('BEKOR', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
