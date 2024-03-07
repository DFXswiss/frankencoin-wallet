import 'package:basic_utils/basic_utils.dart';
import 'package:frankencoin_wallet/src/core/alias_resolver/alias_resolver.dart';

class OpenAliasResolver extends AliasResolver {
  @override
  Future<AliasRecord?> lookupAlias(String alias, String ticker,
      [String? tickerFallback]) async {
    final records = await lookupOpenAliasRecord(alias);

    if (records == null) return null;

    AliasRecord? result = fetchAddressAndName(
        formattedName: alias, ticker: ticker, txtRecords: records);

    if (tickerFallback != null && result == null) {
      result = fetchAddressAndName(
          formattedName: alias, ticker: tickerFallback, txtRecords: records);
    }

    return result;
  }

  Future<List<RRecord>?> lookupOpenAliasRecord(String name) async {
    try {
      final txtRecord =
          await DnsUtils.lookupRecord(name, RRecordType.TXT, dnssec: true);

      return txtRecord;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  AliasRecord? fetchAddressAndName({
    required String formattedName,
    required String ticker,
    required List<RRecord> txtRecords,
  }) {
    String address = '';
    String name = formattedName;
    String note = '';

    for (RRecord element in txtRecords) {
      String record = element.data;

      if (record.contains("oa1:$ticker") &&
          record.contains("recipient_address")) {
        record = record.replaceAll('"', "");

        final dataList = record.split(";");

        address = dataList
            .firstWhere((item) => (item.contains("recipient_address")))
            .replaceAll("oa1:$ticker recipient_address=", "")
            .replaceAll("(", "")
            .replaceAll(")", "")
            .trim();

        final recipientName = dataList
            .firstWhere((item) => (item.contains("recipient_name")))
            .replaceAll("(", "")
            .replaceAll(")", "")
            .trim();

        if (recipientName.isNotEmpty) {
          name = recipientName.replaceAll("recipient_name=", "");
        }

        final description = dataList
            .firstWhere((item) => (item.contains("tx_description")))
            .replaceAll("(", "")
            .replaceAll(")", "")
            .trim();

        if (description.isNotEmpty) {
          note = description.replaceAll("tx_description=", "");
        }

        break;
      }
    }

    if (address.isEmpty) return null;

    return AliasRecord(address: address, name: name, description: note);
  }
}
