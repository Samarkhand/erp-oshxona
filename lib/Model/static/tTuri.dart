
class TolovTuri{
  static Map<int, TolovTuri> obyektlar = {};
  
  final int tr;
  int trHisob;
  String nomi;

  TolovTuri(this.tr, this.trHisob, this.nomi);

  TolovTuri.fromJson(Map<dynamic, dynamic> json)
      : tr = int.parse(json['tr'].toString()),
        trHisob = int.parse(json['trHisob'].toString()),
        nomi = json['nomi'].toString();

  Map<dynamic, dynamic> toJson() => {
        'tr': tr,
        'trHisob': trHisob,
        'nomi': nomi,
      };

  @override
  String toString() {
    return "$tr $nomi";
  }

  @override
  operator == (other) => other is TolovTuri && other.tr == tr;

  @override
  int get hashCode => tr.hashCode ^ nomi.hashCode;

}


class SaqlashTuri{
  static const naqd = 1;
  static const plastik = 2;
  static const elHamyon = 3;
  static const bank = 4;

  static final Map<int, SaqlashTuri> obyektlar = {
    naqd: SaqlashTuri(naqd, "Naqd"),
    plastik: SaqlashTuri(plastik, "Plastik"),
    elHamyon: SaqlashTuri(elHamyon, "Elektron hamyon"),
    bank: SaqlashTuri(bank, "Bank"),
  };

  final int tr;
  final String nomi;

  SaqlashTuri(this.tr, this.nomi);
}
