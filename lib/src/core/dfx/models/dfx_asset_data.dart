class DFXAssetData {
  final int id;
  final String name;
  final String chainId;
  final String explorerUrl;
  final String uniqueName;
  final String description;
  final String type;
  final String category;
  final String dexName;
  final bool comingSoon;
  final bool buyable;
  final bool sellable;
  final bool cardBuyable;
  final bool cardSellable;
  final bool instantBuyable;
  final bool instantSellable;
  final String blockchain;
  final int sortOrder;

  const DFXAssetData({
    required this.id,
    required this.name,
    required this.chainId,
    required this.explorerUrl,
    required this.uniqueName,
    required this.description,
    required this.type,
    required this.category,
    required this.dexName,
    required this.comingSoon,
    required this.buyable,
    required this.sellable,
    required this.cardBuyable,
    required this.cardSellable,
    required this.instantBuyable,
    required this.instantSellable,
    required this.blockchain,
    required this.sortOrder,
  });

  DFXAssetData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        chainId = json['chainId'] as String,
        explorerUrl = json['explorerUrl'] as String,
        uniqueName = json['uniqueName'] as String,
        description = json['description'] as String,
        type = json['type'] as String,
        category = json['category'] as String,
        dexName = json['dexName'] as String,
        comingSoon = json['comingSoon'] as bool,
        buyable = json['buyable'] as bool,
        sellable = json['sellable'] as bool,
        cardBuyable = json['cardBuyable'] as bool,
        cardSellable = json['cardSellable'] as bool,
        instantBuyable = json['instantBuyable'] as bool,
        instantSellable = json['instantSellable'] as bool,
        blockchain = json['blockchain'] as String,
        sortOrder = json['sortOrder'] as int;
}
