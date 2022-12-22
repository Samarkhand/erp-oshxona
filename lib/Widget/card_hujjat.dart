import 'package:erp_oshxona/Library/global.dart';
import 'package:erp_oshxona/Library/theme.dart';
import 'package:erp_oshxona/Model/kont.dart';
import 'package:erp_oshxona/View/Hujjat/HujjatIchiView.dart';
import 'package:erp_oshxona/Model/hujjat.dart';
import 'package:erp_oshxona/Model/system/controller.dart';
import 'package:erp_oshxona/View/Kirim/buyurtma_royxat_view.dart';
import 'package:flutter/material.dart';

class HujjatCard extends StatelessWidget {
  const HujjatCard(this.object,
      {Key? key, required this.cont, required this.doAfterDelete})
      : super(key: key);
  final Hujjat object;
  final Controller cont;
  final Function doAfterDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          /*
          showDialog(
            context: context,
            builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10.0)), //this right here
            child: HujjatIchiView(object)),
          );*/
          Widget? view;
          if(HujjatTur.kirim.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.kirimFil.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.qaytibOlish.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.qaytibBerish.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.zarar.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.kirimIch.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.chiqimIch.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.chiqimFil.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.buyurtma.tr == object.turi){
            //HujjatIchiView(object);
            view = BuyurtmaRoyxatView(object);
          }
          else if(HujjatTur.chiqim.tr == object.turi){
            view = BuyurtmaRoyxatView(object);
          }
          if(view == null) return;
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => view!,
              ));
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(children: [
                      //Icon(HujjatTur.obyektlar[object.turi]!.icon, size: 16),
                      Text(
                        "${HujjatTur.obyektlar[object.turi]!.tr}-",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        HujjatTur.obyektlar[object.turi]!.nomi,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ]),
                    object.trKont == 0
                        ? const SizedBox()
                        : Row(children: [
                            const Icon(Icons.person, size: 16),
                            Text(
                              Kont.obyektlar[object.kont]!.nomi,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ]),
                    Text(
                      object.izoh,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Wrap(children: [
                      Text(
                        dateFormat.format(object.sanaDT),
                        style: MyTheme.small.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hourMinuteFormat.format(object.vaqtDT),
                        style: MyTheme.small.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ]),
                    Text(sumFormat.format(object.summa)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openItemActionDialog(BuildContext context) {}
}
