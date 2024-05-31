import 'package:frankencoin_wallet/src/core/dfx/models/dfx_fees_data.dart';
import 'package:frankencoin_wallet/src/core/dfx/models/dfx_asset_data.dart';

class DFXSwapPaymentInfosData {
  final int routeId;
  final String depositAddress;
  final DFXFeesData fees;
  final num minVolume;
  final num maxVolume;
  final num amount;
  final DFXAssetData sourceAsset;
  final DFXFeesData feesTarget;
  final num minVolumeTarget;
  final num maxVolumeTarget;
  final num exchangeRate;
  final num rate;
  final bool exactPrice;
  final num estimatedAmount;
  final DFXAssetData targetAsset;
  final String? paymentRequest;
  final bool isValid;
  final String? error;

  const DFXSwapPaymentInfosData({
    required this.routeId,
    required this.depositAddress,
    required this.fees,
    required this.minVolume,
    required this.maxVolume,
    required this.amount,
    required this.sourceAsset,
    required this.feesTarget,
    required this.minVolumeTarget,
    required this.maxVolumeTarget,
    required this.exchangeRate,
    required this.rate,
    required this.exactPrice,
    required this.estimatedAmount,
    required this.targetAsset,
    required this.paymentRequest,
    required this.isValid,
    required this.error,
  });

  DFXSwapPaymentInfosData.fromJson(Map<String, dynamic> json)
      : routeId = json['routeId'] as int,
        depositAddress = json['depositAddress'] as String,
        fees = DFXFeesData.fromJson(json['fees']),
        minVolume = json['minVolume'] as num,
        maxVolume = json['maxVolume'] as num,
        amount = json['amount'] as num,
        sourceAsset = DFXAssetData.fromJson(json['sourceAsset']),
        feesTarget = DFXFeesData.fromJson(json['feesTarget']),
        minVolumeTarget = json['minVolumeTarget'] as num,
        maxVolumeTarget = json['maxVolumeTarget'] as num,
        exchangeRate = json['exchangeRate'] as num,
        rate = json['rate'] as num,
        exactPrice = json['exactPrice'] as bool,
        estimatedAmount = json['estimatedAmount'] as num,
        targetAsset = DFXAssetData.fromJson(json['targetAsset']),
        paymentRequest = json['paymentRequest'] as String?,
        isValid = json['isValid'] as bool,
        error = json['error'] as String?;
}
