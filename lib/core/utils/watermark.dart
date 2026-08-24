/// Invisible watermark utilities.
///
/// Embeds a hidden signature using zero-width Unicode characters.
/// The mark is not visible to users but can still be detected later
/// even after light editing in many cases.
class JagxWatermark {
  /// Hidden payload: "jagxai by JagX and JRILICENSE"
  static const String payload = 'jagxai by JagX and JRILICENSE';

  // Zero-width characters used for encoding
  static const String _zwsp = '\u200B'; // zero width space = 0
  static const String _zwnj = '\u200C'; // zero width non-joiner = 1
  static const String _zwj = '\u200D';  // zero width joiner = separator

  /// Embeds an invisible watermark into [text].
  /// The result looks identical to humans.
  static String embed(String text) {
    if (text.isEmpty) return text;

    final encoded = _encode(payload);
    // Place watermark near the end, before the last character if possible
    if (text.length <= 1) {
      return '$text$encoded';
    }

    final insertAt = text.length - 1;
    return text.substring(0, insertAt) + encoded + text.substring(insertAt);
  }

  /// Returns true if the watermark signature is detected in [text].
  static bool detect(String text) {
    final decoded = _decode(text);
    return decoded.contains('jagxai') && decoded.contains('JRILICENSE');
  }

  /// Extracts any hidden watermark payload found in [text].
  static String? extract(String text) {
    final decoded = _decode(text);
    if (decoded.contains('jagxai')) return decoded;
    return null;
  }

  static String _encode(String input) {
    final bytes = input.codeUnits;
    final buffer = StringBuffer();

    for (final byte in bytes) {
      for (var i = 7; i >= 0; i--) {
        final bit = (byte >> i) & 1;
        buffer.write(bit == 0 ? _zwsp : _zwnj);
      }
      buffer.write(_zwj); // separator between bytes
    }

    return buffer.toString();
  }

  static String _decode(String text) {
    final buffer = StringBuffer();
    var currentByte = 0;
    var bitCount = 0;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == _zwsp) {
        currentByte = (currentByte << 1) | 0;
        bitCount++;
      } else if (char == _zwnj) {
        currentByte = (currentByte << 1) | 1;
        bitCount++;
      } else if (char == _zwj) {
        if (bitCount == 8) {
          buffer.writeCharCode(currentByte);
        }
        currentByte = 0;
        bitCount = 0;
      }

      if (bitCount == 8) {
        buffer.writeCharCode(currentByte);
        currentByte = 0;
        bitCount = 0;
      }
    }

    return buffer.toString();
  }
}
