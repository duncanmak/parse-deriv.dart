import 'package:charcode/ascii.dart';

extension CharacterHelpers on int {
  bool get isNewline =>
    this == $lf || this == $cr;
}



enum State {
  start,
  comment,
  number,
  string,
  name,
}

Set digits = {$0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $0};

class PSScanner {

  String input;
  State state = State.start;
  StringBuffer buf = StringBuffer();

  PSScanner(this.input);


  bool isNewline(int a, int b) => a == $cr || [a, b] == [$cr, $lf];


  bool isNumber(int c) {
    if (c == $plus || c == $minus) return true;

    if (digits.contains(c)) {
      return true;
    }

    return false;
  }

  dynamic token() {
  }

  bool get comment => state == State.comment;

  Iterable scan() sync* {
    var i = 0;
    var units = input.codeUnits;

    while (i < units.length) {

      // Comments
      var c = input.codeUnitAt(i);
      var next = i + 1 <= units.length ? input.codeUnitAt(i + 1) : -1;
      if (comment && isNewline(c, next)) {
        state = State.start;
        i += 2;
        continue;
      }

      if (c == $percent) {
        state = State.comment;
      }

      if (c == $space) {
        yield token();
      }

      if (isNumber(c)) {
        state = State.number;
      } else if (c == $open_paren) {
        state = State.string;
      } else {
        state = State.name;
      }

      buf.writeCharCode(c);
      i++;
    }
  }


}