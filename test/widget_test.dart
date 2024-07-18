import 'package:bolt11_decoder/bolt11_decoder.dart';

main() {
  Bolt11PaymentRequest req = Bolt11PaymentRequest(
      "lnbc168846150n1pn8pvvvpp5yvzdfq4rwrl5uqjxu69uzj57yxaxzq4z7xv39f5kull9czvwaufqdf82pshjgr5dp5hxgzvd9nksarwd9hxwgrzd9kxcgr5dus8gunpdeekvetjyqcnqvpsxqsyxjzxyp6x7gpjx9jrvdny9csyzmr5v4exuct5d9mx2mre9ss8xetwvssrzvpsxqczqkjrfprzqar0yqc8se34x4jxxwryvvcxgdpcxa3xyetxxycrscmxxfnx2vfkx43rqv35xpnxvvpcvejrjgrkd9sjq3t5dpjhyet4d5kzq5r0d3ukwmmw9ssyzunzd968yatd9ssy7ur5d9kkjumdyphhygzzv9ek2tscqzzsxqzpusp5a3k62dzusgyq0tspfchnxwk6unv3jj2q6drnmdu90p40xpnvr6gs9qyyssqah4gh5kn5z9fpgm2wgund2w629w8yws2vxcak4mn469dvllh3sk5r77lesvy6ug3n0t3mts2dwcnhv5kprv6lwxv49pn38s774rm00gqq8kwtv");
  print("amount: ${req.amount}");
  // => amount: 0
  print("timestamp: ${req.timestamp}");
  // => timestamp: 1496314658

  req.tags.forEach((TaggedField t) {
    print("${t.type}: ${t.data}");
  });
  // => payment_hash: 0001020304050607080900010203040506070809000102030405060708090102
  // => description: Please consider supporting this project
}
