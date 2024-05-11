class DFXFeesData {
  final num rate;
  final num fixed;
  final num network;
  final num min;
  final num dfx;
  final num total;

  const DFXFeesData({
    required this.rate,
    required this.fixed,
    required this.network,
    required this.min,
    required this.dfx,
    required this.total,
  });

  DFXFeesData.fromJson(Map<String, dynamic> json)
      : rate = json['rate'] as num,
        fixed = json['fixed'] as num,
        network = json['network'] as num,
        min = json['min'] as num,
        dfx = json['dfx'] as num,
        total = json['total'] as num;
}
