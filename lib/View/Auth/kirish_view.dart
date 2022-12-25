import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Auth/registratsiya_view.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/View/Auth/kirish_cont.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class KirishView extends StatefulWidget {
  const KirishView({Key? key}) : super(key: key);

  @override
  State<KirishView> createState() => _KirishViewState();
}

class _KirishViewState extends State<KirishView> {
  final KirishCont _cont = KirishCont();
  bool yuklanmoqda = false;
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _body(context),
      ),
    );
  }

  static const double oraliqPadding = 20;
  Widget _body(context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400.0),
          child: Form(
            key: _cont.formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Image.asset("assets/logo_inware.png", width: 200),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  child: Text("Kirish", style: MyTheme.h2),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        IntlPhoneField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            label: const Text("Telefon"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            //prefixIcon: const Icon(Icons.phone),
                          ),
                          initialCountryCode: 'UZ',
                          autofocus: true,
                          onChanged: (phone) {
                            //logConsole(phone.completeNumber);
                          },
                          onCountryChanged: (country) {
                            //logConsole('Country changed to: ' + country.name);
                          },
                          onSaved: (value) {
                            if (value != null) {
                              _cont.telephone = value;
                            }
                          },
                        ),
                        /*TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          label: const Text("Telefon"),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.person)),
                      autofocus: true,
                      validator: (value) => _cont.validate(value,
                          required: true, nomi: 'Telefon raqamni kiriting'),
                      onSaved: (value) {
                        _cont.telephone = value;
                      },
                    ),*/
                        const SizedBox(
                          height: oraliqPadding,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            label: const Text("Parol"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (showPassword) {
                                  showPassword = false;
                                } else {
                                  showPassword = true;
                                }
                                setState(() {});
                              },
                              icon: showPassword
                                  ? const Icon(Icons.remove_red_eye)
                                  : const Icon(Icons.visibility_off),
                            ),
                          ),
                          validator: (value) => _cont.validate(value,
                              required: true, nomi: 'Parolni kiriting'),
                          onSaved: (value) {
                            _cont.password = value;
                          },
                        ),
                        const SizedBox(
                          height: oraliqPadding,
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 30.0),
                              child: Text("Kirish".toUpperCase()),
                            ),
                            onPressed: () async {
                              await _cont.save(context);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextButton(
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Text("Ro'yxatdan o'tish"),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistratsiyaView(),
                                  ));
                            },
                          ),
                        ),
                        /*Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextButton(
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          child: Text("Parolni unutdim"),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Tez orada qo'shiladi..."),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.blueAccent,
                          ));
                        },
                      ),
                    ),*/
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _cont.init(widget, setState, context: context);
    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
    super.initState();
  }
}
