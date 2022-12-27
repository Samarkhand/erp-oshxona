import 'package:erp_oshxona/Library/functions.dart';
import 'package:erp_oshxona/Library/rest_api.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/View/Auth/kirish_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:erp_oshxona/View/Auth/registratsiya_cont.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistratsiyaView extends StatefulWidget {
  const RegistratsiyaView({Key? key}) : super(key: key);

  @override
  State<RegistratsiyaView> createState() => _RegistratsiyaViewState();
}

class _RegistratsiyaViewState extends State<RegistratsiyaView> {
  final RegistratsiyaCont _cont = RegistratsiyaCont();
  bool yuklanmoqda = false;
  bool showPassword = false;

  int tanlanganOyna = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: (tanlanganOyna == 1) ? _body(context) : _oferta(context),
    );
  }

  static const double oraliqPadding = 20;
  Widget _body(context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 10),
                    child: Text("Ro'yxatdan o'tish", style: MyTheme.h2),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                label: const Text("Ism"),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.person)),
                            autofocus: true,
                            validator: (value) => _cont.validate(value,
                                required: true, nomi: 'Ismingizni kiriting'),
                            onSaved: (value) {
                              _cont.ism = value;
                            },
                          ),
                          const SizedBox(
                            height: oraliqPadding,
                          ),
                          IntlPhoneField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              label: const Text("Telefon"),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              //prefixIcon: const Icon(Icons.phone),
                            ),
                            initialCountryCode: 'UZ',
                            onChanged: (phone) {
                              //logConsole(phone.completeNumber);
                            },
                            onCountryChanged: (country) {
                              //logConsole('Country changed to: ' + country.name);
                            },
                            onSaved: (value) {
                              if (value != null) {
                                _cont.tel = value;
                              }
                            },
                          ),
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
                            validator: (value) => _cont.validateParol(value,
                                required: true, nomi: 'Parol kiriting'),
                            onSaved: (value) {
                              _cont.parol = value;
                            },
                          ),
                          const SizedBox(height: oraliqPadding),
                          CheckboxListTile(
                              value: _cont.ofertaTasdiq,
                              onChanged: (value) => setState(
                                    () => {
                                      _cont.ofertaTasdiq = !_cont.ofertaTasdiq
                                    },
                                  ),
                              title: const Text(
                                  "Ommaviy oferta shartlari bilan tanishdim va rozilik bildiraman")),
                          InkWell(
                            child: Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 2),
                              child: const Text(
                                "Ommaviy oferta bilan tanishish",
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            onTap: () async {
                              var uri = Uri.parse(InwareServer.linkOferta);
                              if (await canLaunchUrl(uri)) {
                                launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Internetga ulaning"),
                                  duration: Duration(seconds: 5),
                                  backgroundColor: Colors.amberAccent,
                                ));
                              }
                            },
                          ),
                          const SizedBox(height: oraliqPadding),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ElevatedButton(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 30.0),
                                child: Text("Ro'yxatdan o'tish".toUpperCase()),
                              ),
                              onPressed: () {
                                //_cont.save(context);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextButton(
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 30.0),
                                child: Text("Akkauntim bor"),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const KirishView(),
                                    ));
                              },
                            ),
                          ),
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
      ),
    );
  }

  Widget _oferta(context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ommaviy oferta (taklif)")),
      backgroundColor: Theme.of(context).cardColor,
      body: Column(
        children: <Widget>[
          Expanded(
              child: FutureBuilder<String>(
                  future: _cont.ofertaOl(context), builder: _ofertaKorsat)),
          Material(
            elevation: 4,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _cont.save(context);
                  },
                  label: const Icon(Icons.check),
                  icon: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    child: Text("Qabul qilaman",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _cont.init(widget, setState, context: context);
    //WidgetsBinding.instance.addPostFrameCallback((_) async {});
    super.initState();
  }

  Widget _ofertaKorsat(BuildContext context, AsyncSnapshot snapshot) {
    logConsole(snapshot.connectionState.name);
    logConsole(snapshot.data);
    if (snapshot.connectionState == ConnectionState.done) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: HtmlWidget(
          snapshot.data ?? "Internetga ulaning",
          onErrorBuilder: (context, element, error) =>
              Text('$element hatolik: $error'),
          onLoadingBuilder: (context, element, loadingProgress) =>
              const CircularProgressIndicator(),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
