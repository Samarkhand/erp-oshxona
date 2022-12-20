import 'package:flutter/material.dart';

Future<String?> inputDialog(BuildContext context, String? qiymat, {Function? onCancel, Function? onSave}) async {
    var cont = TextEditingController(text: qiymat);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Miqdor kiriting'),
          content: TextField(
              controller: cont,
            autofocus: true,
            textAlign: TextAlign.center,
            onChanged: ((value) => qiymat = value),
            decoration: InputDecoration(
              hintText: "Miqdori",
              suffix: IconButton(
                icon: const Icon(Icons.close), 
                onPressed: () {
                  cont.text = "";
                  qiymat = "";
                },
              ),
            ),
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
