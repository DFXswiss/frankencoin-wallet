import 'package:web3dart/web3dart.dart' as web3;

final _contractAbi = web3.ContractAbi.fromJson(
    '[{"inputs":[{"internalType":"contract Frankencoin","name":"zchf_","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"allowance","type":"uint256"},{"internalType":"uint256","name":"needed","type":"uint256"}],"name":"ERC20InsufficientAllowance","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"balance","type":"uint256"},{"internalType":"uint256","name":"needed","type":"uint256"}],"name":"ERC20InsufficientBalance","type":"error"},{"inputs":[],"name":"NotQualified","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"}],"name":"Delegation","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"who","type":"address"},{"indexed":false,"internalType":"int256","name":"amount","type":"int256"},{"indexed":false,"internalType":"uint256","name":"totPrice","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"newprice","type":"uint256"}],"name":"Trade","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[],"name":"DOMAIN_SEPARATOR","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MIN_HOLDING_DURATION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"VALUATION_FACTOR","outputs":[{"internalType":"uint32","name":"","type":"uint32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"shares","type":"uint256"}],"name":"calculateProceeds","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"investment","type":"uint256"}],"name":"calculateShares","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"canRedeem","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"address[]","name":"helpers","type":"address[]"}],"name":"checkQualified","outputs":[],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"delegate","type":"address"}],"name":"delegateVoteTo","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"delegates","outputs":[{"internalType":"address","name":"delegate","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"holder","type":"address"}],"name":"holdingDuration","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"expectedShares","type":"uint256"}],"name":"invest","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address[]","name":"targets","type":"address[]"},{"internalType":"uint256","name":"votesToDestroy","type":"uint256"}],"name":"kamikaze","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"nonces","outputs":[{"internalType":"uint256","name":"nonce","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"permit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"price","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"target","type":"address"},{"internalType":"uint256","name":"shares","type":"uint256"}],"name":"redeem","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"target","type":"address"},{"internalType":"uint256","name":"shares","type":"uint256"},{"internalType":"uint256","name":"expectedProceeds","type":"uint256"}],"name":"redeemExpected","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"target","type":"address"},{"internalType":"uint256","name":"shares","type":"uint256"},{"internalType":"uint256","name":"expectedProceeds","type":"uint256"}],"name":"redeemFrom","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"holder","type":"address"}],"name":"relativeVotes","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address[]","name":"helpers","type":"address[]"},{"internalType":"address[]","name":"addressesToWipe","type":"address[]"}],"name":"restructureCapTable","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalVotes","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"holder","type":"address"}],"name":"votes","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"address[]","name":"helpers","type":"address[]"}],"name":"votesDelegated","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"zchf","outputs":[{"internalType":"contract Frankencoin","name":"","type":"address"}],"stateMutability":"view","type":"function"}]',
    'Erc20');

/// Interface of the ERC20 standard as defined in the EIP.
class Equity extends web3.GeneratedContract {
  /// Constructor.
  Equity({
    required web3.EthereumAddress address,
    required web3.Web3Client client,
    int? chainId,
  }) : super(web3.DeployedContract(_contractAbi, address), client, chainId);

  /// Returns the price of one FPS in ZCHF with 18 decimals precision.
  Future<BigInt> price({
    web3.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[19];
    assert(checkSignature(function, 'a035b1fe'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// Returns the price of one FPS in ZCHF with 18 decimals precision.
  Future<BigInt> totalSupply({
    web3.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[26];
    assert(checkSignature(function, '18160ddd'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// Calculate ZCHF received when depositing shares
  /// [shares] number of shares we want to exchange for ZCHF in dec18 format
  /// It returns the amount of ZCHF received for the shares
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> calculateProceeds(
    BigInt shares, {
    web3.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, 'ad08ce5b'));
    final params = [shares];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// Calculate shares received when investing Frankencoins
  /// [investment] is ZCHF to be invested
  /// It returns shares to be received in return
  Future<BigInt> calculateShares(
    BigInt investment, {
    web3.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '3ec16194'));
    final params = [investment];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// Returns whether the given address is allowed to redeem FPS, which is the
  /// case after their average holding duration is larger than the required minimum.
  Future<bool> canRedeem(
    web3.EthereumAddress owner, {
    web3.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '151535b9'));
    final params = [owner];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// Checks whether the sender address is qualified given a list of helpers
  /// that delegated their votes directly or indirectly to the sender.
  /// It is the responsibility of the caller to figure out whether helper are
  /// necessary and to identify them by scanning the blockchain for Delegation events.
  // Future<bool> checkQualified(
  //   web3.EthereumAddress sender,
  //   List<web3.EthereumAddress> helpers, {
  //   web3.BlockNum? atBlock,
  // }) async {
  //   final function = self.abi.functions[8];
  //   print(bytesToHex(function.selector));
  //   assert(checkSignature(function, '151535b9'));
  //   final params = [sender, helpers];
  //   final response = await read(function, params, atBlock);
  //   return (response[0] as bool);
  // }

  /// Call this method to obtain newly minted pool shares in exchange for Frankencoins.
  /// No allowance required (i.e. it is hardcoded in the Frankencoin token contract).
  /// Make sure to invest at least 10e-12 * market cap to avoid rounding losses.
  ///
  /// The [amount] of Frankencoins to invest
  /// The minimum amount of [expectedShares] for frontrunning protection
  Future<String> invest(
    BigInt amount,
    BigInt expectedShares, {
    required web3.Credentials credentials,
    web3.Transaction? transaction,
  }) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, 'd87aa643'));
    final params = [amount, expectedShares];
    return write(credentials, transaction, function, params);
  }



  /// Returns a live stream of all Trade events emitted by this contract.
  Stream<Delegation> delegationEvents(
      {web3.BlockNum? fromBlock, web3.BlockNum? toBlock}) {
    final event = self.event('Delegation');
    final filter = web3.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Delegation._(decoded);
    });
  }

  /// Returns a live stream of all Trade events emitted by this contract.
  Stream<Trade> tradeEvents(
      {web3.BlockNum? fromBlock, web3.BlockNum? toBlock}) {
    final event = self.event('Trade');
    final filter = web3.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Trade._(decoded);
    });
  }
}

/// indicates a delegation
class Delegation {
  Delegation._(List<dynamic> response)
      : from = (response[0] as web3.EthereumAddress),
        to = (response[1] as web3.EthereumAddress);

  final web3.EthereumAddress from;

  final web3.EthereumAddress to;
}

class Trade {
  Trade._(List<dynamic> response)
      : who = (response[0] as web3.EthereumAddress),
        amount = (response[1] as BigInt),
        totPrice = (response[2] as BigInt),
        newPrice = (response[3] as BigInt);

  final web3.EthereumAddress who;

  // amount pos or neg for mint or redemption
  final BigInt amount;

  final BigInt totPrice;

  final BigInt newPrice;
}
