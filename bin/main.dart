

import 'package:charcode/ascii.dart';
import 'package:parse_deriv/parser.dart';

void main(List<String> arguments) {
  test1();
  test2();
}

void test1() {
  var p = Literal($a);
  print(p.derive($a).deriveNull());
}

void test2() {
  var p = Concat(Literal($a), Literal($b));
  print(p.derive($a).derive($b));
}
