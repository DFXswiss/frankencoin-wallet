
const evmChainAmountLength = 18;
const evmChainAmountDivider = 1000000000000000000;

class EVMChainFormatter {
  static int parseEVMChainAmount(String amount) {
    try {
      return (double.parse(amount) * evmChainAmountDivider).round();
    } catch (_) {
      return 0;
    }
  }

  static double parseEVMChainAmountToDouble(int amount) {
    try {
      return amount / evmChainAmountDivider;
    } catch (_) {
      return 0;
    }
  }
}
