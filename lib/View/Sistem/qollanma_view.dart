import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:erp_oshxona/View/Sistem/qollanma_cont.dart';

class QollanmaView extends StatefulWidget {
  const QollanmaView({required this.sahifa, Key? key})
      : super(key: key);
  final String sahifa;

  @override
  State<QollanmaView> createState() => _QollanmaViewState();
}

class _QollanmaViewState extends State<QollanmaView> {
  final QollanmaCont _cont = QollanmaCont();
  bool yuklanmoqda = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).cardColor,
      appBar: _appBar(context,
          title: _cont.title),
      body: _cont.isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(_cont.loadingLabel),
                    ),
                  ],
                ),
              )
            : _body(context),
      ),
    );
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
    );
  }

  Widget _body(context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: HtmlWidget(
          _cont.text,
          textStyle: const TextStyle(fontSize: 16),
          onErrorBuilder: (context, element, error) => Text('$element hatolik: $error'),
          onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
        ),
      ),
    );
  }

  /* ================= */

  @override
  void initState() {
    _cont.init(widget, setState, context: super.context);
    super.initState();
  }
}
