import 'package:erp_oshxona/View/Sistem/qollanma_view.dart';
import 'package:flutter/material.dart';
import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/amaliyot.dart';
import 'package:erp_oshxona/View/Hisobot/hisobot_cont.dart';
import 'package:erp_oshxona/Widget/card_dashboard_widget.dart';
import 'package:erp_oshxona/Model/aBolim.dart';
import 'package:erp_oshxona/Model/aMahsulot.dart';
import 'package:erp_oshxona/Model/aOrder.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum OynaHisobotView { mablag, xizmat, mahsulot }

class HisobotView extends StatefulWidget {
  const HisobotView({Key? key}) : super(key: key);

  @override
  State<HisobotView> createState() => _HisobotViewState();
}

class _HisobotViewState extends State<HisobotView> {
  OynaHisobotView tanlanganOyna = OynaHisobotView.mablag;
  final HisobotCont _cont = HisobotCont();

  final Map<int, String> _davrlar = {
    1: "Kunlik",
    //2: "Haftalik",
    3: "Oylik",
    4: "Yillik",
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: SafeArea(
            child: Scaffold(
                appBar: _appBar(context, title: "Hisobot"),
                body: (_cont.isLoading)
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
                      ))
                    : RefreshIndicator(
                        child: TabBarView(
                          children: [
                            Builder(builder: (context) => _MablagCards(_cont)),
                            Builder(builder: (context) => _OrderCards(_cont)),
                            Builder(
                                builder: (context) => _MahsulotCards(_cont)),
                          ],
                        ),
                        onRefresh: () async {
                          _cont.hisobotYangila();
                        },
                      ))));
  }

  AppBar? _appBar(BuildContext context, {String? title}) {
    return AppBar(
      title: Text((_cont.isLoading) ? _cont.loadingLabel : title ?? ""),
      bottom: _tabBar(),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: "Saralash",
          onPressed: () {
            _buildSearchField(context, setState);
          },
        ),
        IconButton(
          icon: const Icon(Icons.question_mark_outlined),
          tooltip: "Sahifa bo'yicha qollanma",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return const QollanmaView(
                  sahifa: "hisobot",
                );
              },
            ));
          },
        ),
      ],
    );
  }

  TabBar _tabBar() {
    return const TabBar(
      tabs: [
        Tab(text: "Mablag'"),
        Tab(text: "Xizmat"),
        Tab(text: "Mahsulot"),
      ],
    );
  }

  _buildSearchField(context, StateSetter setState) async {
    return await showMaterialModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Material(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Saralash', style: MyTheme.h3),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      onTap: () =>
                                          _cont.sanaTanlashD(context, setState),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(children: [
                                          const Icon(Icons.date_range),
                                          Text(
                                              " ${dateFormat.format(HisobotCont.sanaD)}"),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      onTap: () =>
                                          _cont.sanaTanlashG(context, setState),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(children: [
                                          const Icon(Icons.date_range),
                                          Text(
                                              " ${dateFormat.format(HisobotCont.sanaG)}"),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                          const SizedBox(height: 20),
                        DropdownButtonFormField(
                          icon: const Icon(Icons.arrow_drop_down),
                          decoration: const InputDecoration(
                            labelText: "Grafik turi",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            fillColor: Colors.white,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          onChanged: (value) {
                            setState(() => HisobotCont.davr = value!);
                          },
                          items: _davrlar.keys.map((priority) {
                            return DropdownMenuItem<int>(
                              value: priority,
                              child: Text(
                                _davrlar[priority]!,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          value: HisobotCont.davr,
                        ),
                          const SizedBox(height: 25),
                          Row(children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Text("Bekor qilish"),
                                ),
                                onPressed: () => setState(() {
                                  setState(() => HisobotCont.sanaD =
                                      DateTime(today.year, today.month));
                                  setState(() => HisobotCont.sanaG = DateTime(
                                      today.year,
                                      today.month,
                                      today.day,
                                      23,
                                      59,
                                      59));
                                }),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Text("Saralash"),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  _cont.showLoading(text: "Yangilanmoqda");
                                  await HisobotCont.hisobotChiqar();
                                  _cont.hideLoading();
                                },
                              ),
                            ),
                          ]),
                          const SizedBox(height: 3),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ));
  }

  @override
  void initState() {
    _cont.init(widget, setState, context: context);
    super.initState();
  }
}

class _MablagCards extends StatefulWidget {
  const _MablagCards(this.cont);

  final HisobotCont cont;

  @override
  State<_MablagCards> createState() => _MablagCardsState();
}

class _MablagCardsState extends State<_MablagCards> {
  ScrollController scrollCont = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollCont,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CardDashboard(
                  title: Text("Tushum", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mabTushumSum),
                      style: MyTheme.h3),
                  //color: Color.fromARGB(255, 97, 230, 79),
                ),
                CardDashboard(
                  title: Text("Chiqim", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mabChiqimSum),
                      style: MyTheme.h3),
                  //color: Color.fromARGB(255, 89, 147, 255),
                ),
              ],
            ),
            Row(
              children: [
                CardDashboard(
                  title: Text("Qarz olindi", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mabQarzOSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFF5959),
                ),
                CardDashboard(
                  title: Text("Qarz berildi", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mabQarzBSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFFb259),
                ),
              ],
            ),
            Row(
              children: [
                CardDashboard(
                  title: Text("Qoldiq", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mablagQoldiq),
                      style: MyTheme.h3),
                  color: const Color.fromARGB(255, 125, 187, 238),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _chart(_chartMalOl()),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.tushum.tr, ABolimTur.tushum.nomi,
                    HisobotCont.abolimMab)),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.chiqim.tr, ABolimTur.chiqim.nomi,
                    HisobotCont.abolimMab)),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  List<LineSeries<Map<String, dynamic>, dynamic>> _chartMalOl() {
    final List<Map<String, dynamic>> chartData =
        HisobotCont.chartDataMab.values.toList();
    chartData.sort((a, b) => a['x'].toString().compareTo(b['x'].toString()));

    return <LineSeries<Map<String, dynamic>, String>>[
      LineSeries<Map<String, dynamic>, String>(
        name: AmaliyotTur.tushum.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AmaliyotTur.tushum.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AmaliyotTur.chiqim.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AmaliyotTur.chiqim.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AmaliyotTur.qarzO.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AmaliyotTur.qarzO.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AmaliyotTur.qarzB.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AmaliyotTur.qarzB.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AmaliyotTur.tushum.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AmaliyotTur.tushum.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
    ];
  }
}

class _OrderCards extends StatefulWidget {
  const _OrderCards(this.cont);

  final HisobotCont cont;

  @override
  State<_OrderCards> createState() => _OrderCardsState();
}

class _OrderCardsState extends State<_OrderCards> {
  ScrollController scrollCont = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollCont,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CardDashboard(
                  title: Text("Unga xizmat", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.ordUngaSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFFb259),
                ),
                CardDashboard(
                  title: Text("Menga xizmat", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.ordMengaSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFF5959),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _chart(_chartMalOl()),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.tushum.tr, AOrderTur.unga.nomi,
                    HisobotCont.abolimOrd)),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.chiqim.tr, AOrderTur.menga.nomi,
                    HisobotCont.abolimOrd)),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  List<LineSeries<Map<String, dynamic>, dynamic>> _chartMalOl() {
    final List<Map<String, dynamic>> chartData =
        HisobotCont.chartDataOrd.values.toList();
    chartData.sort((a, b) => a['x'].toString().compareTo(b['x'].toString()));

    return <LineSeries<Map<String, dynamic>, String>>[
      LineSeries<Map<String, dynamic>, String>(
        name: AOrderTur.menga.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AOrderTur.menga.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AOrderTur.unga.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AOrderTur.unga.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
    ];
  }
}

class _MahsulotCards extends StatefulWidget {
  const _MahsulotCards(this.cont);

  final HisobotCont cont;

  @override
  State<_MahsulotCards> createState() => _MahsulotCardsState();
}

class _MahsulotCardsState extends State<_MahsulotCards> {
  ScrollController scrollCont = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollCont,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CardDashboard(
                  title: Text("Kirim", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mahKirimSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFFb259),
                ),
                CardDashboard(
                  title: Text("Qaytib olindi", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mahVozvratKSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFF5959),
                ),
              ],
            ),
            Row(
              children: [
                CardDashboard(
                  title: Text("Savdo", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mahSavdoSum),
                      style: MyTheme.h3),
                  color: const Color.fromARGB(255, 125, 187, 238),
                ),
              ],
            ),
            Row(
              children: [
                CardDashboard(
                  title: Text("Ro'yxatdan o'chirildi", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mahSpisanyaSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFF5959),
                ),
                CardDashboard(
                  title: Text("Qaytib berildi", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mahVozvratCSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFF5959),
                ),
              ],
            ),
            Row(
              children: [
                CardDashboard(
                  title: Text("Qoldiq", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mahQoldiqSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFF5959),
                ),
                CardDashboard(
                  title: Text("Foyda", style: MyTheme.small),
                  subtitle: Text(sumFormat.format(HisobotCont.mahFoydaSum),
                      style: MyTheme.h3),
                  //color: Color(0xFFFF5959),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _chart(_chartMalOl()),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.mahsulot.tr,
                    AMahsulotTur.savdo.nomi, HisobotCont.abolimAMahSav)),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.mahsulot.tr,
                    AMahsulotTur.kirim.nomi, HisobotCont.abolimAMahKir)),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.mahsulot.tr,
                    AMahsulotTur.vozvratKir.nomi, HisobotCont.abolimAMahVozK)),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.mahsulot.tr,
                    AMahsulotTur.vozvratChiq.nomi, HisobotCont.abolimAMahVozC)),
            const SizedBox(height: 10),
            CardWithList(
                child: _bolimList(ABolimTur.mahsulot.tr,
                    AMahsulotTur.spisanya.nomi, HisobotCont.abolimAMahSpi)),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  List<LineSeries<Map<String, dynamic>, dynamic>> _chartMalOl() {
    final List<Map<String, dynamic>> chartData =
        HisobotCont.chartDataMah.values.toList();
    chartData.sort((a, b) => a['x'].toString().compareTo(b['x'].toString()));

    return <LineSeries<Map<String, dynamic>, String>>[
      LineSeries<Map<String, dynamic>, String>(
        name: AMahsulotTur.kirim.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AMahsulotTur.kirim.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AMahsulotTur.vozvratKir.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AMahsulotTur.vozvratKir.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AMahsulotTur.vozvratChiq.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AMahsulotTur.vozvratChiq.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AMahsulotTur.spisanya.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AMahsulotTur.spisanya.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
      LineSeries<Map<String, dynamic>, String>(
        name: AMahsulotTur.savdo.nomi,
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> sales, _) => sales['x'],
        yValueMapper: (Map<String, dynamic> sales, _) =>
            sales["${AMahsulotTur.savdo.tr}"],
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 4,
          width: 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          //borderColor: Colors.red,
        ),
      ),
    ];
  }
}

Widget _bolimList(int turi, String sarlavha, Map<int, num> summalar) {
  var objectList =
      ABolim.obyektlar.values.where((element) => element.turi == turi).toList();
  objectList.sort((a, b) => -b.tartib.compareTo(a.tartib));
  List<Widget> childList = [];

  for (var object in objectList) {
    if (summalar[object.tr] == null) continue;
    childList.add(
      ListTile(
        leading: Icon(object.icon),
        title: Text(object.nomi),
        trailing: Text(sumFormat.format(summalar[object.tr]!)),
      ),
    );
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
          Container(
              alignment: Alignment.center,
              child: Text(
                sarlavha,
                style: MyTheme.h5,
              )),
        ] +
        childList,
  );
}

Widget _chart(List<LineSeries<dynamic, dynamic>> chartMal,
    {String title = 'Grafik'}) {
  return SizedBox(
    height: 600,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: SfCartesianChart(
        title: ChartTitle(text: title, textStyle: MyTheme.h5),
        legend: Legend(isVisible: true),
        series: chartMal,
        tooltipBehavior: TooltipBehavior(enable: true),
        // Assigning visible minimum and maximum to the x-axis.
        primaryXAxis: CategoryAxis(
          visibleMinimum: 1,
          interval: 1,
          labelRotation: 50,
        ),
        zoomPanBehavior: ZoomPanBehavior(),
      ),
    ),
  );
}
