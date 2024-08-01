import 'package:eth_sig_util/eth_sig_util.dart';

String getPermit(
  String privateKey, {
  required String erc20name,
  required int chainId,
  required String tokenAddress,
  required String owner,
  required String spender,
  required BigInt value,
  required int nonce,
  required int deadline,
}) =>
    EthSigUtil.signTypedData(
        privateKey: privateKey,
        jsonData: '''
{
  "types": {
    "EIP712Domain": [
      {
        "name": "name",
        "type": "string"
      },
      {
        "name": "version",
        "type": "string"
      },
      {
        "name": "chainId",
        "type": "uint256"
      },
      {
        "name": "verifyingContract",
        "type": "address"
      }
    ],
    "Permit": [
      {
        "name": "owner",
        "type": "address"
      },
      {
        "name": "spender",
        "type": "address"
      },
      {
        "name": "value",
        "type": "uint256"
      },
      {
        "name": "nonce",
        "type": "uint256"
      },
      {
        "name": "deadline",
        "type": "uint256"
      }
    ]
  },
  "primaryType": "Permit",
  "domain": {
    "name": "$erc20name",
    "version": "1",
    "chainId": "$chainId",
    "verifyingContract": "$tokenAddress"
  },
  "message": {
    "owner": "$owner",
    "spender": "$spender",
    "value": "$value",
    "nonce": "$nonce",
    "deadline": "$deadline"
  }
}
''',
        version: TypedDataVersion.V4);
