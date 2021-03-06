import 'dart:typed_data';

///
/// Utils class holding different methods to ease the handling of ANS1Objects and their byte representation.
///
class ASN1Utils {
  ///
  /// Calculates the start position of the value bytes for the given [encodedBytes].
  ///
  /// It will return 2 if the **length byte** is less than 127 or the length calculate on the **length byte** value.
  /// This will throw a [RangeError] if the given [encodedBytes] has length < 2.
  ///
  static int calculateValueStartPosition(Uint8List encodedBytes) {
    var length = encodedBytes[1];
    if (length < 0x7F) {
      return 2;
    } else {
      return 2 + (length & 0x7F);
    }
  }

  ///
  /// Calculates the length of the **value bytes** for the given [encodedBytes].
  ///
  /// Will return **-1** if the length byte equals **0x80**. Throws an [ArgumentError] if the length could not be calculated for the given [encodedBytes].
  ///
  static int decodeLength(Uint8List encodedBytes) {
    var valueStartPosition = 2;
    var length = encodedBytes[1];
    if (length < 0x7F) {
      return length;
    }
    if (length == 0x80) {
      return -1;
    }
    if (length > 127) {
      var length = encodedBytes[1] & 0x7F;

      var numLengthBytes = length;

      length = 0;
      for (var i = 0; i < numLengthBytes; i++) {
        length <<= 8;
        length |= (encodedBytes[valueStartPosition++] & 0xFF);
      }
      return length;
    }
    throw ArgumentError('Could not calculate the length from the given bytes.');
  }

  ///
  /// Encode the given [length] to byte representation.
  ///
  static Uint8List encodeLength(int length) {
    Uint8List e;
    if (length <= 127) {
      e = Uint8List(1);
      e[0] = length;
    } else {
      var x = Uint32List(1);
      x[0] = length;
      var y = Uint8List.view(x.buffer);
      // Skip null bytes
      var num = 3;
      while (y[num] == 0) {
        --num;
      }
      e = Uint8List(num + 2);
      e[0] = 0x80 + num + 1;
      for (var i = 1; i < e.length; ++i) {
        e[i] = y[num--];
      }
    }
    return e;
  }
}
