import 'package:convert/convert.dart';
import 'package:frankencoin_wallet/src/core/contracts/Frankencoin.g.dart';
import 'package:web3dart/web3dart.dart';

extension PrepareTransaction on Frankencoin {
  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> prepareTransfer(
    ({EthereumAddress recipient, BigInt amount}) args, {
    required Credentials credentials,
    Transaction? transaction,
  }) async {
    final function = self.abi.functions[35];
    assert(checkSignature(function, 'a9059cbb'));
    final params = [
      args.recipient,
      args.amount,
    ];
    return _prepareWrite(
      credentials,
      transaction,
      function,
      params,
    );
  }

  Future<String> _prepareWrite(
    Credentials credentials,
    Transaction? base,
    ContractFunction function,
    List<dynamic> parameters,
  ) {
    final transaction = base?.copyWith(
          data: function.encodeCall(parameters),
          to: self.address,
        ) ??
        Transaction.callContract(
          contract: self,
          function: function,
          parameters: parameters,
        );

    return _prepareTransaction(
      credentials,
      transaction,
      chainId: chainId,
      fetchChainIdFromNetworkId: chainId == null,
    );
  }

  Future<String> _prepareTransaction(
    Credentials credentials,
    Transaction transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  }) async {
    if (credentials is CustomTransactionSender) {
      return credentials.sendTransaction(transaction);
    }

    var signed = await client.signTransaction(
      credentials,
      transaction,
      chainId: chainId,
      fetchChainIdFromNetworkId: fetchChainIdFromNetworkId,
    );

    if (transaction.isEIP1559) {
      signed = prependTransactionType(0x02, signed);
    }

    return hex.encode(signed);
  }
}
