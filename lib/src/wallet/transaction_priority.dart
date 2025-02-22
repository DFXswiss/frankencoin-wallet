enum TransactionPriority {
  slow(1),
  medium(2),
  fast(4);

  const TransactionPriority(this.tip);

  final int tip;
}
