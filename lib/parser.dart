import 'package:tuple/tuple.dart';

abstract class Parser {
  Parser derive(int char);
  Set deriveNull();
  Parser compact(Set seen) {
    if (!seen.contains(this)) {
      seen.add(this);
    }

    return this;
  }
}

class EmptyLanguage extends Parser {
  @override
  Parser derive(int char) => EmptyLanguage();

  @override
  Set deriveNull() => {};

  @override
  String toString () => 'EMPTY';
}

class EmptyString extends Parser {

   final Set trees = {};

  EmptyString.empty() { trees.add(Literal(0)); } // TODO: double check?
  EmptyString.character(int char) { trees.add(Literal(char)); }

  @override
  Parser derive(int char) => EmptyLanguage();

  @override
  Set deriveNull() => trees;

  @override
  String toString() => '$trees';
}

class Literal extends Parser {

  final int char;
  Literal(this.char);


  @override
  Parser derive(int char) => this.char == char ? EmptyString.character(char) : EmptyLanguage();

  @override
  Set deriveNull() => {};

  @override
  String toString() => String.fromCharCode(char);
}

class Concat extends Parser {

  final Parser l1, l2;

  Concat(this.l1, this.l2);

  @override
  Parser derive(int char) =>
    Alternative(Concat(l1.derive(char), l2), Concat(Delta(l1), l2.derive(char)));

  @override
  Set deriveNull() {
    var s1 = l1.deriveNull();
    var s2 = l2.deriveNull();
    var result = <dynamic>{};

    for (var o1 in s1) {
      for (var o2 in s2) {
        result.add(Tuple2(o1, o2));
      }
    }
    return result;
  }

  @override
  String toString() => '$l1 & $l2';
}

class Alternative extends Parser {
  final Parser l1, l2;

  Alternative(this.l1, this.l2);

  @override
  Parser derive(int char) => Alternative(l1.derive(char), l2.derive(char));

  @override
  Set deriveNull() => {...l1.deriveNull(), ...l2.deriveNull()};

  @override
  String toString() => '$l1 | $l2';
}

class Delta extends Parser {
  final Parser l;
  Delta(this.l);

  @override
  Parser derive(int char) => EmptyLanguage();
  @override
  Set deriveNull() => l.deriveNull();
  @override
  String toString () => l.toString();
}

abstract class Reduction<T, U> {
  U reduce (T t);
}

class Reduce extends Parser {

  Parser parser;
  Reduction reduction;

  Reduce(this.parser, this.reduction);


  @override
  Parser derive(int char) => Reduce(parser.derive(char), reduction);

  @override
  Set deriveNull() {
    var result = <dynamic>{};
    for (var o in parser.deriveNull()) {
      result.add(reduction.reduce(o));
    }
    return result;
  }

}

class Recurrence extends Parser {

  Parser l;

  set parser(l) { this.l = l; }

  @override
  Parser derive(int char) => l.derive(char);

  @override
  Set deriveNull() => l.deriveNull();
}