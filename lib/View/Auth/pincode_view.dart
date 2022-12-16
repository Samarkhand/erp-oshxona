import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/sozlash.dart';
import 'package:erp_oshxona/View/Auth/kirish_view.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

enum AuthPinViewType {
  auth,
  insert,
  update,
}

/*
authType
authPinCode
authPassword
*/

class AuthPinView extends StatefulWidget {
  AuthPinView({super.key, this.type}) {
    type ??= AuthPinViewType.auth;
  }

  late AuthPinViewType? type;

  @override
  AuthPinViewState createState() => AuthPinViewState();
}

class AuthPinViewState extends State<AuthPinView> {
  final _formKey = GlobalKey<FormState>();
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  String label = "";
  late AuthPinController _cont;
  bool togrimi = false;

  @override
  void initState() {
    _cont = AuthPinController(widget.type!);
    _cont.init(widget, setState, context: context);
    if (widget.type == AuthPinViewType.auth) {
      label = "PIN kod kiriting";
    } else if (widget.type == AuthPinViewType.update) {
      label = "Hozirgi PIN kodni kiriting";
    } else if (widget.type == AuthPinViewType.insert) {
      label = "Yangi PIN kod kiriting";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (context) => Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: PageView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    FractionallySizedBox(
                      heightFactor: 1.0,
                      child: Center(
                        child: onlySelectedBorderPinPut(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget onlySelectedBorderPinPut(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            height: 30,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            onLongPress: () {
              logConsole(_formKey.currentState!.validate());
            },
            child: Pinput(
              validator: (s) {
                if (s!.contains('1')) return null;
                return "Noto'g'ri PIN kod";
              },
              useNativeKeyboard: false,
              // autovalidateMode: AutovalidateMode.onUserStringeraction,
              /*withCursor: false,
              fieldsCount: 4,
              fieldsAlignment: MainAxisAlignment.spaceAround,
              textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
              eachFieldMargin: EdgeInsets.all(0),
              eachFieldWidth: 45.0,
              eachFieldHeight: 45.0,*/
              obscureText: true,
              onCompleted: (String pin) => _submitPinCode(pin, context),
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              /*submittedFieldDecoration: pinPutDecoration,
              selectedFieldDecoration: pinPutDecoration.copyWith(
                color: Colors.black,
                border: Border.all(
                  width: 0,
                  color: const Color.fromRGBO(160, 215, 220, 1),
                ),
              ),
              followingFieldDecoration: pinPutDecoration,*/
              pinAnimationType: PinAnimationType.scale,
            ),
          ),
          SizedBox(
            width: 300.0,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((e) {
                  return RoundedButton(
                    title: '$e',
                    onTap: () {
                      if (_pinPutController.text.length >= 4) return;
                      _pinPutController.text = '${_pinPutController.text}$e';
                    },
                  );
                }),
                RoundedButton(
                  title: '',
                  onTap: () {
                    //Navigator.of(context).pop();
                  },
                ),
                RoundedButton(
                  title: '0',
                  onTap: () {
                    if (_pinPutController.text.length >= 4) return;
                    _pinPutController.text = '${_pinPutController.text}0';
                  },
                ),
                MaterialButton(
                  child: const Icon(Icons.backspace, color: Colors.white),
                  onTap: () {
                    if (_pinPutController.text.isNotEmpty) {
                      _pinPutController.text = _pinPutController.text
                          .substring(0, _pinPutController.text.length - 1);
                    }
                  },
                ),
              ],
            ),
          ),
          widget.type == AuthPinViewType.auth
              ? TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KirishView(),
                      ),
                    );
                  },
                  child: const Text(
                    "PIN kodni tiklash",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Future<void> _submitPinCode(String pin, BuildContext context) async {
    logConsole("pin: {$pin}");
    _pinPutController.text = "";
    SnackBar snackBar;
    try {
      if (widget.type == AuthPinViewType.auth) {
        await _cont.kirish(pin, context);
      } else if (widget.type == AuthPinViewType.update) {
        String pinCurrent = Sozlash.pinCode;

        if (pinCurrent == pin && !togrimi) {
          togrimi = true;
          setState(() {
            label = "Yangi PIN kodni kiriting";
            _pinPutController.text = '';
          });
          return;
        } else if (pinCurrent != pin && !togrimi) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Noto'g'ri PIN kod",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.orangeAccent,
          ));
          return;
        } else {
          await _cont.parolOzgartirish(pin);
          if (_cont.pin1.isEmpty) {
            setState(() {
              label = "Yangi PIN kodni kiriting";
              _pinPutController.text = '';
            });
          } else if (_cont.pin2.isEmpty) {
            setState(() {
              label = "Yangi PIN kodni takrorlang";
              _pinPutController.text = '';
            });
          }
        }
      } else if (widget.type == AuthPinViewType.insert) {
        await _cont.parolQoyish(pin);
        if (_cont.pin1.isEmpty) {
          setState(() {
            label = "Yangi PIN kod kiriting";
            _pinPutController.text = '';
          });
        } else if (_cont.pin2.isEmpty) {
          setState(() {
            label = "PIN kodni takrorlang";
            _pinPutController.text = '';
          });
        }
      }
    } catch (e) {
      snackBar = SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          e.toString(),
        ),
        backgroundColor: Colors.orangeAccent,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class AuthPinController with Controller {
  AuthPinViewType type;
  late AuthPinView widget;

  int kirishgaHarakat = 0;
  int blokDaraja = 0;

  String pin1 = "";
  String pin2 = "";

  AuthPinController(this.type);

  Future<void> init(widget, Function setState,
      {required BuildContext context}) async {
    this.setState = setState;
    this.widget = widget;
    this.context = context;
    kirishgaHarakat = 0;
    blokDaraja = 0;
  }

  Future<void> parolOzgartirish(String pin) async {
    if (pin1.isEmpty) {
      pin1 = pin;
      return;
    }
    pin2 = pin;
    if (pin1 == pin2) {
      await Sozlash.box.put("pinCode", pin1);
      await Sozlash.box.put("pinCodeBormi", true);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "PIN kodni noto'g'ri takrorladingiz!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: Duration(seconds: 4),
        backgroundColor: Colors.orangeAccent,
      ));
    }
  }

  Future<void> parolQoyish(String pin) async {
    if (pin1.isEmpty) {
      pin1 = pin;
      return;
    }
    pin2 = pin;
    if (pin1 == pin2) {
      await Sozlash.box.put("pinCode", pin1);
      await Sozlash.box.put("pinCodeBormi", true);
      Navigator.of(context).pop();
    } else {
      setState(() {
        pin1;
        pin2;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "PIN kodni noto'g'ri takrorladingiz!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: Duration(seconds: 4),
        backgroundColor: Colors.orangeAccent,
      ));
    }
  }

  Future<void> kirish(String pin, BuildContext context) async {
    String pinCurrent = Sozlash.pinCode;

    if (pinCurrent == pin) {
      kirishgaHarakat = 0;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => getView(),
        ),
      );
      return;
    } else {
      kirishgaHarakat++;

      throw Exception('Hato pin kod');
    }
  }

  Future<void> parolYoq() async {}

  Future<void> kirishRuhsat(BuildContext context) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => getView(),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const RoundedButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }
}

class MaterialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const MaterialButton({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: child,
    );
  }
}
